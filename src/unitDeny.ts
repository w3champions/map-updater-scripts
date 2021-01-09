import { getPlayerRGBCode } from "utils";
import { Unit, MapPlayer, Trigger, File } from "w3ts/index";
import { Players } from "w3ts/globals/index";

export function enableUnitDenyTrigger() {
  const denyToggleTrigger = new Trigger()
  let isDenyEnabled: boolean = true

  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    // If the player is not an observer, then read settings from file
    if (!MapPlayer.fromHandle(Player(i)).isObserver()) {
      const fileText = File.read("w3cUnitDeny.txt")

      if (fileText)
        isDenyEnabled = (fileText == "true")
    }

    denyToggleTrigger.registerPlayerChatEvent(MapPlayer.fromHandle(Player(i)), "-deny", true)
  }

  denyToggleTrigger.addAction(() => {
    let triggerPlayer = MapPlayer.fromEvent()
    let localPlayer = MapPlayer.fromLocal()

    // Making sure that enable/disable only if the local player is the one who called the command
    if (triggerPlayer.name != localPlayer.name) {
      return;
    }

    isDenyEnabled = !isDenyEnabled
    DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `\n|cff00ff00[W3C]:|r Showing |cffffff00 !|r when a player's unit is denied is now |cffffff00 ` + (isDenyEnabled ? `ENABLED` : `DISABLED`) + `|r.`);
    File.write("w3cUnitDeny.txt", isDenyEnabled.toString())
  })

  // Returns TRUE if the unit that was killed belongs to the same player/team who killed it, or when the killer is a creep
  let checkKillerIsAllyOfDyingUnitOrKillerIsACreep = () => {
    return Unit.fromEvent().owner.isPlayerAlly(Unit.fromHandle(GetKillingUnit()).owner) ||
      Unit.fromHandle(GetKillingUnit()).owner == Players[PLAYER_NEUTRAL_AGGRESSIVE]
  }

  const denyTrigger = new Trigger()
  denyTrigger.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH);
  denyTrigger.addCondition(checkKillerIsAllyOfDyingUnitOrKillerIsACreep);
  denyTrigger.addAction(() => showExclamationOverDyingUnit(isDenyEnabled, "UNIT_DENY"));
}

export function showExclamationOverDyingUnit(isDenyEnabled: boolean, type: string) {
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
    SetTextTagVisibility(tag, (isDenyEnabled && dyingUnit.isVisible(localPlayer) && !dyingUnit.isFogged(localPlayer) && !dyingUnit.isMasked(localPlayer)) || localPlayer.isObserver());
  }
  else if (type == "CREEP_LAST_HIT") {
    // Only show if the player is an observer
    SetTextTagVisibility(tag, localPlayer.isObserver());
  }
}
