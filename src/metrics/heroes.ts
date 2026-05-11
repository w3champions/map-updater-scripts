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

    W3CEvents.event("HeroLevel", {
        player: id,
        hero: getUnitName(heroTypeId),
        heroTypeId,
        level: GetHeroLevel(unit),
        x: GetUnitX(unit),
        y: GetUnitY(unit),
    });
}

function trackHeroSkill() {
    const hero = GetTriggerUnit();
    const id = GetPlayerId(GetOwningPlayer(hero));
    const heroTypeId = GetUnitTypeId(hero);
    const skillId = GetLearnedSkill();

    W3CEvents.event("HeroSkill", {
        player: id,
        hero: getUnitName(heroTypeId),
        heroTypeId,
        heroLevel: GetHeroLevel(hero),
        skill: getAbilityName(skillId),
        skillId,
        skillLevel: GetLearnedSkillLevel(),
        x: GetUnitX(hero),
        y: GetUnitY(hero),
    });
}

function shopContext(shopUnit: unit | null) {
    if (shopUnit == null) {
        return { shopName: "", shopTypeId: 0, shopX: 0, shopY: 0 };
    }
    const typeId = GetUnitTypeId(shopUnit);
    return {
        shopName: getUnitName(typeId),
        shopTypeId: typeId,
        shopX: GetUnitX(shopUnit),
        shopY: GetUnitY(shopUnit),
    };
}

function trackHeroInventory() {
    const hero = GetTriggerUnit();
    const item = GetManipulatedItem();
    const heroTypeId = GetUnitTypeId(hero);
    const itemTypeId = GetItemTypeId(item);
    const id = GetPlayerId(GetOwningPlayer(hero));
    const eventId = GetTriggerEventId();

    const base: W3CEvents.EventPayload = {
        player: id,
        hero: getUnitName(heroTypeId),
        heroTypeId,
        item: getItemName(itemTypeId),
        itemTypeId,
        x: GetUnitX(hero),
        y: GetUnitY(hero),
    };

    if (eventId === EVENT_PLAYER_UNIT_PICKUP_ITEM) {
        let slot = 0;
        for (let i = 0; i < bj_MAX_INVENTORY; i++) {
            if (UnitItemInSlot(hero, i) === item) {
                slot = i;
            }
        }
        W3CEvents.event("HeroItemPickup", { ...base, slot });

    } else if (eventId === EVENT_PLAYER_UNIT_DROP_ITEM) {
        W3CEvents.event("HeroItemDrop", base);

    } else if (eventId === EVENT_PLAYER_UNIT_SELL_ITEM) {
        // Hero buys from a shop: GetSellingUnit() is the shop
        W3CEvents.event("HeroItemBought", { ...base, ...shopContext(GetSellingUnit()) });

    } else if (eventId === EVENT_PLAYER_UNIT_PAWN_ITEM) {
        // Hero sells to a pawn shop: GetBuyingUnit() may return the shop (needs validation)
        W3CEvents.event("HeroItemSold", { ...base, ...shopContext(GetBuyingUnit()) });
    }
}

function trackHeroItemUse() {
    const hero = GetTriggerUnit();
    const item = GetManipulatedItem();
    const heroTypeId = GetUnitTypeId(hero);
    const itemTypeId = GetItemTypeId(item);
    const id = GetPlayerId(GetOwningPlayer(hero));
    const target = getHeroItemUseTarget();

    W3CEvents.event("HeroItemUse", {
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
    });
}

interface HeroItemUseTarget {
    x: number;
    y: number;
    typeId: number;
    name: string;
    player: number;
}

function getHeroItemUseTarget(): HeroItemUseTarget {
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

    return {
        x: GetSpellTargetX(),
        y: GetSpellTargetY(),
        typeId: 0,
        name: "",
        player: -1,
    };
}
