import { Players } from "w3ts/globals";
import * as W3CEvents from "../lua/w3cEvents";
import { getUnitName } from "./objectNames";

export function trackUnitLifecycle() {
    trackSummons();
    trackOwnerChanges();
    trackUnitSales();
}

function isPlayerOwned(unit: unit): boolean {
    return GetOwningPlayer(unit) !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle;
}

function trackSummons() {
    const trigger = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SUMMON);
    TriggerAddAction(trigger, () => {
        const summoner = GetTriggerUnit();
        if (!isPlayerOwned(summoner)) return;

        const summoned = GetSummonedUnit();
        if (summoned == null) return;

        const summonerTypeId = GetUnitTypeId(summoner);
        const summonedTypeId = GetUnitTypeId(summoned);

        W3CEvents.event("UnitSummoned", {
            player: GetPlayerId(GetOwningPlayer(summoner)),
            summoner: getUnitName(summonerTypeId),
            summonerTypeId,
            summonerX: GetUnitX(summoner),
            summonerY: GetUnitY(summoner),
            summoned: getUnitName(summonedTypeId),
            summonedTypeId,
            summonedX: GetUnitX(summoned),
            summonedY: GetUnitY(summoned),
        });
    });
}

function trackOwnerChanges() {
    const trigger = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_CHANGE_OWNER);
    TriggerAddAction(trigger, () => {
        const unit = GetChangingUnit();
        const prevOwner = GetChangingUnitPrevOwner();
        const newOwner = GetOwningPlayer(unit);
        const newOwnerId = GetPlayerId(newOwner);
        const prevOwnerId = GetPlayerId(prevOwner);

        // Only track when a player unit is involved (either side)
        const prevIsPlayer = prevOwner !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle;
        const newIsPlayer = newOwner !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle;
        if (!prevIsPlayer && !newIsPlayer) return;

        const typeId = GetUnitTypeId(unit);
        W3CEvents.event("UnitOwnerChanged", {
            player: newOwnerId,
            unit: getUnitName(typeId),
            typeId,
            x: GetUnitX(unit),
            y: GetUnitY(unit),
            previousOwner: prevOwnerId,
            newOwner: newOwnerId,
        });
    });
}

function trackUnitSales() {
    const trigger = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SELL);
    TriggerAddAction(trigger, () => {
        const buyer = GetBuyingUnit();
        if (buyer == null || !isPlayerOwned(buyer)) return;

        const soldUnit = GetSoldUnit();
        const shop = GetSellingUnit();

        if (soldUnit == null) return;

        const buyerPlayer = GetPlayerId(GetOwningPlayer(buyer));
        const soldTypeId = GetUnitTypeId(soldUnit);
        const shopTypeId = shop != null ? GetUnitTypeId(shop) : 0;

        W3CEvents.event("UnitSold", {
            player: buyerPlayer,
            soldUnit: getUnitName(soldTypeId),
            soldTypeId,
            soldX: GetUnitX(soldUnit),
            soldY: GetUnitY(soldUnit),
            shopName: shop != null ? getUnitName(shopTypeId) : "",
            shopTypeId,
            shopX: shop != null ? GetUnitX(shop) : 0,
            shopY: shop != null ? GetUnitY(shop) : 0,
            buyerPlayer,
        });
    });
}
