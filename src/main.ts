import { MapPlayer } from "w3ts/handles/player";
import { Camera } from "w3ts/handles/camera";
import { getElapsedTime } from "w3ts/system/gametime";
import { File } from "w3ts/system/file";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";

function init() {
  enableCameraZoom();
  enableBadPing();
  enableUnitDenyTrigger();
  enableCreepLastHitTrigger();
  enableItemSoldTrigger();
}

function enableBadPing() {
  let badPingTrigger = CreateTrigger();
  let players = [];
  let playerCount = 0;
  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
      playerCount++;
      TriggerRegisterPlayerChatEvent(badPingTrigger, Player(i), "-badping", false);
      DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To cancel this game due to bad ping, all players must use|cffffff00 -badping|r.\nThis command expires in 2 minutes.`);
    }
  }

  let requiredPlayers = playerCount;

  if (playerCount == 4) {
    requiredPlayers = 3;
  }
  else if (playerCount == 8) {
    requiredPlayers = 6;
  }

  TriggerAddAction(badPingTrigger, () => {
    let triggerPlayer = MapPlayer.fromEvent();

    if (getElapsedTime() > 120) {
      DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `|cff00ff00[W3C]:|r The|cffffff00 -badping|r command is disabled after two minutes of gameplay.`);
      return;
    }

    if (players.indexOf(triggerPlayer.name) == -1) {
      players.push(triggerPlayer.name);
      let remainingPlayers = requiredPlayers - players.length;

      if (players.length == 1) {
        print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r is proposing to cancel this game. \nType|cffffff00 -badping|r to cancel the game. ${remainingPlayers} player(s) remaining.`);
      } else if (players.length < requiredPlayers) {
        print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r votes to cancel this game. ${remainingPlayers} player(s) remaining.`);
      }
    }

    if (players.length == requiredPlayers) {
      for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_NEUTRAL, false);
      }
    }
  });
}

function enableCameraZoom() {
  let zoomTrigger = CreateTrigger();

  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    let isLocalPlayer = MapPlayer.fromHandle(Player(i)).name == MapPlayer.fromLocal().name;

    // If the player is an observer, we will set a static zoom level.
    // As of right now, observer chat events are not picked up by the ChatEvent hook from above.
    /*** DESYNC ISSUES CURRENTLY WITH OBSERVERS ***/
    // if (isLocalPlayer && IsPlayerObserver(Player(i))) {
    //   setCameraZoom(1950, Player(i));
    //   return;
    // }

    // Else if the player is not an observer, then read from the file.
    if (isLocalPlayer) {
      const fileText = File.read("w3cZoomFFA.txt");

      if (fileText && Number(fileText) > 0) {
        setCameraZoom(Number(fileText), MapPlayer.fromLocal().handle);
      } else {
        print("\n");
        print("|cff00ff00[W3C] Tip:|r Type|cffffff00 -zoom <VALUE>|r to change your zoom level. Default: 1650 \n Minimum zoom: 1650 | Maximum zoom: 3000");
      }
    }
    TriggerRegisterPlayerChatEvent(zoomTrigger, Player(i), "-zoom", false);
  }

  TriggerAddAction(zoomTrigger, () => {
    let triggerPlayer = MapPlayer.fromEvent();
    let localPlayer = MapPlayer.fromLocal();;

    // Making sure that we only set our zoom level only if the local player is the one who called the command
    if (triggerPlayer.name != localPlayer.name) {
      return;
    }

    let zoomLevel = GetEventPlayerChatString().split('-zoom')[1].trim();
    let zoomNumber: number = Number(zoomLevel);
    setCameraZoom(zoomNumber, triggerPlayer.handle);
    File.write("w3cZoomFFA.txt", zoomNumber.toString());
  });
}

function setCameraZoom(zoomLevel: number, player: player) {
  const maxZoom = 3000;
  const minZoom = 1650;

  if (zoomLevel > maxZoom) {
    zoomLevel = maxZoom;
  } else if (zoomLevel < minZoom) {
    zoomLevel = minZoom;
  }

  if (player == MapPlayer.fromLocal().handle) {
    DisplayTextToPlayer(player, 0, 0, `|cff00ff00[W3C]:|r Zoom is set to|cffffff00 ${zoomLevel}|r.`);
    Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, zoomLevel, 0.0);
  }
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, init);

function getPlayerRGBCode(whichPlayer: player) {
  if      (GetPlayerColor(whichPlayer) == PLAYER_COLOR_RED)        return [100.00, 1.18, 1.18]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_BLUE)       return [0.00, 25.88, 100.00]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_CYAN)       return [10.59, 90.59, 72.94]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_PURPLE)     return [33.33, 0.00, 50.59]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_YELLOW)     return [99.61, 98.82, 0.00]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_ORANGE)     return [99.61, 53.73, 5.10]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_GREEN)      return [12.94, 74.90, 0.00]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_PINK)       return [89.41, 36.08, 68.63]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_LIGHT_GRAY) return [57.65, 58.43, 58.82]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_LIGHT_BLUE) return [49.41, 74.90, 94.51]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_AQUA)       return [6.27, 38.43, 27.84]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_BROWN)      return [30.98, 16.86, 1.96]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_MAROON)     return [61.18, 0.00, 0.00]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_NAVY)       return [0.00, 0.00, 76.47]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_TURQUOISE)  return [0.00, 92.16, 100.00]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_VIOLET)     return [74.12, 0.00, 100.00]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_WHEAT)      return [92.55, 80.78, 52.94]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_PEACH)      return [96.86, 64.71, 54.51]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_MINT)       return [74.90, 100.00, 50.59]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_LAVENDER)   return [85.88, 72.16, 92.16]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_COAL)       return [30.98, 31.37, 33.33]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_SNOW)       return [92.55, 94.12, 100.00]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_EMERALD)    return [0.00, 47.06, 11.76]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_PEANUT)     return [64.71, 43.53, 20.39]
  else                                                             return [18.04, 17.65, 18.04]
}

function showExclamationOverDyingUnit(type: string) {
  let col: number[] = getPlayerRGBCode(GetOwningPlayer(GetKillingUnitBJ()))
  let tag: texttag  = CreateTextTagUnitBJ("!", GetDyingUnit(), -50.00, 12, col[0], col[1], col[2], 0)
  SetTextTagPermanentBJ(tag, false)
  SetTextTagLifespanBJ(tag, 2.00)
  SetTextTagFadepointBJ(tag, 1.50)

  if (type == "UNIT_DENY") {
    // Only show if the player actually has vision of the dying unit (or if player is observer);
    // that way players won't see denies in fog of war
    SetTextTagVisibility(tag, (IsUnitInvisible(GetDyingUnit(), GetLocalPlayer()) == false &&
                               IsUnitFogged   (GetDyingUnit(), GetLocalPlayer()) == false &&
                               IsUnitMasked   (GetDyingUnit(), GetLocalPlayer()) == false) ||
                              GetPlayerState(GetLocalPlayer(), PLAYER_STATE_OBSERVER) == 1)
  }
  else if (type == "CREEP_LAST_HIT") {
    // Only show if the player is an observer
    SetTextTagVisibility(tag, GetPlayerState(GetLocalPlayer(), PLAYER_STATE_OBSERVER) == 1)
  }
}

function enableUnitDenyTrigger() {
  // Returns TRUE if the unit that was killed belongs to the same player who killed it
  let checkDyingUnitBelongsToKiller = () => { return GetOwningPlayer(GetDyingUnit()) == GetOwningPlayer(GetKillingUnitBJ()) }

  let unitDenyTrigger: trigger = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(unitDenyTrigger, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddCondition(unitDenyTrigger, Condition(checkDyingUnitBelongsToKiller))
  TriggerAddAction(unitDenyTrigger, () => showExclamationOverDyingUnit("UNIT_DENY"))
}

function enableCreepLastHitTrigger() {
  let checkDyingUnitIsCreepAndLocalPlayerIsObserverAndEnemyIsNearby = () => {
    // Returns FALSE if dying unit is NOT a creep
    if (GetOwningPlayer(GetDyingUnit()) != Player(PLAYER_NEUTRAL_AGGRESSIVE))
      return false

    // Returns FALSE when no enemy units are nearby (e.g. range 800 = coil range)
    let atLeast1EnemyNearby: boolean = false
    ForGroupBJ(GetUnitsInRangeOfLocAll(1000.00, GetUnitLoc(GetDyingUnit())), () => {
      if (IsUnitEnemy(GetEnumUnit(), GetOwningPlayer(GetKillingUnitBJ())) == true && GetOwningPlayer(GetEnumUnit()) != Player(PLAYER_NEUTRAL_AGGRESSIVE))
        atLeast1EnemyNearby = true
    })
    return atLeast1EnemyNearby
  }

  let creepLastHitTriger: trigger = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(creepLastHitTriger, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddCondition(creepLastHitTriger, Condition(checkDyingUnitIsCreepAndLocalPlayerIsObserverAndEnemyIsNearby))
  TriggerAddAction(creepLastHitTriger, () => showExclamationOverDyingUnit("CREEP_LAST_HIT"))
}

function enableItemSoldTrigger() {
  let stackCounter: number = 0
  let itemSoldTrigger: trigger = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(itemSoldTrigger, EVENT_PLAYER_UNIT_PAWN_ITEM)
  
  TriggerAddAction(itemSoldTrigger, () => {
    stackCounter = ModuloReal(stackCounter + 1, 3.00)
    let col: number[] = getPlayerRGBCode(GetOwningPlayer(GetSellingUnit()))
    let tag: texttag = CreateTextTagUnitBJ("Sold \"" + GetItemName(GetSoldItem()) + "\"", GetSellingUnit(), (-50.00 + (-50.00 * stackCounter)), 10, col[0], col[1], col[2], 0)
    SetTextTagPermanentBJ(tag, false)
    SetTextTagVelocityBJ(tag, 30, (50.00 + (-50.00 * stackCounter)))
    SetTextTagLifespanBJ(tag, 2.00)
    SetTextTagFadepointBJ(tag, 1.50)

    // Only show if the local player is an observer
    SetTextTagVisibility(tag, GetPlayerState(GetLocalPlayer(), PLAYER_STATE_OBSERVER) == 1)
  })
}