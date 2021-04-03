import { getPlayerRGBCode, getPlayerHexCode } from "utils";
import { Players } from "w3ts/globals/index";
import { Unit, Trigger, MapPlayer, Quest, Item } from "w3ts/index";

export function enableListOfCreepKills() {
  const q = new Quest();
  q.setTitle("Creep Kills")
  q.setDescription("")
  q.setIcon("ReplaceableTextures\\CommandButtons\\BTNTomeBrown.blp")
  
  const getFormattedIngameTime = () => {
    const timeOfDay = GetTimeOfDay()
    const hour      = R2SW(R2I(timeOfDay), 0, 0)
    const minute    = R2SW(R2I((timeOfDay - S2I(hour)) * 60), 0, 0)
    const h         = hour.substr(0, hour.length - 2)
    const m         = minute.substr(0, minute.length - 2)
    return `${h.length == 1 ? '0' : ''}${h}:${m.length == 1 ? '0' : ''}${m}`
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
      let message = `|cff808080[${getFormattedIngameTime()}]|r `
      if (killingUnit.owner == Players[PLAYER_NEUTRAL_AGGRESSIVE])
        message += `${killingUnit.name} |cff808080(Creep)|r |cffff6666denied|r ${dyingUnit.name} |cff808080(Creep)|r`
      else if (killingUnit.isUnitType(UNIT_TYPE_STRUCTURE))
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${killingPlayer.name})|r |cffff6666denied|r ${dyingUnit.name} |cff808080(Creep)|r`
      else
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${killingPlayer.name})|r killed ${dyingUnit.name} |cff808080(Creep)|r`

      creepKillList = `${message}\n${creepKillList}`
      q.setDescription(creepKillList)
    }
    else if (killingUnit.owner.isPlayerAlly(MapPlayer.fromLocal()))
    {
      let message = `|cff808080[${getFormattedIngameTime()}]|r `
      if (killingUnit.isUnitType(UNIT_TYPE_STRUCTURE))
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${killingPlayer.name})|r |cffff6666denied|r ${dyingUnit.name} |cff808080(Creep)|r`
      else
        message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${killingPlayer.name})|r killed ${dyingUnit.name} |cff808080(Creep)|r`

      creepKillList = `${message}\n${creepKillList}`
      q.setDescription(creepKillList)      
    }
  }

  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH)
  t.addCondition(() => checkDyingUnitIsCreep())
  t.addAction(() => addCreepKillToListAndUpdateQuest())
}
