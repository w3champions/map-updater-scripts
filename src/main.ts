import { File, Camera, MapPlayer, getElapsedTime } from "w3ts";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";

function init() {
  enableCameraZoom();
  enableBadPing();
  enableWorkerCount();
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

function enableWorkerCount() {
  let issuedTargetOrderTrigger = CreateTrigger();
  let issuedOrder = CreateTrigger();
  let issuedPointOrder = CreateTrigger();
  let lossOfUnitTrigger = CreateTrigger();


  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    TriggerRegisterPlayerUnitEventSimple(issuedTargetOrderTrigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER);
    TriggerRegisterPlayerUnitEventSimple(issuedOrder, Player(i), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER);
    TriggerRegisterPlayerUnitEventSimple(issuedPointOrder, Player(i), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER);
    TriggerRegisterPlayerUnitEventSimple(lossOfUnitTrigger, Player(i), EVENT_PLAYER_UNIT_DEATH);
    TriggerRegisterPlayerUnitEventSimple(lossOfUnitTrigger, Player(i), EVENT_PLAYER_UNIT_CHANGE_OWNER);
  }

  TriggerAddAction(issuedTargetOrderTrigger, action_issuedTargetOrderTrigger);
  TriggerAddAction(issuedOrder, action_issuedOrder);
  TriggerAddAction(issuedPointOrder, action_issuedOrder);
  TriggerAddAction(lossOfUnitTrigger, action_lossOfUnit);
}

function action_lossOfUnit() {
  let triggerUnit = GetTriggerUnit();
  if (unitIsWorker(triggerUnit)) {
    removeWorkerFromMine(triggerUnit);
  }
}

function action_issuedOrder() {
  let triggerUnit = GetTriggerUnit();
  let orderId = GetIssuedOrderId();

  if (unitIsWorker(triggerUnit) && (!isUnitReturningGold(orderId) && !unitOrderedToGather(orderId, GetUnitName(GetOrderTargetUnit())))) {
    removeWorkerFromMine(triggerUnit);
  }
}

function unitIsWorker(whichUnit) {
  const workerIds = [FourCC('ngir'), FourCC('hpea'), FourCC('opeo'), FourCC('uaco'), FourCC('ugho'), FourCC('ewsp')];
  if (workerIds.some(x => x == GetUnitTypeId(whichUnit))) {
    return true;
  }
  return false;
}

function getTreeIds() {
  return [FourCC('ATtr'),
  FourCC('ATtc'),
  FourCC('BTtw'),
  FourCC('BTtc'),
  FourCC('CTtc'),
  FourCC('CTtr'),
  FourCC('DTsh'),
  FourCC('FTtw'),
  FourCC('GTsh'),
  FourCC('ITtc'),
  FourCC('ITtw'),
  FourCC('JTct'),
  FourCC('JTtw'),
  FourCC('KTtw'),
  FourCC('LTlt'),
  FourCC('NTtc'),
  FourCC('NTtw'),
  FourCC('OTtw'),
  FourCC('VTlt'),
  FourCC('WTst'),
  FourCC('WTtw'),
  FourCC('YTft'),
  FourCC('YTst'),
  FourCC('YTct'),
  FourCC('YTwt'),
  FourCC('ZTtc'),
  FourCC('ZTtw')
  ];
}

function getGoldIds() {
  return [FourCC('ngol'), FourCC('ugol'), FourCC('egol')];
}

function targetIsTree(target) {
  return getTreeIds().some(t => t == GetDestructableTypeId(target));
}

function targetIsGold(target) {
  return getGoldIds().some(t => t == GetUnitTypeId(target));
}

function unitCanGatherTarget(unit, target, isUnit) {
  if (!isUnit) {
    // Lumber
    if (unitIsWorker(unit) && targetIsTree(target)) {
      return true;
    }
  } else {
    // Gold
    if (unitIsWorker(unit) && targetIsGold(target)) {
      return true;
    }
  }
  return false;
}

function unitOrderedToGather(orderId, targetName) {
  return [852018, 851970].some(x => x == orderId) ||
    (orderId == 851971 && (targetName == "Gold Mine" || targetName == "Entangled Gold Mine" || targetName == "Haunted Gold Mine"));
}

function isUnitReturningGold(orderId) {
  return orderId == 852017;
}

let mines = [];
let workersMineMap = {};

function addWorkerToMine(worker, mine) {
  for (let i = 0; i < mines.length; i++) {
    if (mines[i].id == mine && workersMineMap[worker] != mine) {
      workersMineMap[worker] = mine;
      mines[i].workers += 1;
      updateMineText(mines[i]);
    }
  }
}

function updateMineText(mine) {
  let textTag = CreateTextTag();

  if (mine.textTag) {
    textTag = mine.textTag;
  }

  SetTextTagTextBJ(textTag, mine.workers + "/5", 12);
  SetTextTagPos(textTag, GetUnitX(mine.id), GetUnitY(mine.id) - 150, 0);

  if (mine.workers == 5) {
    SetTextTagColorBJ(textTag, 0, 100, 0, 10);
  } else {
    SetTextTagColorBJ(textTag, 100, 100, 30, 10);
  }
  SetTextTagVisibility(textTag, mine.workers > 0 && !IsPlayerEnemy(GetTriggerPlayer(), GetLocalPlayer()));
  // SetTextTagVisibility(textTag, true);
  mine.textTag = textTag;
}

function removeWorkerFromMine(worker) {
  let currentWorkerMine = workersMineMap[worker];
  for (let i = 0; i < mines.length; i++) {
    if (mines[i].id == currentWorkerMine) {
      workersMineMap[worker] = null;
      mines[i].workers -= 1;
      updateMineText(mines[i]);
    }
  }
}

function doesMineExist(mine) {
  for (let i = 0; i < mines.length; i++) {
    let foundMine = mines[i];
    if (foundMine.id == mine) {
      return true;
    }
  }

  return false;
}

function targetedOrder(unit, target, orderId, isUnit) {
  if (unitIsWorker(unit) && unitCanGatherTarget(unit, target, isUnit) && unitOrderedToGather(orderId, GetUnitName(target)) && isUnit) {
    if (!doesMineExist(target)) {
      mines.push({ id: target, workers: 0 });
    }

    addWorkerToMine(unit, target);
    return;
  }

  if (!isUnitReturningGold(orderId)) {
    removeWorkerFromMine(unit);
  }
}

function action_issuedTargetOrderTrigger() {
  let targetUnit = GetOrderTargetUnit();
  if (!targetUnit) {
    targetedOrder(GetTriggerUnit(), GetOrderTargetDestructable(), GetIssuedOrderId(), false);
  } else {
    targetedOrder(GetTriggerUnit(), GetOrderTargetUnit(), GetIssuedOrderId(), true);
  }
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