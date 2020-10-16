gg_trg_Melee_Initialization = nil
function InitGlobals()
end

function Unit000014_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000018_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000021_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000022_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000023_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000034_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000039_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000040_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000041_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000042_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000045_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000048_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000063_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000066_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000071_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000078_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000079_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000090_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000091_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000092_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000096_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000100_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000101_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000103_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000107_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000109_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000112_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000118_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000124_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000127_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000128_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000133_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000135_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000136_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000139_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000140_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000143_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000145_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000148_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000150_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000161_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000163_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000168_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000169_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000171_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000175_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000178_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000180_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000184_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000186_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000189_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000190_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000192_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000195_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000196_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000197_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(FourCC("rhe2"), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000210_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000215_DropItems()
    local trigWidget = nil
    local trigUnit = nil
    local itemID = 0
    local canDrop = true
    trigWidget = bj_lastDyingWidget
    if (trigWidget == nil) then
        trigUnit = GetTriggerUnit()
    end
    if (trigUnit ~= nil) then
        canDrop = not IsUnitHidden(trigUnit)
        if (canDrop and GetChangingUnit() ~= nil) then
            canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
        end
    end
    if (canDrop) then
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
        RandomDistReset()
        RandomDistAddItem(FourCC("rhe2"), 100)
        itemID = RandomDistChoose()
        if (trigUnit ~= nil) then
            UnitDropItem(trigUnit, itemID)
        else
            WidgetDropItem(trigWidget, itemID)
        end
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function CreateNeutralHostile()
    local p = Player(PLAYER_NEUTRAL_AGGRESSIVE)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -6602.1, -3951.3, 311.293, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nscb"), -118.0, 4792.4, 159.249, FourCC("nscb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 417.7, -8106.7, 72.481, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), -3159.4, -2657.9, 229.520, FourCC("nlsn"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000018_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -182.9, 7691.6, 247.513, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 207.9, 7680.5, 296.678, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrd"), 9.8, 7586.0, 274.728, FourCC("ntrd"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000215_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -2945.0, -2752.6, 227.280, FourCC("nltc"))
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 114.8, 766.6, 82.480, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000079_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -75.1, 764.6, 105.560, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000091_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgb"), -8289.4, -225.0, 358.780, FourCC("nsgb"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000039_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgb"), 8220.8, -345.6, 177.952, FourCC("nsgb"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000175_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), 3169.2, -2652.4, 313.940, FourCC("nlsn"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000136_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 3264.9, -2453.2, 316.622, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 408.0, 7606.7, 304.522, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -3236.1, 1943.0, 132.484, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -2943.0, 2205.9, 127.561, FourCC("nltc"))
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 129.7, -1243.5, 283.660, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000135_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), 9.1, 3722.6, 272.340, FourCC("njga"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000041_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 3162.7, -7139.9, 121.526, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -363.1, 7606.2, 239.330, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 203.4, -4260.3, 108.398, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -5502.6, -552.2, 13.066, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), -5284.1, -241.9, 348.811, FourCC("njga"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000145_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), 2970.8, -7141.3, 135.710, FourCC("njga"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000171_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 2722.2, -7366.6, 148.560, FourCC("nfsh"))
    IssueImmediateOrder(u, "healon")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000168_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), -3162.3, 2156.1, 129.800, FourCC("nlsn"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000096_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 286.4, 3941.1, 253.357, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -269.9, 3936.7, 290.000, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -5339.9, -470.1, 24.697, FourCC("nftr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -3184.4, -7196.5, 34.600, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 5547.4, -543.4, 190.612, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 5394.6, -503.5, 177.129, FourCC("nftr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), 8129.9, -97.6, 180.562, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000042_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -184.8, 3775.5, 287.858, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), 3168.6, 2149.3, 45.836, FourCC("nlsn"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000103_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 4476.4, -6439.2, 109.780, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000023_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -373.3, -8099.3, 107.390, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 2953.2, -2753.4, 311.699, FourCC("nltc"))
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), 2.5, -4182.5, 89.770, FourCC("njga"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000021_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), 60.3, -5275.0, 270.317, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "slowon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000071_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 222.9, -5352.9, 282.097, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 3273.9, 1947.9, 48.516, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhyd"), -7923.0, -2558.1, 53.930, FourCC("nhyd"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000100_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -1737.2, -426.6, 344.258, FourCC("nltc"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -1744.6, -223.3, 359.050, FourCC("nltc"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), 8134.5, -586.3, 180.562, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000196_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 117.9, -1403.1, 272.414, FourCC("nlpd"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 2949.3, 2196.7, 43.592, FourCC("nltc"))
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -63.1, 941.8, 90.708, FourCC("nlpd"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), 1639.0, -284.8, 179.810, FourCC("nlkl"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000163_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), -8194.4, 29.8, 1.038, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000107_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nrel"), -198.7, -8027.0, 106.743, FourCC("nrel"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhyd"), -7807.6, 2167.9, 314.202, FourCC("nhyd"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000133_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -1615.6, -132.7, 346.540, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("njgb"), -6467.1, -4171.9, 337.110, FourCC("njgb"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000101_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 6518.4, -3976.0, 227.798, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nscb"), 70.4, -5398.5, 341.196, FourCC("nscb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -115.8, -5352.9, 278.449, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2662.2, -7544.3, 143.720, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 3216.3, 6722.0, 223.342, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), -2981.1, -7120.6, 63.090, FourCC("njga"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000092_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -183.5, -4267.6, 81.698, FourCC("nfsh"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "healoff")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000127_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -274.2, -4410.0, 71.754, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -2737.1, -7275.2, 61.630, FourCC("nfsh"))
    IssueImmediateOrder(u, "healon")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000109_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 6515.9, 3480.9, 142.302, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 290.5, -4428.1, 108.398, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -6008.7, -7043.3, 87.530, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000139_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), -6132.0, -7012.6, 79.130, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "slowon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000190_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -6513.4, 3480.5, 38.040, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 6027.7, -6974.0, 86.470, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000189_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), 2963.1, 6657.8, 237.527, FourCC("njga"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000112_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), 6171.8, -6931.6, 78.070, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "slowon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000192_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 6405.6, -7054.7, 70.614, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 5368.3, -40.2, 194.664, FourCC("nftr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), 5278.7, -278.4, 183.860, FourCC("njga"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000078_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -5895.9, -7131.4, 71.678, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -6259.1, -7051.4, 67.752, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -6349.7, -7144.0, 71.678, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 2732.7, 6823.2, 250.372, FourCC("nfsh"))
    IssueImmediateOrder(u, "healon")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000063_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 5518.3, 34.7, 195.210, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nrel"), 224.3, -8032.9, 82.721, FourCC("nrel"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2674.9, -7465.2, 30.060, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2748.4, 7032.8, 214.576, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nrel"), -195.1, 7507.9, 255.500, FourCC("nrel"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -3185.3, 6740.5, 313.811, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -3273.8, -2454.6, 232.200, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("njga"), -2987.4, 6628.5, 295.810, FourCC("njga"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000169_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -2740.8, 6835.7, 322.570, FourCC("nfsh"))
    IssueImmediateOrder(u, "healon")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000143_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nhyd"), 7707.7, 2018.7, 247.850, FourCC("nhyd"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000148_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -6870.5, -4419.7, 318.591, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 1651.5, -477.7, 165.500, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2735.7, 7030.7, 317.740, FourCC("nftt"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -1603.5, -509.4, 0.320, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -6626.6, -4337.1, 331.930, FourCC("nfsh"))
    IssueImmediateOrder(u, "healoff")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000040_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 4280.2, -6541.6, 116.878, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -5908.7, 6180.8, 259.829, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 6286.2, -6972.7, 66.688, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), -1617.7, -319.1, 352.100, FourCC("nlkl"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000124_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 5951.6, -7058.9, 70.610, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhyd"), 7816.5, -2661.7, 140.290, FourCC("nhyd"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000034_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -4348.5, -6499.6, 65.760, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000178_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -5336.5, -42.5, 341.258, FourCC("nftr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -5490.4, 47.6, 350.835, FourCC("nftt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 1661.7, -97.6, 179.270, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 6081.6, 6043.7, 264.259, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000150_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), 6202.8, 6006.1, 255.860, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "slowon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000090_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 6662.8, -4378.7, 208.120, FourCC("nfsh"))
    IssueImmediateOrder(u, "healoff")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000066_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 6903.4, -4419.6, 214.137, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("njgb"), 6484.6, -4213.6, 220.880, FourCC("njgb"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000045_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 1786.2, -193.3, 187.882, FourCC("nltc"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 1774.2, -387.9, 178.004, FourCC("nltc"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "frostarmoron")
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 117.7, 937.7, 84.592, FourCC("nlpd"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), -8184.6, -485.2, 6.316, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000210_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 231.4, -8197.2, 73.722, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -63.0, -1404.4, 266.298, FourCC("nlpd"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 199.0, 3790.8, 255.100, FourCC("nfsh"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "healoff")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000022_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -252.2, 4713.2, 78.151, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), 61.0, 4724.7, 116.309, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), -91.3, 4655.1, 86.870, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "slowon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000161_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrd"), 7.8, -8119.2, 90.420, FourCC("ntrd"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000197_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -60.1, -1239.3, 260.580, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000128_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -197.4, -8183.4, 98.600, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nrel"), 233.5, 7518.5, 301.574, FourCC("nrel"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 6708.6, 4055.5, 171.205, FourCC("nftr"))
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -4633.4, 6147.9, 285.929, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000195_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -4440.4, 6181.7, 293.029, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 5973.9, 6138.2, 248.408, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), -6105.7, 6019.9, 267.280, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "slowon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000180_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -6356.2, 6104.0, 259.829, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -6232.5, 6045.5, 255.902, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 6332.0, 6037.6, 244.481, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -6563.2, 3856.4, 35.760, FourCC("nfsh"))
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000184_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -6787.9, 3976.0, 28.067, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("njgb"), -6404.1, 3673.3, 40.940, FourCC("njgb"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000186_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -6612.1, 4097.3, 55.499, FourCC("nftr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 6427.8, 6124.8, 248.408, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrr"), -5977.6, 6077.9, 275.680, FourCC("nmrr"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000140_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -4562.3, -6452.1, 72.860, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 4584.0, 6166.7, 239.360, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000048_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 4782.8, 6091.5, 246.460, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    IssueImmediateOrder(u, "Thornyshield")
    u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 6628.7, 3810.5, 151.470, FourCC("nfsh"))
    IssueImmediateOrder(u, "healoff")
    IssueImmediateOrder(u, "autodispelon")
    IssueImmediateOrder(u, "innerfireon")
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000118_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 6845.9, 3871.8, 149.339, FourCC("nftb"))
    u = BlzCreateUnitWithSkin(p, FourCC("njgb"), 6468.5, 3675.7, 156.650, FourCC("njgb"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000014_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -6693.2, -4523.2, 307.948, FourCC("nftr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 6725.5, -4526.4, 222.830, FourCC("nftr"))
end

function CreateNeutralPassiveBuildings()
    local p = Player(PLAYER_NEUTRAL_PASSIVE)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("ntav"), 0.0, -256.0, 270.000, FourCC("ntav"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("nshp"), -3328.0, -256.0, 270.000, FourCC("nshp"))
    u = BlzCreateUnitWithSkin(p, FourCC("nshp"), 3328.0, -256.0, 270.000, FourCC("nshp"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngme"), -5504.0, -256.0, 270.000, FourCC("ngme"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngme"), 5504.0, -256.0, 270.000, FourCC("ngme"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -2944.0, -7360.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 2944.0, -7360.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -2944.0, 6848.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 0.0, -4416.0, 270.000, FourCC("ngad"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 3008.0, -2496.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 9500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -3008.0, 1984.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 9500)
    u = BlzCreateUnitWithSkin(p, FourCC("nmer"), -6144.0, -7296.0, 270.000, FourCC("nmer"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg1"), -736.0, -5280.0, 270.000, FourCC("nmg1"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmer"), -6144.0, 6272.0, 270.000, FourCC("nmer"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -3008.0, -2496.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 9500)
    u = BlzCreateUnitWithSkin(p, FourCC("nmer"), 6144.0, -7232.0, 270.000, FourCC("nmer"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -6784.0, -4160.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 6784.0, -4160.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -6784.0, 3648.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 6784.0, 3584.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 0.0, 3968.0, 270.000, FourCC("ngad"))
    u = BlzCreateUnitWithSkin(p, FourCC("nshp"), 0.0, -2816.0, 270.000, FourCC("nshp"))
    u = BlzCreateUnitWithSkin(p, FourCC("nshp"), 0.0, 2240.0, 270.000, FourCC("nshp"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg1"), -416.0, -5792.0, 270.000, FourCC("nmg1"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg0"), 800.0, -5536.0, 270.000, FourCC("nmg0"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg1"), 480.0, -5792.0, 270.000, FourCC("nmg1"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 3008.0, 1984.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 9500)
    u = BlzCreateUnitWithSkin(p, FourCC("nmg1"), 352.0, 5216.0, 270.000, FourCC("nmg1"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg0"), 672.0, 4768.0, 270.000, FourCC("nmg0"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg1"), -800.0, 4704.0, 270.000, FourCC("nmg1"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg0"), -544.0, 5216.0, 270.000, FourCC("nmg0"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 2944.0, 6848.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 12500)
    u = BlzCreateUnitWithSkin(p, FourCC("nmer"), 6208.0, 6272.0, 270.000, FourCC("nmer"))
    SetUnitColor(u, ConvertPlayerColor(0))
end

function CreateNeutralPassive()
    local p = Player(PLAYER_NEUTRAL_PASSIVE)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -4117.9, -5879.2, 246.534, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), -2688.7, 5301.9, 357.338, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -2287.2, -81.7, 289.940, FourCC("nhmc"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -33.1, -2238.7, 260.150, FourCC("nhmc"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 6569.1, -741.6, 81.870, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 6555.3, 299.4, 104.978, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -6809.1, -699.4, 81.870, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -2.8, 1529.4, 333.770, FourCC("nhmc"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -408.2, 97.9, 88.157, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), 365.9, -523.0, 211.647, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -28.6, -6647.4, 63.790, FourCC("nhmc"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -94.7, 6160.3, 239.399, FourCC("nhmc"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -2998.9, -227.9, 180.430, FourCC("nhmc"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), 3010.2, -232.1, 133.280, FourCC("nhmc"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 3972.0, -5702.3, 77.240, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 4112.5, 5363.8, 51.130, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -4142.4, 5485.4, 351.200, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -6822.9, 341.6, 104.978, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -7694.1, -2362.1, 25.800, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 7463.4, -2519.9, 337.750, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 7332.2, 1966.4, 97.960, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -7529.4, 2043.2, 170.710, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), -3746.0, -3367.8, 283.570, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), 3604.0, -3157.4, 0.140, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), 3748.9, 2801.5, 311.529, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), 5752.6, -6118.0, 119.820, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), 5901.6, 5282.8, 40.190, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), -5827.7, 5369.5, 78.530, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ncrb"), -5959.4, -6167.1, 85.810, FourCC("ncrb"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 1744.9, 3850.3, 51.130, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 1774.8, -4114.2, 51.130, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -1583.5, -4193.1, 51.130, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -1835.3, 3736.5, 51.130, FourCC("nfro"))
    SetUnitAcquireRange(u, 200.0)
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
end

function CreateAllUnits()
    CreateNeutralPassiveBuildings()
    CreatePlayerBuildings()
    CreateNeutralHostile()
    CreateNeutralPassive()
    CreatePlayerUnits()
end

function Trig_Melee_Initialization_Actions()
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
end

function InitTrig_Melee_Initialization()
    gg_trg_Melee_Initialization = CreateTrigger()
    TriggerAddAction(gg_trg_Melee_Initialization, Trig_Melee_Initialization_Actions)
end

function InitCustomTriggers()
    InitTrig_Melee_Initialization()
end

function RunInitializationTriggers()
    ConditionalTriggerExecute(gg_trg_Melee_Initialization)
end

function InitCustomPlayerSlots()
    SetPlayerStartLocation(Player(0), 0)
    SetPlayerColor(Player(0), ConvertPlayerColor(0))
    SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(0), true)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(1), 1)
    SetPlayerColor(Player(1), ConvertPlayerColor(1))
    SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
    SetPlayerRaceSelectable(Player(1), true)
    SetPlayerController(Player(1), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(2), 2)
    SetPlayerColor(Player(2), ConvertPlayerColor(2))
    SetPlayerRacePreference(Player(2), RACE_PREF_UNDEAD)
    SetPlayerRaceSelectable(Player(2), true)
    SetPlayerController(Player(2), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(3), 3)
    SetPlayerColor(Player(3), ConvertPlayerColor(3))
    SetPlayerRacePreference(Player(3), RACE_PREF_NIGHTELF)
    SetPlayerRaceSelectable(Player(3), true)
    SetPlayerController(Player(3), MAP_CONTROL_USER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
    SetPlayerTeam(Player(1), 0)
    SetPlayerTeam(Player(2), 0)
    SetPlayerTeam(Player(3), 0)
end

function InitAllyPriorities()
    SetStartLocPrioCount(0, 1)
    SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(1, 1)
    SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(2, 1)
    SetStartLocPrio(2, 0, 3, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(3, 1)
    SetStartLocPrio(3, 0, 2, MAP_LOC_PRIO_HIGH)
end

function main()
    SetCameraBounds(-9472.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -9216.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 9472.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 8704.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -9472.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 8704.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 9472.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -9216.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    NewSoundEnvironment("lake")
    SetAmbientDaySound("SunkenRuinsDay")
    SetAmbientNightSound("SunkenRuinsNight")
    SetMapMusic("Music", true, 0)
    CreateAllUnits()
    InitBlizzard()
    InitGlobals()
    InitCustomTriggers()
    RunInitializationTriggers()
end

function config()
    SetMapName("TRIGSTR_001")
    SetMapDescription("TRIGSTR_003")
    SetPlayers(4)
    SetTeams(4)
    SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
    DefineStartLocation(0, -6144.0, 4096.0)
    DefineStartLocation(1, -6144.0, -4608.0)
    DefineStartLocation(2, 6144.0, 4096.0)
    DefineStartLocation(3, 6144.0, -4608.0)
    InitCustomPlayerSlots()
    SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(2), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(3), MAP_CONTROL_USER)
    InitGenericPlayerSlots()
    InitAllyPriorities()
end

