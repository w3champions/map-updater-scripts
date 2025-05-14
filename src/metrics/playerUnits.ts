import * as W3CMetrics from "../lua/w3cMetrics"

export function trackPlayerUnitTrained() {
    const trigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_TRAIN_START);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_TRAIN_CANCEL);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_TRAIN_FINISH);
        }
    }

    TriggerAddAction(trigger, trackPlayerTraining);
};

function trackPlayerTraining() {
    const eventId = GetTriggerEventId();
    const player = GetTriggerPlayer();
    const id = GetPlayerId(player);

    let name = "";
    let typeId = 0;
    let isHero = false;

    if (eventId === EVENT_PLAYER_UNIT_TRAIN_START) {
        typeId = GetTrainedUnitType();
        name = GetObjectName(typeId);
        isHero = IsHeroUnitId(typeId); // helper below
    } else {
        const unit = GetTrainedUnit();
        typeId = GetUnitTypeId(unit);
        name = GetUnitName(unit);
        isHero = IsUnitType(unit, UNIT_TYPE_HERO);
    }

    const eventType =
        eventId === EVENT_PLAYER_UNIT_TRAIN_START
            ? isHero ? "HeroStarted" : "UnitStarted"
            : eventId === EVENT_PLAYER_UNIT_TRAIN_CANCEL
            ? isHero ? "HeroCancelled" : "UnitCancelled"
            : isHero ? "HeroTrained" : "UnitTrained";

    W3CMetrics.event(eventType, {
        player: id,
        name,
        typeId,
    });
}

function IsHeroUnitId(unitId: number): boolean {
    return IsUnitType(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), unitId, 0, 0, 0), UNIT_TYPE_HERO);
}
    
