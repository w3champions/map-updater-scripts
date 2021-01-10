import { showMessageOverUnit } from "utils";
import { Players } from "w3ts/globals/index";
import { Unit, Trigger } from "w3ts/index";

export function enableLastHitOnCreepTrigger() {
  // Returns TRUE if an enemy (that is not a creep) is nearby, if dying unit is a creep and if killing unit is NOT a creep
  const checkEnemyIsNearbyAndDyingUnitIsCreepAndKillerisNotCreep = () => {
    const dyingUnit = Unit.fromHandle(GetDyingUnit())
    const killingPlayer = Unit.fromHandle(GetKillingUnitBJ()).owner

    let atLeast1EnemyNearby: boolean = false
    ForGroupBJ(GetUnitsInRangeOfLocAll(1000.00, GetUnitLoc(GetDyingUnit())), () => {
      if (Unit.fromEnum().isEnemy(killingPlayer) == true && Unit.fromEnum().owner != Players[PLAYER_NEUTRAL_AGGRESSIVE])
        atLeast1EnemyNearby = true
    })

    return atLeast1EnemyNearby && dyingUnit.owner == Players[PLAYER_NEUTRAL_AGGRESSIVE] && killingPlayer != Players[PLAYER_NEUTRAL_AGGRESSIVE]
  }

  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH)
  t.addCondition(() => checkEnemyIsNearbyAndDyingUnitIsCreepAndKillerisNotCreep())
  t.addAction(() => showMessageOverUnit(Unit.fromHandle(GetDyingUnit()), Unit.fromHandle(GetKillingUnit()).owner, "!", 13, false))
}
