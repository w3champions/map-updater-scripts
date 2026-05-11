import * as W3CEvents from "../lua/w3cEvents";
import { getUnitName } from "./objectNames";

export function trackHeroRevive() {
    const trigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) === PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_HERO_REVIVE_START);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_HERO_REVIVE_CANCEL);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_HERO_REVIVE_FINISH);
        }
    }

    TriggerAddAction(trigger, () => {
        const hero = GetRevivingUnit();
        if (hero == null) return;

        const heroTypeId = GetUnitTypeId(hero);
        const id = GetPlayerId(GetOwningPlayer(hero));

        // GetTriggerUnit() should be the reviving structure (altar/tavern).
        // Validated assumption: needs confirmation in a test map.
        const source = GetTriggerUnit();

        const eventId = GetTriggerEventId();
        const eventName =
            eventId === EVENT_PLAYER_HERO_REVIVE_START
                ? "HeroReviveStart"
                : eventId === EVENT_PLAYER_HERO_REVIVE_CANCEL
                ? "HeroReviveCancel"
                : "HeroReviveFinish";

        W3CEvents.event(eventName, {
            player: id,
            hero: getUnitName(heroTypeId),
            heroTypeId,
            // On FINISH, the hero has a valid position at its spawn point.
            // On START/CANCEL, we use the revive structure position as a proxy.
            x: eventId === EVENT_PLAYER_HERO_REVIVE_FINISH ? GetUnitX(hero) : GetUnitX(source),
            y: eventId === EVENT_PLAYER_HERO_REVIVE_FINISH ? GetUnitY(hero) : GetUnitY(source),
        });
    });
}
