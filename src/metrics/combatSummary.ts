import { Players } from "w3ts/globals";
import * as W3CEvents from "../lua/w3cEvents";
import { getUnitName } from "./objectNames";

type UnitCategory = "hero" | "unit" | "worker" | "structure" | "creep";

interface WindowStats {
    sourcePlayer: number;
    targetPlayer: number;
    sourceCategory: string;
    targetCategory: string;
    sourceHeroTypeId: number;
    targetHeroTypeId: number;
    damage: number;
    eventCount: number;
    sumSourceX: number;
    sumSourceY: number;
    sumTargetX: number;
    sumTargetY: number;
}

// Accumulated per 5-second window; keyed by `srcPlayer:tgtPlayer:srcCat:tgtCat`
const windowData: Record<string, WindowStats> = {};

// Last PvP damage timestamp per source/target player pair, for CombatStart/End
const lastPvpDamageTime: Record<number, Record<number, number>> = {};
const combatActive: Record<number, Record<number, boolean>> = {};

// Seconds of no PvP damage before fight is considered ended / restarted
const COMBAT_GAP_SECONDS = 5;

export function trackCombatSummary() {
    const damageTrigger = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(damageTrigger, EVENT_PLAYER_UNIT_DAMAGED);
    TriggerAddAction(damageTrigger, onUnitDamaged);

    const combatEndTimer = CreateTimer();
    TimerStart(combatEndTimer, 1.0, true, checkCombatEnd);

    W3CEvents.track("CombatSummary", flushWindowData, 1);
}

function classifyUnit(unit: unit): UnitCategory {
    const owner = GetOwningPlayer(unit);
    if (owner === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) return "creep";
    if (IsUnitType(unit, UNIT_TYPE_HERO)) return "hero";
    if (IsUnitType(unit, UNIT_TYPE_STRUCTURE)) return "structure";
    if (IsUnitType(unit, UNIT_TYPE_PEON)) return "worker";
    const typeId = GetUnitTypeId(unit);
    if (typeId === FourCC("acol") || typeId === FourCC("drll")) return "worker";
    return "unit";
}

function isPlayerUnit(unit: unit): boolean {
    return GetOwningPlayer(unit) !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle;
}

function onUnitDamaged() {
    const source = GetEventDamageSource();
    const target = BlzGetEventDamageTarget();
    const damage = GetEventDamage();

    if (!isPlayerUnit(source)) return;

    const sourcePlayer = GetPlayerId(GetOwningPlayer(source));
    const targetPlayer = isPlayerUnit(target) ? GetPlayerId(GetOwningPlayer(target)) : -1;

    const srcCat = classifyUnit(source);
    const tgtCat = classifyUnit(target);
    const srcTypeId = GetUnitTypeId(source);
    const tgtTypeId = GetUnitTypeId(target);

    const key = `${sourcePlayer}:${targetPlayer}:${srcCat}:${tgtCat}`;

    if (!windowData[key]) {
        windowData[key] = {
            sourcePlayer,
            targetPlayer,
            sourceCategory: srcCat,
            targetCategory: tgtCat,
            sourceHeroTypeId: srcCat === "hero" ? srcTypeId : 0,
            targetHeroTypeId: tgtCat === "hero" ? tgtTypeId : 0,
            damage: 0,
            eventCount: 0,
            sumSourceX: 0,
            sumSourceY: 0,
            sumTargetX: 0,
            sumTargetY: 0,
        };
    }

    const w = windowData[key];
    w.damage += damage;
    w.eventCount += 1;
    w.sumSourceX += GetUnitX(source);
    w.sumSourceY += GetUnitY(source);
    w.sumTargetX += GetUnitX(target);
    w.sumTargetY += GetUnitY(target);

    // Only track fight state for real player-vs-player damage
    if (targetPlayer < 0 || targetPlayer === sourcePlayer) return;

    handlePvpDamage(sourcePlayer, targetPlayer, source, target, srcCat, tgtCat, srcTypeId, tgtTypeId);
}

function handlePvpDamage(
    srcPlayer: number,
    tgtPlayer: number,
    source: unit,
    target: unit,
    srcCat: UnitCategory,
    tgtCat: UnitCategory,
    srcTypeId: number,
    tgtTypeId: number,
) {
    lastPvpDamageTime[srcPlayer] ??= {};
    combatActive[srcPlayer] ??= {};

    const wasActive = combatActive[srcPlayer][tgtPlayer];
    const lastTime = lastPvpDamageTime[srcPlayer][tgtPlayer] ?? -999;
    const now = W3CEvents.now();

    lastPvpDamageTime[srcPlayer][tgtPlayer] = now;

    if (!wasActive || (now - lastTime) > COMBAT_GAP_SECONDS) {
        combatActive[srcPlayer][tgtPlayer] = true;
        W3CEvents.event("CombatStart", {
            player: srcPlayer,
            targetPlayer: tgtPlayer,
            sourceCategory: srcCat,
            sourceTypeId: srcTypeId,
            sourceX: GetUnitX(source),
            sourceY: GetUnitY(source),
            targetCategory: tgtCat,
            targetTypeId: tgtTypeId,
            targetX: GetUnitX(target),
            targetY: GetUnitY(target),
        });
    }
}

function checkCombatEnd() {
    const now = W3CEvents.now();
    for (const src in combatActive) {
        const srcPlayer = tonumber(src) as number;
        for (const tgt in combatActive[srcPlayer]) {
            const tgtPlayer = tonumber(tgt) as number;
            if (!combatActive[srcPlayer][tgtPlayer]) continue;
            const lastTime = lastPvpDamageTime[srcPlayer]?.[tgtPlayer] ?? 0;
            if (now - lastTime > COMBAT_GAP_SECONDS) {
                combatActive[srcPlayer][tgtPlayer] = false;
                W3CEvents.event("CombatEnd", {
                    player: srcPlayer,
                    targetPlayer: tgtPlayer,
                });
            }
        }
    }
}

function flushWindowData(): W3CEvents.EventPayload[] {
    const events: W3CEvents.EventPayload[] = [];

    for (const key in windowData) {
        const w = windowData[key];
        if (w.damage <= 0) continue;

        const count = w.eventCount;
        events.push({
            player: w.sourcePlayer,
            targetPlayer: w.targetPlayer,
            sourceCategory: w.sourceCategory,
            targetCategory: w.targetCategory,
            sourceHeroTypeId: w.sourceHeroTypeId,
            targetHeroTypeId: w.targetHeroTypeId,
            damage: w.damage,
            eventCount: count,
            sourceX: w.sumSourceX / count,
            sourceY: w.sumSourceY / count,
            targetX: w.sumTargetX / count,
            targetY: w.sumTargetY / count,
        });
    }

    // Reset window data after each flush
    for (const key in windowData) {
        delete windowData[key];
    }

    return events;
}
