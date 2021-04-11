import { getPlayerRGBCode } from "utils";
import { Trigger, Unit, Item, TextTag, MapPlayer } from "w3ts/index";

export function enableItemSoldBoughtTrigger() {
  let stackCounter: number = 0

  const showMessage = (prefix: string, unit: Unit) => {
    stackCounter = ModuloReal(stackCounter + 1, 3.00)
    const item = Item.fromHandle(GetSoldItem())
    const color = getPlayerRGBCode(unit.owner)
    let tag: texttag = CreateTextTagUnitBJ(prefix + " \"" + item.name + "\"", unit.handle, -50.00 + (-50.00 * stackCounter), 10, color[0], color[1], color[2], 0)
    SetTextTagPermanentBJ(tag, false)
    SetTextTagVelocityBJ(tag, 30, 50.00 + (-50.00 * stackCounter))
    SetTextTagLifespanBJ(tag, 2.50)
    SetTextTagFadepointBJ(tag, 2.00)

    // Only show if the local player is an observer
    SetTextTagVisibility(tag, MapPlayer.fromLocal().isObserver())
  }

  const sellTrigger = new Trigger()
  sellTrigger.registerAnyUnitEvent(EVENT_PLAYER_UNIT_PAWN_ITEM)
  sellTrigger.addAction(() => { showMessage("Sold", Unit.fromHandle(GetSellingUnit())) })

  const buyTrigger = new Trigger()
  buyTrigger.registerAnyUnitEvent(EVENT_PLAYER_UNIT_SELL_ITEM)  // Not sure why it is the 'SELL_ITEM' event, but it corresponds to 'buying item from shop'
  buyTrigger.addAction(() => { showMessage("Bought", Unit.fromHandle(GetBuyingUnit())) })
}