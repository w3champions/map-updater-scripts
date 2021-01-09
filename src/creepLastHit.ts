import { showExclamationOverDyingUnit } from "unitDeny";
import { Players } from "w3ts/globals/index";
import { Unit, Trigger } from "w3ts/index";

export function enableCreepLastHitTrigger() {
  const checkDyingUnitIsCreepAndEnemyIsNearby = () => {
    const dyingUnit = Unit.fromHandle(GetDyingUnit())
    const killingPlayer = Unit.fromHandle(GetKillingUnitBJ()).owner

    // Returns FALSE if dying unit is NOT a creep, or when killing unit is a creep
    if (dyingUnit.owner != Players[PLAYER_NEUTRAL_AGGRESSIVE] || killingPlayer == Players[PLAYER_NEUTRAL_AGGRESSIVE]) {
      return false
    }

    // Returns FALSE when no enemy units are nearby (e.g. range 800 = coil range)
    let atLeast1EnemyNearby: boolean = false
    ForGroupBJ(GetUnitsInRangeOfLocAll(1000.00, GetUnitLoc(GetDyingUnit())), () => {
      if (IsUnitEnemy(GetEnumUnit(), killingPlayer.handle) == true && GetOwningPlayer(GetEnumUnit()) != Player(PLAYER_NEUTRAL_AGGRESSIVE))
        atLeast1EnemyNearby = true
    })

    return atLeast1EnemyNearby
  }

  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH)
  t.addCondition(() => checkDyingUnitIsCreepAndEnemyIsNearby())
  t.addAction(() => showExclamationOverDyingUnit(true, "CREEP_LAST_HIT"))
}
