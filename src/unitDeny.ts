import { showMessageOverUnit } from "utils";
import { Unit, MapPlayer, Trigger, File } from "w3ts/index";
import { Players } from "w3ts/globals/index";

export function enableUnitDenyTrigger() {
  const denyToggleTrigger = new Trigger()
  let isDenyEnabled: boolean = true

  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    const fileText = File.read("w3cUnitDeny.txt")

    if (fileText)
      isDenyEnabled = (fileText == "true")

    denyToggleTrigger.registerPlayerChatEvent(MapPlayer.fromHandle(Player(i)), "-deny", true)
  }

  denyToggleTrigger.addAction(() => {
    let triggerPlayer = MapPlayer.fromEvent()
    let localPlayer = MapPlayer.fromLocal()

    // Making sure that enable/disable only if the local player is the one who called the command
    if (triggerPlayer.name != localPlayer.name)
      return

    isDenyEnabled = !isDenyEnabled
    DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `\n|cff00ff00[W3C]:|r Showing |cffffff00 !|r when a player's unit is denied is now |cffffff00 ` + (isDenyEnabled ? `ENABLED` : `DISABLED`) + `|r.`)
    File.write("w3cUnitDeny.txt", isDenyEnabled.toString())
  })

  // Returns TRUE if the unit that was killed belongs to the same player/team who killed it, or when the killer is a creep
  let checkKillerIsAllyOfDyingUnitOrKillerIsACreep = () => {
    return (Unit.fromEvent().owner.isPlayerAlly(Unit.fromHandle(GetKillingUnit()).owner) ||
      Unit.fromHandle(GetKillingUnit()).owner == Players[PLAYER_NEUTRAL_AGGRESSIVE]) &&
      Unit.fromEvent().owner != Players[PLAYER_NEUTRAL_PASSIVE] &&
      Unit.fromHandle(GetKillingUnit()).typeId != FourCC("usap") &&  // Sacrificial Pit (when an acolyte is sacrificed)
      Unit.fromHandle(GetKillingUnit()).typeId != FourCC("otot")     // Stasis Trap (when it sets itself off)
  }

  const denyTrigger = new Trigger()
  denyTrigger.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH);
  denyTrigger.addCondition(checkKillerIsAllyOfDyingUnitOrKillerIsACreep);
  denyTrigger.addAction(() => showMessageOverUnit(Unit.fromHandle(GetDyingUnit()), Unit.fromHandle(GetKillingUnit()).owner, "!", 13, isDenyEnabled))
}
