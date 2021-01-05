import { MapPlayer } from "w3ts/handles/player";
import { Camera } from "w3ts/handles/camera";
import { getElapsedTime } from "w3ts/system/gametime";
import { File } from "w3ts/system/file";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";

function init() {
  enableCameraZoom();
  enableBadPing();
  enableUnitDeny();
  enableCreepLastHit();
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
  if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_RED)
    return [100, 1.17, 1.17]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_BLUE)
    return [0, 25.88, 100]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_CYAN)  // TEAL
    return [10.98, 90.20, 72.55]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_PURPLE)
    return [31.37, 0, 50.59]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_YELLOW)
    return [100, 100, 0.39]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_ORANGE)
    return [99.6, 54.12, 5.49]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_GREEN)
    return [12.55, 75.30, 0]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_PINK)
    return [89.80, 35.69, 69.02]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_LIGHT_GRAY)
    return [58.43, 58.82, 59.22]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_LIGHT_BLUE)
    return [49.41, 74.9, 94.51]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_EMERALD)  // DARK GREEN
    return [6.27, 38.43, 27.45]
  else if (GetPlayerColor(whichPlayer) == PLAYER_COLOR_BROWN)
    return [29.02, 16, 47, 1.57]
  else
    return [10, 10, 10]

  // TODO: Add all remaining colours
}

function enableUnitDeny() {
  let unitDenyTrigger: trigger = CreateTrigger()

  // Check that the unit that was killed belongs to the same player who killed it
  let checkDyingUnitBelongsToKiller = () => { return GetOwningPlayer(GetDyingUnit()) == GetOwningPlayer(GetKillingUnitBJ()) }

  TriggerRegisterAnyUnitEventBJ(unitDenyTrigger, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddCondition(unitDenyTrigger, Condition(checkDyingUnitBelongsToKiller))
  TriggerAddAction(unitDenyTrigger, showExclamationMarkIfVisibleEnemyIsNearby)
}

function enableCreepLastHit() {
  let creepLastHitTriger: trigger = CreateTrigger()

  // Check that the unit that was killed is a creep & local player is just an observer
  let checkDyingUnitBelongsToCreepsAndLocalPlayerIsObserver = () => {
    return GetOwningPlayer(GetDyingUnit()) == Player(PLAYER_NEUTRAL_AGGRESSIVE) &&
           GetPlayerState(GetLocalPlayer(), PLAYER_STATE_OBSERVER) == 1
  }

  TriggerRegisterAnyUnitEventBJ(creepLastHitTriger, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddCondition(creepLastHitTriger, Condition(checkDyingUnitBelongsToCreepsAndLocalPlayerIsObserver))
  TriggerAddAction(creepLastHitTriger, showExclamationMarkIfVisibleEnemyIsNearby)
}

function showExclamationMarkIfVisibleEnemyIsNearby() {
  let killingPlayer: player = GetOwningPlayer(GetKillingUnitBJ())
  let col: number[] = getPlayerRGBCode(killingPlayer)

  // Detect enemy units nearby (range 800 = coil range)
  let atLeast1EnemyNearby: boolean = false
  ForGroupBJ(GetUnitsInRangeOfLocAll(800.00, GetUnitLoc(GetDyingUnit())), () => {
    if (IsUnitEnemy(GetEnumUnit(), killingPlayer) == true &&
      IsUnitInvisible(GetEnumUnit(), killingPlayer) == false &&
      IsUnitFogged(GetEnumUnit(), killingPlayer) == false &&
      IsUnitMasked(GetEnumUnit(), killingPlayer) == false &&
      (GetOwningPlayer(GetEnumUnit()) != Player(PLAYER_NEUTRAL_AGGRESSIVE))
    ) atLeast1EnemyNearby = true
  })

  // Only show text if an enemy unit is nearby
  if (atLeast1EnemyNearby) {
    let tag: texttag = CreateTextTagUnitBJ("!", GetDyingUnit(), -50.00, 10, col[0], col[1], col[2], 0)
    SetTextTagPermanentBJ(tag, false)
    SetTextTagLifespanBJ(tag, 2.00)
    SetTextTagFadepointBJ(tag, 1.50)
  }
}