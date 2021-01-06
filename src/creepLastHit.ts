import { showExclamationOverDyingUnit } from "unitDeny";
import { Players } from "w3ts/globals/index";
import { Unit, Group, Trigger } from "w3ts/index";

export function enableCreepLastHitTrigger() {
    const checkDyingUnitIsCreepAndLocalPlayerIsObserverAndEnemyIsNearby = () => {
      const u = Unit.fromEvent();
      const killer = Unit.fromHandle(GetKillingUnit());
  
      // Returns FALSE if dying unit is NOT a creep
      if (u.owner != Players[PLAYER_NEUTRAL_AGGRESSIVE]) {
        return false;
      }
  
      // Returns FALSE when no enemy units are nearby (e.g. range 800 = coil range)
      const g = new Group();
      g.enumUnitsInRange(u.x, u.y, 1000, () => u.isEnemy(killer.owner) && Unit.fromEnum().owner !== Players[PLAYER_NEUTRAL_AGGRESSIVE]);
      const atLeast1EnemyNearby = g.size > 0;
      g.destroy();
      return atLeast1EnemyNearby
    }
  
    const t = new Trigger();
    t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH);
    t.addCondition(() => checkDyingUnitIsCreepAndLocalPlayerIsObserverAndEnemyIsNearby());
    t.addAction(() => showExclamationOverDyingUnit("CREEP_LAST_HIT"));
  }
  