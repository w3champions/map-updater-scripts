import { getPlayerRGBCode } from "utils";
import { Unit, MapPlayer, Trigger } from "w3ts/index";

export function enableUnitDenyTrigger() {
  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH);
  t.addCondition(() => Unit.fromEvent().owner.isPlayerAlly(Unit.fromHandle(GetKillingUnit()).owner));  // Returns TRUE if the unit that was killed belongs to the same player who killed it
  t.addAction(() => showExclamationOverDyingUnit("UNIT_DENY"));
}

export function showExclamationOverDyingUnit(type: string) {
  const dyingUnit = Unit.fromHandle(GetDyingUnit());
  const localPlayer = MapPlayer.fromLocal();
  const color = getPlayerRGBCode(Unit.fromHandle(GetKillingUnit()).owner)

  let tag: texttag = CreateTextTagUnitBJ("!", dyingUnit.handle, -80.00, 13, color[0], color[1], color[2], 0)
  SetTextTagPermanentBJ(tag, false)
  SetTextTagVelocityBJ(tag, 20, 90)
  SetTextTagLifespanBJ(tag, 2.00)
  SetTextTagFadepointBJ(tag, 1.50)

  if (type == "UNIT_DENY") {
    // Only show if the player actually has vision of the dying unit (or if player is observer);
    // that way players won't see denies in fog of war
    SetTextTagVisibility(tag, (dyingUnit.isVisible(localPlayer) && !dyingUnit.isFogged(localPlayer) && !dyingUnit.isMasked(localPlayer)) || localPlayer.isObserver());
  }
  else if (type == "CREEP_LAST_HIT") {
    // Only show if the player is an observer
    SetTextTagVisibility(tag, localPlayer.isObserver());
  }
}
