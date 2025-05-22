import { ItemProps } from "war3-objectdata-th/dist/cjs/generated/items";
import * as W3Metrics from "../lua/w3cMetrics";

export function trackHeroes() {
    const heroLevel = CreateTrigger();
    const heroSkill = CreateTrigger();
    const heroInventory = CreateTrigger();
    const heroXp = CreateTrigger();

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

    const payload: W3Metrics.EventPayload = {
        player: id,
        value: {},
    }

    payload.value["hero"] = GetUnitName(unit);
    payload.value["level"] = GetHeroLevel(unit);

    W3Metrics.event("HeroLevel", payload);
}

function trackHeroSkill() {
    const hero = GetTriggerUnit();
    const id = GetPlayerId(GetOwningPlayer(hero));

    const payload: W3Metrics.EventPayload = {
        player: id,
        value: {},
    };

    payload.value["hero"] = GetUnitName(hero);
    payload.value["heroLevel"] = GetHeroLevel(hero);

    payload.value["skill"] = GetObjectName(GetLearnedSkill());
    payload.value["skillLevel"] = GetLearnedSkillLevel();

    W3Metrics.event("HeroSkill", payload);
}

function trackHeroInventory() {
    const hero = GetTriggerUnit();
    const item = GetManipulatedItem();
    const itemName = GetItemName(item);
    const id = GetPlayerId(GetOwningPlayer(hero));

    const payload: W3Metrics.EventPayload = {
        player: id,
        value: {
            item: itemName
        },
    };

    let eventType = "";
    let eventId = GetTriggerEventId();

    if (eventId === EVENT_PLAYER_UNIT_PICKUP_ITEM) {
        eventType = "HeroItemPickup";
        for (let i = 0; i < bj_MAX_INVENTORY; i++) {
            if (UnitItemInSlot(hero, i) === item) {
                payload.value["slot"] = i;
            }
        }
    } else if (eventId === EVENT_PLAYER_UNIT_DROP_ITEM) {
        eventType = "HeroItemDrop";
    } else if (eventId === EVENT_PLAYER_UNIT_SELL_ITEM) {
        eventType = "HeroItemBought";
    } else if (eventId === EVENT_PLAYER_UNIT_PAWN_ITEM) {
        eventType = "HeroItemSold";
    }

    W3Metrics.event(eventType, payload);
}
