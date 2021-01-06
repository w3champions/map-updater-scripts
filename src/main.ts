import { Players } from "w3ts/globals";
import { Camera, Group, Item, MapPlayer, TextTag, Trigger, Unit } from "w3ts/handles";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";
import { File } from "w3ts/system/file";
import { getElapsedTime } from "w3ts/system/gametime";
import { playerColors } from "w3ts/utils/color";

function init() {
  enableCameraZoom();
  enableBadPing();
  enableUnitDenyTrigger();
  enableCreepLastHitTrigger();
  enableItemSoldTrigger();
}

function enableBadPing() {
  const t = new Trigger();
  const players = [];
  let playerCount = 0;
  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
      playerCount++;
      t.registerPlayerChatEvent(Players[i], "-badping", false);
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

  t.addAction(() => {
    const triggerPlayer = MapPlayer.fromEvent();

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
  const t = new Trigger();

  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    const isLocalPlayer = MapPlayer.fromHandle(Player(i)).name == MapPlayer.fromLocal().name;

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
        setCameraZoom(Number(fileText), MapPlayer.fromLocal());
      } else {
        print("\n");
        print("|cff00ff00[W3C] Tip:|r Type|cffffff00 -zoom <VALUE>|r to change your zoom level. Default: 1650 \n Minimum zoom: 1650 | Maximum zoom: 3000");
      }
    }
    t.registerPlayerChatEvent(Players[i], "-zoom", false);
  }

  t.addAction(() => {
    const triggerPlayer = MapPlayer.fromEvent();
    const localPlayer = MapPlayer.fromLocal();

    // Making sure that we only set our zoom level only if the local player is the one who called the command
    if (triggerPlayer.name != localPlayer.name) {
      return;
    }

    const zoomLevel = GetEventPlayerChatString().split('-zoom')[1].trim();
    const zoomNumber: number = Number(zoomLevel);
    setCameraZoom(zoomNumber, triggerPlayer);
    File.write("w3cZoomFFA.txt", zoomNumber.toString());
  })
}

function setCameraZoom(zoomLevel: number, player: MapPlayer) {
  const maxZoom = 3000;
  const minZoom = 1650;

  if (zoomLevel > maxZoom) {
    zoomLevel = maxZoom;
  } else if (zoomLevel < minZoom) {
    zoomLevel = minZoom;
  }

  if (player == MapPlayer.fromLocal()) {
    DisplayTextToPlayer(player.handle, 0, 0, `|cff00ff00[W3C]:|r Zoom is set to|cffffff00 ${zoomLevel}|r.`);
    Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, zoomLevel, 0.0);
  }
}

function getPlayerRGBCode(whichPlayer: MapPlayer) {
  return playerColors[GetHandleId(whichPlayer.color)];
}

function showExclamationOverDyingUnit(type: string) {
  const u = Unit.fromEvent();
  const p = Unit.fromHandle(GetKillingUnit());
  const lp = MapPlayer.fromLocal();
  const color = getPlayerRGBCode(p.owner)
  const tt = new TextTag();
  tt.setText("!", 12, true);
  tt.setPosUnit(u, -50.00);
  tt.setColor(color.red, color.green, color.blue, 0);
  tt.setPermanent(false);
  tt.setLifespan(2.00);
  tt.setFadepoint(1.50);

  if (type == "UNIT_DENY") {
    // Only show if the player actually has vision of the dying unit (or if player is observer);
    // that way players won't see denies in fog of war
    const flag = (!u.isVisible(lp) && !u.isFogged(lp) && u.isMasked(lp) || lp.isObserver())
    tt.setVisible(flag);
  }
  else if (type == "CREEP_LAST_HIT") {
    // Only show if the player is an observer
    tt.setVisible(lp.isObserver());
  }
}

function enableUnitDenyTrigger() {
  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH);
  t.addCondition(() => Unit.fromEvent().owner === Unit.fromHandle(GetKillingUnit()).owner); // Returns TRUE if the unit that was killed belongs to the same player who killed it
  t.addAction(() => showExclamationOverDyingUnit("UNIT_DENY"));
}

function enableCreepLastHitTrigger() {
  const checkDyingUnitIsCreepAndLocalPlayerIsObserverAndEnemyIsNearby = () => {
    const u = Unit.fromEvent();
    const killer = Unit.fromHandle(GetKillingUnit());

    // Returns FALSE if dying unit is NOT a creep
    if (u.owner != Players[PLAYER_NEUTRAL_AGGRESSIVE]) {
      return false;
    }

    // Returns FALSE when no enemy units are nearby (e.g. range 800 = coil range)
    const g = new Group();
    g.enumUnitsInRange(u.x, u.y, 1000, () => u.isEnemy(killer.owner) && Unit.fromEnum().owner !== Players[PLAYER_NEUTRAL_AGGRESSIVE]);
    const atLeast1EnemyNearby = g.size > 0;
    g.destroy();
    return atLeast1EnemyNearby
  }

  const t = new Trigger();
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_DEATH);
  t.addCondition(() => checkDyingUnitIsCreepAndLocalPlayerIsObserverAndEnemyIsNearby());
  t.addAction(() => showExclamationOverDyingUnit("CREEP_LAST_HIT"));
}

function enableItemSoldTrigger() {
  let stackCounter: number = 0

  const t = new Trigger();
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_PAWN_ITEM);
  t.addAction(() => {
    const u = Unit.fromHandle(GetSellingUnit());
    const itm = Item.fromHandle(GetSoldItem());

    stackCounter = ModuloReal(stackCounter + 1, 3.00);
    const color = getPlayerRGBCode(u.owner);
    const tt = new TextTag();
    tt.setText(`Sold "${itm.name}"`, 10, true);
    tt.setPosUnit(u, (-50.00 + (-50.00 * stackCounter)));
    tt.setColor(color.red, color.green, color.blue, 0);
    tt.setPermanent(false);
    tt.setVelocityAngle(30, (50.00 + (-50.00 * stackCounter)));
    tt.setLifespan(2.00);
    tt.setFadepoint(1.50);

    // Only show if the local player is an observer
    tt.setVisible(MapPlayer.fromLocal().isObserver());
  })
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, init);
