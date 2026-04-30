import * as W3CEvents from "../lua/w3cEvents";
import { getDistanceBucket, getRecentlySeenBucketFromDelta, quantizeCoord } from "./orderContextHelpers";

const POINT_SCAN_RADIUS = 900;
const REVEAL_SOURCE_NONE = 0;
const REVEAL_SOURCE_LEGAL_VISION = 1;

let visionClock: timer | undefined;
let visionRefreshTimer: timer | undefined;
let orderContextTrackingEnabled = false;

const trackedPlayers: number[] = [];
const trackedUnits: Record<number, unit> = {};
const lastSeenByPlayer: Record<number, Record<number, number>> = {};

export function trackOrderContext() {
    if (orderContextTrackingEnabled) {
        return;
    }

    initializeVisionTracking();

    const unitOrderTrigger = CreateTrigger();
    const pointOrderTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) === PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(player)) {
            trackedPlayers.push(i);
            TriggerRegisterPlayerUnitEvent(unitOrderTrigger, player, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER);
            TriggerRegisterPlayerUnitEvent(pointOrderTrigger, player, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER);
        }
    }

    TriggerAddAction(unitOrderTrigger, onIssuedTargetOrder);
    TriggerAddAction(pointOrderTrigger, onIssuedPointOrder);
    orderContextTrackingEnabled = true;
}

function initializeVisionTracking() {
    if (!visionClock) {
        visionClock = CreateTimer();
        TimerStart(visionClock, 1e9, false, undefined);
    }

    if (!visionRefreshTimer) {
        visionRefreshTimer = CreateTimer();
        TimerStart(visionRefreshTimer, 1.0, true, refreshTrackedVision);
    }
}

function onIssuedTargetOrder() {
    const issuer = GetTriggerUnit();
    const target = GetOrderTargetUnit();
    if (!issuer || !target || !shouldTrackIssuer(issuer) || !isRelevantEnemyTarget(target, GetTriggerPlayer())) {
        return;
    }

    const actingPlayer = GetTriggerPlayer();
    const playerId = GetPlayerId(actingPlayer);
    const targetHandleId = GetHandleId(target);

    rememberUnit(target);

    const visible = IsUnitVisible(target, actingPlayer);
    const fogged = IsUnitFogged(target, actingPlayer);
    const masked = IsUnitMasked(target, actingPlayer);

    if (visible && !fogged && !masked) {
        setLastSeen(playerId, targetHandleId, nowSeconds());
    }

    W3CEvents.event("OrderContextUnit", {
        player: playerId,
        issuerTypeId: GetUnitTypeId(issuer),
        issuerOwner: GetPlayerId(GetOwningPlayer(issuer)),
        orderId: GetIssuedOrderId(),
        targetTypeId: GetUnitTypeId(target),
        targetOwner: GetPlayerId(GetOwningPlayer(target)),
        targetIsHero: IsUnitType(target, UNIT_TYPE_HERO),
        targetIsStructure: IsUnitType(target, UNIT_TYPE_STRUCTURE),
        targetX: quantizeCoord(GetUnitX(target)),
        targetY: quantizeCoord(GetUnitY(target)),
        visible,
        fogged,
        masked,
        recentlySeenBucket: getRecentlySeenBucket(playerId, targetHandleId),
        revealSource: visible && !fogged && !masked ? REVEAL_SOURCE_LEGAL_VISION : REVEAL_SOURCE_NONE,
    });
}

function onIssuedPointOrder() {
    const issuer = GetTriggerUnit();
    const actingPlayer = GetTriggerPlayer();
    if (!issuer || !shouldTrackIssuer(issuer)) {
        return;
    }

    const pointX = GetOrderPointX();
    const pointY = GetOrderPointY();
    const nearestHiddenEnemy = findNearestHiddenEnemy(actingPlayer, pointX, pointY);
    if (!nearestHiddenEnemy) {
        return;
    }

    const playerId = GetPlayerId(actingPlayer);

    W3CEvents.event("OrderContextPoint", {
        player: playerId,
        issuerTypeId: GetUnitTypeId(issuer),
        issuerOwner: GetPlayerId(GetOwningPlayer(issuer)),
        orderId: GetIssuedOrderId(),
        pointX: quantizeCoord(pointX),
        pointY: quantizeCoord(pointY),
        nearHiddenEnemy: true,
        nearestHiddenEnemyType: GetUnitTypeId(nearestHiddenEnemy.unit),
        nearestHiddenEnemyOwner: GetPlayerId(GetOwningPlayer(nearestHiddenEnemy.unit)),
        distanceBucket: getDistanceBucket(nearestHiddenEnemy.distance),
        recentlySeenBucket: getRecentlySeenBucket(playerId, nearestHiddenEnemy.handleId),
        revealSource: IsVisibleToPlayer(pointX, pointY, actingPlayer) ? REVEAL_SOURCE_LEGAL_VISION : REVEAL_SOURCE_NONE,
    });
}

function shouldTrackIssuer(issuer: unit) {
    const owner = GetOwningPlayer(issuer);
    return GetPlayerSlotState(owner) === PLAYER_SLOT_STATE_PLAYING
        && !IsPlayerObserver(owner)
        && !IsUnitType(issuer, UNIT_TYPE_DEAD);
}

function isRelevantEnemyTarget(target: unit, actingPlayer: player) {
    const owner = GetOwningPlayer(target);
    if (owner === actingPlayer || IsPlayerAlly(owner, actingPlayer)) {
        return false;
    }

    return isRelevantTrackedUnit(target);
}

function isRelevantTrackedUnit(target: unit) {
    if (!target || IsUnitType(target, UNIT_TYPE_DEAD)) {
        return false;
    }

    const ownerId = GetPlayerId(GetOwningPlayer(target));
    if (ownerId === PLAYER_NEUTRAL_AGGRESSIVE || ownerId === PLAYER_NEUTRAL_PASSIVE) {
        return false;
    }

    return IsUnitType(target, UNIT_TYPE_HERO)
        || IsUnitType(target, UNIT_TYPE_STRUCTURE)
        || IsUnitType(target, UNIT_TYPE_PEON)
        || isWorkerByType(target);
}

function isWorkerByType(target: unit) {
    const unitTypeId = GetUnitTypeId(target);
    return unitTypeId === FourCC("hpea")
        || unitTypeId === FourCC("opeo")
        || unitTypeId === FourCC("uaco")
        || unitTypeId === FourCC("ewsp")
        || unitTypeId === FourCC("ngir")
        || unitTypeId === FourCC("hmil");
}

function rememberUnit(target: unit) {
    trackedUnits[GetHandleId(target)] = target;
}

function refreshTrackedVision() {
    const currentTime = nowSeconds();

    for (let index = 0; index < trackedPlayers.length; index++) {
        const playerId = trackedPlayers[index];
        const actingPlayer = Player(playerId);
        for (const handleIdKey in trackedUnits) {
            const handleId = tonumber(handleIdKey) as number;
            const trackedUnit = trackedUnits[handleId];
            if (!trackedUnit || IsUnitType(trackedUnit, UNIT_TYPE_DEAD)) {
                delete trackedUnits[handleId];
                continue;
            }

            if (IsUnitVisible(trackedUnit, actingPlayer) && !IsUnitFogged(trackedUnit, actingPlayer) && !IsUnitMasked(trackedUnit, actingPlayer)) {
                setLastSeen(playerId, handleId, currentTime);
            }
        }
    }
}

function findNearestHiddenEnemy(actingPlayer: player, x: number, y: number) {
    const group = CreateGroup();
    let nearestUnit: unit | undefined;
    let nearestDistance = POINT_SCAN_RADIUS + 1;
    let nearestHandleId = 0;

    GroupEnumUnitsInRange(group, x, y, POINT_SCAN_RADIUS, undefined);

    let candidate = FirstOfGroup(group);
    while (candidate) {
        GroupRemoveUnit(group, candidate);

        if (isRelevantEnemyTarget(candidate, actingPlayer)) {
            rememberUnit(candidate);

            const visible = IsUnitVisible(candidate, actingPlayer) && !IsUnitFogged(candidate, actingPlayer) && !IsUnitMasked(candidate, actingPlayer);
            if (visible) {
                setLastSeen(GetPlayerId(actingPlayer), GetHandleId(candidate), nowSeconds());
            } else {
                const distance = distanceBetweenPoints(x, y, GetUnitX(candidate), GetUnitY(candidate));
                if (distance < nearestDistance) {
                    nearestUnit = candidate;
                    nearestDistance = distance;
                    nearestHandleId = GetHandleId(candidate);
                }
            }
        }

        candidate = FirstOfGroup(group);
    }

    DestroyGroup(group);

    if (!nearestUnit) {
        return undefined;
    }

    return {
        unit: nearestUnit,
        distance: nearestDistance,
        handleId: nearestHandleId,
    };
}

function distanceBetweenPoints(ax: number, ay: number, bx: number, by: number) {
    const dx = ax - bx;
    const dy = ay - by;
    return SquareRoot(dx * dx + dy * dy);
}

function nowSeconds() {
    return visionClock ? Math.floor(TimerGetElapsed(visionClock)) : 0;
}

function setLastSeen(playerId: number, handleId: number, timeSeen: number) {
    if (!lastSeenByPlayer[playerId]) {
        lastSeenByPlayer[playerId] = {};
    }

    lastSeenByPlayer[playerId][handleId] = timeSeen;
}

function getRecentlySeenBucket(playerId: number, handleId: number) {
    const playerSeenCache = lastSeenByPlayer[playerId];
    const seenAt = playerSeenCache ? playerSeenCache[handleId] : undefined;
    const delta = seenAt === undefined ? undefined : nowSeconds() - seenAt;
    return getRecentlySeenBucketFromDelta(delta);
}
