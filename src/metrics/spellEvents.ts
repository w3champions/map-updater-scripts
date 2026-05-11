import * as W3CEvents from "../lua/w3cEvents";
import { getUnitName, getAbilityName } from "./objectNames";

export function trackSpellEvents() {
    const trigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) === PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_SPELL_EFFECT);
        }
    }

    // Hero spells only — unit spell tracking can be enabled later after volume testing
    TriggerAddCondition(trigger, Condition(() => IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO)));
    TriggerAddAction(trigger, onSpellEffect);
}

function onSpellEffect() {
    const caster = GetSpellAbilityUnit();
    const abilityId = GetSpellAbilityId();
    const casterTypeId = GetUnitTypeId(caster);
    const id = GetPlayerId(GetOwningPlayer(caster));

    const targetUnit = GetSpellTargetUnit();
    let targetTypeId = 0;
    let targetName = "";
    let targetPlayer = -1;
    let targetX = GetSpellTargetX();
    let targetY = GetSpellTargetY();

    if (targetUnit != null) {
        targetTypeId = GetUnitTypeId(targetUnit);
        targetName = getUnitName(targetTypeId);
        targetPlayer = GetPlayerId(GetOwningPlayer(targetUnit));
        targetX = GetUnitX(targetUnit);
        targetY = GetUnitY(targetUnit);
    }

    W3CEvents.event("SpellEvent", {
        player: id,
        caster: getUnitName(casterTypeId),
        casterTypeId,
        casterX: GetUnitX(caster),
        casterY: GetUnitY(caster),
        abilityId,
        ability: getAbilityName(abilityId),
        targetTypeId,
        target: targetName,
        targetPlayer,
        targetX,
        targetY,
    });
}
