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

  const createCreepKillMessage = () => {
    const dyingUnit     = Unit.fromHandle(GetDyingUnit())
    const killingUnit   = Unit.fromHandle(GetKillingUnitBJ())
    const killingPlayer = killingUnit.owner

    if (!MapPlayer.fromLocal().isObserver() && !killingUnit.owner.isPlayerAlly(MapPlayer.fromLocal()))
    {
      return null;
    }
    let message = `|cff808080[${getFormattedElapsedTime()}]|r `
    if (MapPlayer.fromLocal().isObserver() && killingUnit.owner == Players[PLAYER_NEUTRAL_AGGRESSIVE])
    {
      message += `${killingUnit.name} |cff808080(Creep)|r |cffff6666denied|r ${dyingUnit.name}`
    }
    else if (killingUnit.isUnitType(UNIT_TYPE_STRUCTURE))
    {
      message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${getPlayerNameWithoutNumber(killingPlayer)})|r |cffff6666denied|r ${dyingUnit.name} |cff808080(Level ${dyingUnit.level})|r`
    }
    else
    {
      message += `${killingUnit.name} |${getPlayerHexCode(killingPlayer)}(${getPlayerNameWithoutNumber(killingPlayer)})|r killed ${dyingUnit.name} |cff808080(Level ${dyingUnit.level})|r`
    }
    return message
  }

  // Adds each creep kill to the running list, limiting the list to 4096 characters
  let creepKillList: string = ""
  const addCreepKillToListAndUpdateQuest = () => {
    const message = createCreepKillMessage()
    if (message != null)
    {
      creepKillList = `${message}\n${creepKillList}`
      if (creepKillList.length > 4096)
      {
        const lastIndexOfNewLine = getLastIndexOf(creepKillList, "\n");
        creepKillList = creepKillList.substring(0, lastIndexOfNewLine);
      }

      q.setDescription(creepKillList)
    }
  }

  const getLastIndexOf = (str: string, c: string): number => {
    for (let i = str.length - 1; i >= 0; i--) {
      if (str[i] === c) {
        return i;
      }
    }
    return 0;
  };

  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH)
  t.addCondition(() => checkDyingUnitIsCreep())
  t.addAction(() => addCreepKillToListAndUpdateQuest())
}
