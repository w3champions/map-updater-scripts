import { getPlayerRGBCode } from "utils";
import { Trigger, Unit, Item, TextTag, MapPlayer } from "w3ts/index";

export function enableItemSoldTrigger() {
  let stackCounter: number = 0

  const t = new Trigger()
  t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_PAWN_ITEM)
  t.addAction(() => {
    const sellingUnit = Unit.fromHandle(GetSellingUnit())
    const item = Item.fromHandle(GetSoldItem())

    stackCounter = ModuloReal(stackCounter + 1, 3.00)
    const color = getPlayerRGBCode(sellingUnit.owner)
    let tag: texttag = CreateTextTagUnitBJ("Sold \"" + item.name + "\"", sellingUnit.handle, -50.00 + (-50.00 * stackCounter), 10, color.red, color.green, color.blue, 0)
    SetTextTagPermanentBJ(tag, false)
    SetTextTagVelocityBJ(tag, 30, 50.00 + (-50.00 * stackCounter))
    SetTextTagLifespanBJ(tag, 2.50)
    SetTextTagFadepointBJ(tag, 2.00)

    // Only show if the local player is an observer
    SetTextTagVisibility(tag, MapPlayer.fromLocal().isObserver())
  })
}