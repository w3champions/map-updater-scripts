import { getPlayerNameWithoutNumber, getPlayerHexCode } from "../utils";
import { Players } from "w3ts/globals/index";
import { Unit, Trigger, MapPlayer, Quest, getElapsedTime } from "w3ts/index";

export function enableListOfCreepKills() {
  const q = new Quest();
  q.setTitle("Creep Kills")
  q.setDescription("No Kills yet.")
  q.setIcon("ReplaceableTextures\\CommandButtons\\BTNTomeBrown.blp")
  
  const getFormattedElapsedTime = () => {
    const elapsedTime = getElapsedTime()
    const minutes     = R2SW(R2I(elapsedTime / 60), 0, 0)
    const seconds     = R2SW(R2I(elapsedTime - 60 * R2I(elapsedTime / 60)), 0, 0)
    const m           = minutes.substr(0, minutes.length - 2)
    const s           = seconds.substr(0, seconds.length - 2)
    return `${m.length == 1 ? '0' : ''}${m}:${s.length == 1 ? '0' : ''}${s}`
    }

  // Returns TRUE if dying unit is a creep
  const checkDyingUnitIsCreep = () => {
    return Unit.fromHandle(GetDyingUnit()).owner == Players[PLAYER_NEUTRAL_AGGRESSIVE]
  }

  // Adds each creep kill to the running list
  let creepKillList: string = ""
  const addCreepKillToListAndUpdateQuest = () => {
    const dyingUnit     = Unit.fromHandle(GetDyingUnit())
    const killingUnit   = Unit.fromHandle(GetKillingUnitBJ())
    const killingPlayer = killingUnit.owner
    
    if (MapPlayer.fromLocal().isObserver())
    {
      let message = `|cff808080[${getFormattedElapsedTime()}]|r `
      if (killingUnit.owner == Players[PLAYER_NEUTRAL_AGGRESSIVE])
        message += `${killingUnit.name} |cff808080(Creep)|r |cffff6666denied|r ${dyingUnit.name}`
      else if (killingUnit.isUnitType(UNIT_TYPE_STRUCTURE))
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${getPlayerNameWithoutNumber(killingPlayer)})|r |cffff6666denied|r ${dyingUnit.name} |cff808080(Level ${dyingUnit.level})|r`
      else
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${getPlayerNameWithoutNumber(killingPlayer)})|r killed ${dyingUnit.name} |cff808080(Level ${dyingUnit.level})|r`

      creepKillList = `${message}\n${creepKillList}`
      q.setDescription(creepKillList)
    }
    else if (killingUnit.owner.isPlayerAlly(MapPlayer.fromLocal()))
    {
      let message = `|cff808080[${getFormattedElapsedTime()}]|r `
      if (killingUnit.isUnitType(UNIT_TYPE_STRUCTURE))
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${getPlayerNameWithoutNumber(killingPlayer)})|r |cffff6666denied|r ${dyingUnit.name} |cff808080(Level ${dyingUnit.level})|r`
      else
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${getPlayerNameWithoutNumber(killingPlayer)})|r killed ${dyingUnit.name} |cff808080(Level ${dyingUnit.level})|r`

      creepKillList = `${message}\n${creepKillList}`
      q.setDescription(creepKillList)      
    }
  }

  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH)
  t.addCondition(() => checkDyingUnitIsCreep())
  t.addAction(() => addCreepKillToListAndUpdateQuest())
}
