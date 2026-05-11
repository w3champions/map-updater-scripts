import * as W3CEvents from "../lua/w3cEvents";
import { getUnitName, getItemName, getAbilityName } from "./objectNames";

export function trackHeroes() {
    const heroLevel = CreateTrigger();
    const heroSkill = CreateTrigger();
    const heroInventory = CreateTrigger();
    const heroItemUse = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(heroLevel, Player(i), EVENT_PLAYER_HERO_LEVEL);
            TriggerRegisterPlayerUnitEvent(heroSkill, Player(i), EVENT_PLAYER_HERO_SKILL);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_DROP_ITEM);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_SELL_ITEM);
            TriggerRegisterPlayerUnitEvent(heroInventory, Player(i), EVENT_PLAYER_UNIT_PAWN_ITEM);
            TriggerRegisterPlayerUnitEvent(heroItemUse, Player(i), EVENT_PLAYER_UNIT_USE_ITEM);
        }
    }

    TriggerAddAction(heroLevel, trackHeroLevel);
    TriggerAddAction(heroSkill, trackHeroSkill);

    TriggerAddCondition(heroInventory, Condition(isHero));
    TriggerAddAction(heroInventory, trackHeroInventory);

    TriggerAddCondition(heroItemUse, Condition(isHero));
    TriggerAddAction(heroItemUse, trackHeroItemUse);
}

function isHero() {
    const unit = GetTriggerUnit();
    return IsUnitType(unit, UNIT_TYPE_HERO)
}

function trackHeroLevel() {
    const unit = GetTriggerUnit();
    const player = GetOwningPlayer(unit);
    const id = GetPlayerId(player);
    const heroTypeId = GetUnitTypeId(unit);

    const payload: W3CEvents.EventPayload = {
        player: id,
        hero: getUnitName(heroTypeId),
        heroTypeId,
        level: GetHeroLevel(unit),
        x: GetUnitX(unit),
        y: GetUnitY(unit),
    };

    W3CEvents.event("HeroLevel", payload);
}

function trackHeroSkill() {
    const hero = GetTriggerUnit();
    const id = GetPlayerId(GetOwningPlayer(hero));
    const heroTypeId = GetUnitTypeId(hero);
    const skillId = GetLearnedSkill();

    const payload: W3CEvents.EventPayload = {
        player: id,
        hero: getUnitName(heroTypeId),
        heroTypeId,
        heroLevel: GetHeroLevel(hero),
        skill: getAbilityName(skillId),
        skillId,
        skillLevel: GetLearnedSkillLevel(),
        x: GetUnitX(hero),
        y: GetUnitY(hero),
    };

    W3CEvents.event("HeroSkill", payload);
}

function trackHeroInventory() {
    const hero = GetTriggerUnit();
    const item = GetManipulatedItem();
    const heroTypeId = GetUnitTypeId(hero);
    const itemTypeId = GetItemTypeId(item);
    const id = GetPlayerId(GetOwningPlayer(hero));

    const payload: W3CEvents.EventPayload = {
        player: id,
        hero: getUnitName(heroTypeId),
        heroTypeId,
        item: getItemName(itemTypeId),
        itemTypeId,
        x: GetUnitX(hero),
        y: GetUnitY(hero),
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

function trackHeroItemUse() {
    const hero = GetTriggerUnit();
    const item = GetManipulatedItem();
    const heroTypeId = GetUnitTypeId(hero);
    const itemTypeId = GetItemTypeId(item);
    const id = GetPlayerId(GetOwningPlayer(hero));
    const target = getHeroItemUseTarget();

    const payload: W3CEvents.EventPayload = {
        player: id,
        hero: getUnitName(heroTypeId),
        heroTypeId,
        item: getItemName(itemTypeId),
        itemTypeId,
        heroX: GetUnitX(hero),
        heroY: GetUnitY(hero),
        targetX: target.x,
        targetY: target.y,
        targetTypeId: target.typeId,
        target: target.name,
        targetPlayer: target.player,
    };

    W3CEvents.event("HeroItemUse", payload);
}

interface HeroItemUseTarget {
    x: number;
    y: number;
    typeId: number;
    name: string;
    player: number;
}

function getHeroItemUseTarget() : HeroItemUseTarget {
    const targetUnit = GetSpellTargetUnit();
    if (targetUnit != null) {
        const typeId = GetUnitTypeId(targetUnit);
        return {
            x: GetUnitX(targetUnit),
            y: GetUnitY(targetUnit),
            typeId,
            name: getUnitName(typeId),
            player: GetPlayerId(GetOwningPlayer(targetUnit)),
        };
    }

    const targetX = GetSpellTargetX();
    const targetY = GetSpellTargetY();

    return {
        x: targetX,
        y: targetY,
        typeId: 0,
        name: "",
        player: -1,
    };
}
