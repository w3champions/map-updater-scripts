import { getPlayerRGBCode } from "utils";
import { Trigger, Unit, Item, TextTag, MapPlayer } from "w3ts/index";

export function enableItemSoldTrigger() {
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