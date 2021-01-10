import { showMessageOverUnit } from "utils";
import { Unit, Trigger } from "w3ts/index";
import { Players } from "w3ts/globals/index";

export function enableBuildingCancelTrigger() {
  // Returns TRUE when enemy units (or creeps) are nearby (e.g. range 800 = coil range)
  const checkEnemyIsNearby = () => {
    const cancellingUnit = Unit.fromHandle(GetTriggerUnit())
    const cancellingPlayer = cancellingUnit.owner

    let atLeast1EnemyNearby: boolean = false
    ForGroupBJ(GetUnitsInRangeOfLocAll(1000.00, GetUnitLoc(cancellingUnit.handle)), () => {
      if (IsUnitEnemy(GetEnumUnit(), cancellingPlayer.handle) == true)
        atLeast1EnemyNearby = true
    })

    return atLeast1EnemyNearby
  }

  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL)
  t.addCondition(() => checkEnemyIsNearby())
  t.addAction(() => showMessageOverUnit(Unit.fromHandle(GetTriggerUnit()), Players[PLAYER_NEUTRAL_AGGRESSIVE], "cancel", 8, false))
}
