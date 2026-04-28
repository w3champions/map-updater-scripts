import * as W3CEvents from "../lua/w3cEvents";

export function trackHeroes() {
    const heroLevel = CreateTrigger();
    const heroSkill = CreateTrigger();
    const heroInventory = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(heroLevel, Player(i), EVENT_PLAYER_HERO_LEVEL);
            TriggerRegisterPlayerUnitEvent(heroSkill, Player(i), EVENT_PLAYER_HERO_SKILL);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_DROP_ITEM);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_SELL_ITEM);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_PAWN_ITEM);
        }
    }

    TriggerAddAction(heroLevel, trackHeroLevel);
    TriggerAddAction(heroSkill, trackHeroSkill);

    TriggerAddCondition(heroInventory, Condition(isHero));
    TriggerAddAction(heroInventory, trackHeroInventory);
}

function isHero() {
    const unit = GetTriggerUnit();
    return IsUnitType(unit, UNIT_TYPE_HERO)
}

function trackHeroLevel() {
    const unit = GetTriggerUnit();
    const player = GetOwningPlayer(unit);
    const id = GetPlayerId(player);

    const payload: W3CEvents.EventPayload = {
        player: id,
        hero: GetUnitName(unit),
        level: GetHeroLevel(unit),
    };

    W3CEvents.event("HeroLevel", payload);
}

function trackHeroSkill() {
    const hero = GetTriggerUnit();
    const id = GetPlayerId(GetOwningPlayer(hero));

    const payload: W3CEvents.EventPayload = {
        player: id,
        hero: GetUnitName(hero),
        heroLevel: GetHeroLevel(hero),
        skill: GetObjectName(GetLearnedSkill()),
        skillLevel: GetLearnedSkillLevel(),
    };

    W3CEvents.event("HeroSkill", payload);
}

function trackHeroInventory() {
    const hero = GetTriggerUnit();
    const item = GetManipulatedItem();
    const itemName = GetItemName(item);
    const id = GetPlayerId(GetOwningPlayer(hero));

    const payload: W3CEvents.EventPayload = {
        player: id,
        item: itemName,
    };

    let eventType = "";
    let eventId = GetTriggerEventId();

    if (eventId === EVENT_PLAYER_UNIT_PICKUP_ITEM) {
        eventType = "HeroItemPickup";
        for (let i = 0; i < bj_MAX_INVENTORY; i++) {
            if (UnitItemInSlot(hero, i) === item) {
                payload.slot = i;
            }
        }
    } else if (eventId === EVENT_PLAYER_UNIT_DROP_ITEM) {
        eventType = "HeroItemDrop";
    } else if (eventId === EVENT_PLAYER_UNIT_SELL_ITEM) {
        eventType = "HeroItemBought";
    } else if (eventId === EVENT_PLAYER_UNIT_PAWN_ITEM) {
        eventType = "HeroItemSold";
    }

    W3CEvents.event(eventType, payload);
}
