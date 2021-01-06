import { getPlayerRGBCode } from "utils";
import { Unit, MapPlayer, TextTag, Trigger } from "w3ts/index";

export function enableUnitDenyTrigger() {
  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH);
  t.addCondition(() => Unit.fromEvent().owner === Unit.fromHandle(GetKillingUnit()).owner); // Returns TRUE if the unit that was killed belongs to the same player who killed it
  t.addAction(() => showExclamationOverDyingUnit("UNIT_DENY"));
}

export function showExclamationOverDyingUnit(type: string) {
  const u = Unit.fromEvent();
  const p = Unit.fromHandle(GetKillingUnit());
  const lp = MapPlayer.fromLocal();
  const color = getPlayerRGBCode(p.owner)
  const tt = new TextTag();
  tt.setText("!", 12, true);
  tt.setPosUnit(u, -50.00);
  tt.setColor(color.red, color.green, color.blue, 0);
  tt.setPermanent(false);
  tt.setLifespan(2.00);
  tt.setFadepoint(1.50);

  if (type == "UNIT_DENY") {
    // Only show if the player actually has vision of the dying unit (or if player is observer);
    // that way players won't see denies in fog of war
    const flag = (!u.isVisible(lp) && !u.isFogged(lp) && u.isMasked(lp) || lp.isObserver())
    tt.setVisible(flag);
  }
  else if (type == "CREEP_LAST_HIT") {
    // Only show if the player is an observer
    tt.setVisible(lp.isObserver());
  }
}

