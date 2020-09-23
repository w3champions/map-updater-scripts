gg_trg_Melee_Initialization = nil
function InitGlobals()
end

function Unit000007_DropItems()
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

function Unit000016_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000049_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000073_DropItems()
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

function Unit000082_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000083_DropItems()
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

function Unit000088_DropItems()
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

function Unit000097_DropItems()
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

function Unit000099_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
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

function Unit000111_DropItems()
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

function Unit000115_DropItems()
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

function Unit000117_DropItems()
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

function Unit000120_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000121_DropItems()
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

function Unit000123_DropItems()
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

function Unit000126_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000132_DropItems()
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

function Unit000134_DropItems()
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

function Unit000141_DropItems()
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

function Unit000147_DropItems()
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

function Unit000151_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000152_DropItems()
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

function Unit000157_DropItems()
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

function Unit000159_DropItems()
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

function Unit000166_DropItems()
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

function Unit000172_DropItems()
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

function Unit000173_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000174_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000182_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000183_DropItems()
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

function Unit000185_DropItems()
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

function Unit000199_DropItems()
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

function Unit000200_DropItems()
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

function Unit000201_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000203_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000204_DropItems()
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

function Unit000208_DropItems()
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

function Unit000209_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000211_DropItems()
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

function Unit000212_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000213_DropItems()
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

function Unit000216_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000218_DropItems()
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

function Unit000220_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000221_DropItems()
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

function Unit000224_DropItems()
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

function Unit000225_DropItems()
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

function Unit000228_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000231_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000238_DropItems()
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

function Unit000239_DropItems()
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

function Unit000240_DropItems()
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

function Unit000244_DropItems()
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

function Unit000247_DropItems()
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

function Unit000251_DropItems()
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

function Unit000254_DropItems()
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

function Unit000255_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000256_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000257_DropItems()
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

function Unit000259_DropItems()
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

function Unit000262_DropItems()
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

function Unit000267_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000276_DropItems()
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

function Unit000277_DropItems()
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

function Unit000286_DropItems()
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

function Unit000288_DropItems()
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

function Unit000290_DropItems()
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
        RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
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

function Unit000292_DropItems()
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

function Unit000293_DropItems()
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

function Unit000294_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000308_DropItems()
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

function Unit000309_DropItems()
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

function Unit000310_DropItems()
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

function Unit000311_DropItems()
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
    end
    bj_lastDyingWidget = nil
    DestroyTrigger(GetTriggeringTrigger())
end

function Unit000312_DropItems()
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
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -1952.4, -9870.5, 121.706, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 4822.8, 2011.3, 315.745, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000091_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 4968.0, 2123.4, 299.484, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), 3356.0, 2394.5, 233.369, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000103_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), 3529.9, 2239.8, 195.873, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000100_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), 3796.8, 2106.9, 164.583, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 6559.5, 63.1, 176.089, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000212_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 6534.3, -353.9, 173.470, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000211_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 6529.3, -548.0, 141.419, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -2279.4, -9981.2, 93.094, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), -2126.1, -9914.9, 89.860, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000267_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 9425.7, 5849.8, 210.310, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 9722.2, -2464.3, 181.699, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 9619.5, -2134.8, 210.310, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 9528.4, 5520.3, 181.699, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 2608.1, -10148.4, 109.517, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 8412.1, -8112.0, 141.287, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsoc"), -1330.7, 1225.8, 131.560, FourCC("nsoc"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000099_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), -1211.2, 1415.2, 153.344, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrv"), 8218.7, -8239.8, 141.950, FourCC("nmrv"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000200_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsog"), -1580.7, 1276.2, 114.336, FourCC("nsog"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000096_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 8130.4, 7611.5, 225.694, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -8133.3, 7500.3, 296.704, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), -8605.0, -4019.1, 11.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000255_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -9818.8, -2729.9, 43.979, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000168_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), 9532.4, 5698.7, 201.970, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000088_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 2161.5, 9326.8, 300.902, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 2490.0, 9433.0, 272.291, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 5386.9, 9158.7, 310.217, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000247_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 5689.1, 9003.2, 303.143, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 5651.8, 9341.4, 292.660, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), 2306.7, 9405.3, 282.830, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000126_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -6011.2, 9401.6, 303.395, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -5687.6, 9522.0, 274.783, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), -5832.4, 9460.0, 291.982, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000228_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -9573.9, 2175.8, 17.039, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsog"), -1271.7, -1418.5, 204.336, FourCC("nsog"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000310_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -5499.7, -9823.9, 72.014, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000159_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsoc"), -1240.2, -1246.7, 221.560, FourCC("nsoc"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000311_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), -1432.1, -1154.8, 224.335, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsog"), 1424.9, -1306.9, 294.336, FourCC("nsog"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000309_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 2626.8, -10407.6, 122.990, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000277_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsoc"), 1220.8, -1263.8, 311.560, FourCC("nsoc"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000256_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), 1362.9, -1121.8, 277.230, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsog"), 1258.6, 1482.6, 24.336, FourCC("nsog"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000308_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 9367.3, -5633.0, 186.712, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000111_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsoc"), 1236.5, 1313.5, 41.560, FourCC("nsoc"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000107_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), 1072.3, 1471.0, 21.000, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 5233.9, 4887.8, 234.165, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000216_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 5393.6, 4773.2, 231.540, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000215_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 5667.4, 4507.8, 209.228, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), -8679.7, 3762.3, 4.438, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), -8663.1, 4005.3, 11.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000120_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -8563.3, 4244.1, 357.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000121_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -8419.7, 4034.2, 38.860, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -8505.2, -3780.3, 357.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000150_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), -3527.4, -8628.3, 105.028, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), -8627.4, -4240.4, 4.438, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 5983.1, -9598.5, 146.830, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 2170.3, -10220.9, 77.554, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -9598.2, 2520.1, 348.428, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 5734.1, -9837.5, 118.218, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), -9622.1, 2365.2, 348.043, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000231_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -9497.4, -5924.5, 17.039, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), 5882.0, -9714.7, 139.457, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000312_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -9521.8, -5580.2, 348.428, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), -9533.0, -5750.9, 3.738, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000049_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 9459.8, 2719.4, 234.929, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000276_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), -2446.9, 3261.3, 285.990, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000140_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), -2563.7, 3060.0, 306.030, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000135_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), -2802.6, 2955.6, 332.847, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), 6303.2, -203.7, 147.924, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 2386.1, -10495.1, 136.474, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -5815.3, -9563.2, 62.949, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -5780.3, -9839.5, 77.920, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), 3173.1, -3071.3, 126.030, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000141_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), 3056.3, -3272.6, 105.990, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000045_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), 3434.4, -2958.4, 150.670, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrv"), 8267.2, 7788.7, 231.950, FourCC("nmrv"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000254_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 8090.1, 7934.4, 250.260, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 8435.7, 7652.3, 211.740, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000178_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), 4218.2, -521.3, 181.529, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), 4235.0, -845.4, 173.760, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000147_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), 4075.0, -696.9, 185.135, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrn"), 4226.2, -699.8, 183.930, FourCC("nsrn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000157_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrv"), -8277.6, 7699.8, 321.950, FourCC("nmrv"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000251_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -8451.7, 7567.2, 321.270, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -8141.2, 7868.3, 301.740, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000097_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), 848.4, 3980.0, 263.760, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000145_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), 530.9, 3989.4, 272.324, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), 693.9, 3852.6, 275.930, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), -3890.7, 433.5, 353.760, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000152_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), -3779.4, 110.9, 10.161, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), -3709.9, 243.2, 354.501, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), -3121.2, -3189.7, 25.723, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000225_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgn"), -2819.2, -3570.8, 58.651, FourCC("nsgn"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsgh"), -2919.9, -3306.4, 44.893, FourCC("nsgh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000224_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 8082.3, -8408.3, 121.740, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000199_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -2440.4, 9623.4, 313.497, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000262_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), 8093.7, -8045.2, 116.720, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -5373.3, -9603.4, 94.913, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -9717.8, -2286.6, 4.703, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -9558.6, -2700.9, 47.201, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -9950.2, -2440.1, 13.829, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -9930.1, -203.4, 323.401, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), -10066.2, -243.5, 39.330, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000259_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -10082.2, -61.0, 8.700, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000257_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), -10074.9, 110.7, 31.492, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -136.5, 9822.2, 232.020, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), -193.3, 9942.0, 309.330, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000288_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -10.8, 9958.0, 278.700, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000244_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), 181.0, 9959.4, 326.574, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 10066.3, 286.7, 147.737, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), 10210.6, 330.1, 219.330, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000292_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), 10226.7, 147.6, 188.700, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000208_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -67.5, -10556.6, 98.700, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000240_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), -244.1, -10515.1, 126.191, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmsn"), 49.6, -10492.9, 141.750, FourCC("nmsn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000238_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), 10234.5, -15.5, 215.828, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 10104.8, -20.5, 148.213, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrh"), -8101.0, -8072.5, 33.056, FourCC("ntrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmbg"), 9710.8, -2304.8, 201.795, FourCC("nmbg"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000182_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -4316.9, -3468.2, 152.770, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000185_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -8425.1, -8061.0, 31.740, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000286_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrt"), -8132.3, -8396.3, 57.623, FourCC("ntrt"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrv"), -8256.5, -8197.4, 51.950, FourCC("nmrv"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000239_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -4793.1, 1150.7, 90.129, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000073_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -249.9, -10385.4, 58.576, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -78.4, -10323.4, 52.242, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 153.8, -10409.3, 70.520, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), 5236.6, 4535.3, 201.794, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -128.1, 6180.7, 234.331, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000209_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 63.1, 6025.7, 231.710, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000132_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 332.7, 5874.6, 206.820, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), -78.7, 5826.4, 213.326, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -4942.8, 4332.7, 309.530, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000213_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -4658.1, 4542.1, 306.910, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000192_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -4465.8, 4692.0, 272.600, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), -4586.6, 4294.6, 279.106, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -6217.6, -653.7, 318.526, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000201_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -5994.1, -396.2, 315.910, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000196_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -5902.8, -215.8, 296.760, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), -5848.2, -617.1, 303.265, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -4950.2, -5228.2, 36.310, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000204_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -4737.4, -5485.9, 38.930, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000203_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), -5092.3, -5096.6, 4.238, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), -4688.5, -5179.3, 10.744, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 460.0, -6794.0, 58.214, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000151_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 186.0, -6594.2, 55.590, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000143_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 2.0, -6520.9, 24.417, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), 396.9, -6487.5, 30.923, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 5593.3, -5005.2, 106.507, FourCC("nlpd"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000294_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 5248.2, -5092.7, 103.890, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000293_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlpd"), 5026.8, -5150.6, 64.143, FourCC("nlpd"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlpr"), 5216.1, -4874.3, 70.649, FourCC("nlpr"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), 8240.7, 4214.0, 202.758, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), 8371.1, 3962.8, 191.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000220_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 8271.2, 3724.0, 177.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000218_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 8091.1, 3868.8, 162.669, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), 8173.3, -3682.6, 192.304, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), 8209.5, -3911.2, 191.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000175_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 8109.6, -4150.0, 177.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000174_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 7966.8, -3997.0, 156.118, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), 3642.2, 8305.9, 262.236, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), 3832.4, 8205.9, 281.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000016_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 4071.2, 8106.0, 267.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000007_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 3853.0, 7994.3, 296.659, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), -4308.7, 8341.6, 288.536, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), -4029.8, 8319.0, 281.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000082_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -3791.0, 8219.2, 267.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000166_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -3986.0, 8148.3, 258.573, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 10057.5, 131.3, 141.879, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 173.0, 9829.9, 232.495, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 17.3, 9797.9, 226.161, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -9370.8, 5910.8, 14.207, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -9150.6, 5615.0, 56.705, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -9574.6, 5721.1, 23.333, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), -1982.9, 9587.8, 283.534, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -2298.2, 9387.9, 326.033, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -3985.8, -8517.7, 87.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000221_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), -3747.0, -8617.5, 101.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000173_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -3842.4, -8422.6, 139.450, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -3618.9, -8477.8, 11.016, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlsn"), 4237.1, -8520.5, 112.358, FourCC("nlsn"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlkl"), 4016.8, -8589.6, 101.740, FourCC("nlkl"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000290_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 3778.0, -8489.7, 87.780, FourCC("nlds"))
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000115_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 3898.4, -8356.8, 146.780, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -2873.6, 4692.2, 33.868, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000041_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -3014.0, 4817.0, 20.745, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 1692.1, 5410.8, 332.901, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000083_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -4592.5, 1147.0, 107.503, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 5525.3, -1638.6, 239.651, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000123_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -4216.5, -3324.5, 138.158, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -1273.9, -5586.1, 152.770, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000183_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -1190.0, -5452.2, 156.460, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 3483.2, -4790.6, 210.103, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000172_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 3375.0, -4628.9, 230.914, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -8462.7, -4178.1, 270.426, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 5697.7, -1701.4, 245.185, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -2154.6, 9747.2, 292.660, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 9320.4, 2342.3, 219.766, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 9658.7, 2378.5, 202.773, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 9119.9, -5533.8, 183.661, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 9232.4, 2577.6, 219.766, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 9070.0, -5974.8, 151.698, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), 9347.0, -5945.8, 166.668, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -5616.6, -9541.1, 94.913, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -8367.4, -3968.6, 38.860, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 2357.0, -10149.5, 109.517, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 4127.1, -8383.0, 18.346, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 9052.3, -5775.7, 183.661, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 8022.7, -3773.7, 185.283, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 8107.9, 4098.4, 195.154, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 9452.0, 2191.9, 187.803, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), 5454.2, 8914.4, 326.033, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmtw"), 5839.1, 9135.3, 283.534, FourCC("nmtw"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), 3668.3, 8131.8, 168.224, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -2132.9, 9455.6, 303.143, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("ntrs"), -9436.5, 5559.5, 30.346, FourCC("ntrs"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000117_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -9236.9, 5762.4, 33.816, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -4211.4, 8194.8, 283.708, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -9610.3, -2455.1, 24.312, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nltc"), -8515.0, 3824.6, 270.426, FourCC("nltc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 1612.3, 5239.4, 336.150, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrn"), 702.8, 3971.2, 273.930, FourCC("nsrn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000134_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrn"), -3820.7, 285.9, 3.930, FourCC("nsrn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000148_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrn"), -16.9, -4215.2, 93.930, FourCC("nsrn"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000139_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), 156.9, -4208.3, 96.828, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), -16.4, -4084.7, 100.434, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsrh"), -162.5, -4224.1, 83.760, FourCC("nsrh"))
    SetUnitAcquireRange(u, 200.0)
    t = CreateTrigger()
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    TriggerAddAction(t, Unit000136_DropItems)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -9945.2, 105.9, 323.876, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nmcf"), -9909.5, -49.0, 317.542, FourCC("nmcf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 6560.5, -163.6, 158.711, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 5541.7, 4637.3, 231.046, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 196.5, 5953.2, 235.937, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -4780.5, 4432.1, 306.355, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -6077.7, -547.4, 310.711, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), -4832.4, -5351.8, 37.516, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 344.2, -6694.6, 56.186, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nlds"), 5442.4, -5042.0, 120.412, FourCC("nlds"))
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -1378.2, 1441.2, 136.140, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 1403.9, 1326.1, 46.140, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), 1219.6, -1477.2, 316.140, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nsko"), -1411.4, -1315.6, 226.140, FourCC("nsko"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), -1109.2, -1431.1, 207.763, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), -1515.5, 1109.9, 128.012, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), 1371.6, 1168.0, 84.844, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
    u = BlzCreateUnitWithSkin(p, FourCC("nskf"), 1099.4, -1386.2, 335.515, FourCC("nskf"))
    SetUnitAcquireRange(u, 200.0)
end

function CreateNeutralPassiveBuildings()
    local p = Player(PLAYER_NEUTRAL_PASSIVE)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4992.0, 4800.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -9024.0, 4160.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrk"), -8448.0, 7936.0, 270.000, FourCC("nmrk"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("nmrc"), 3712.0, 2496.0, 270.000, FourCC("nmrc"))
    SetUnitColor(u, ConvertPlayerColor(1))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 256.0, 6336.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("ntav"), 0.0, 0.0, 270.000, FourCC("ntav"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("ngme"), 0.0, 10240.0, 270.000, FourCC("ngme"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -5184.0, -5568.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrk"), 8448.0, 8000.0, 270.000, FourCC("nmrk"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -3968.0, 8768.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrc"), -2752.0, 3328.0, 270.000, FourCC("nmrc"))
    SetUnitColor(u, ConvertPlayerColor(1))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -8896.0, -3968.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("ngad"), -3968.0, 128.0, 270.000, FourCC("ngad"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 5376.0, -5440.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 704.0, 4224.0, 270.000, FourCC("ngad"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 6848.0, -320.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrc"), 3392.0, -3328.0, 270.000, FourCC("nmrc"))
    SetUnitColor(u, ConvertPlayerColor(1))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -6400.0, -320.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngme"), -10368.0, -64.0, 270.000, FourCC("ngme"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngme"), 10496.0, 128.0, 270.000, FourCC("ngme"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 3968.0, 8640.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 8768.0, 3904.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 0.0, -4416.0, 270.000, FourCC("ngad"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 8704.0, -3968.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 3968.0, -8960.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("nmrk"), -8448.0, -8448.0, 270.000, FourCC("nmrk"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("nmrc"), -3136.0, -3520.0, 270.000, FourCC("nmrc"))
    SetUnitColor(u, ConvertPlayerColor(1))
    u = BlzCreateUnitWithSkin(p, FourCC("nmrk"), 8448.0, -8448.0, 270.000, FourCC("nmrk"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("ngme"), 64.0, -10752.0, 270.000, FourCC("ngme"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 4480.0, -640.0, 270.000, FourCC("ngad"))
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 64.0, -6912.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 5696.0, 4928.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 17500)
    u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -3840.0, -9024.0, 270.000, FourCC("ngol"))
    SetResourceAmount(u, 15000)
    u = BlzCreateUnitWithSkin(p, FourCC("nmg1"), -5728.0, 9696.0, 270.000, FourCC("nmg1"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg0"), -6304.0, 9120.0, 270.000, FourCC("nmg0"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg0"), -2720.0, 9696.0, 270.000, FourCC("nmg0"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg0"), 2720.0, 9504.0, 270.000, FourCC("nmg0"))
    u = BlzCreateUnitWithSkin(p, FourCC("nmg0"), 9888.0, 2720.0, 270.000, FourCC("nmg0"))
end

function CreateNeutralPassive()
    local p = Player(PLAYER_NEUTRAL_PASSIVE)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), 7535.2, 7289.4, 307.978, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), 4398.5, -7829.5, 347.512, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), 7889.0, -3751.5, 166.109, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), 7362.2, 3470.8, 9.009, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), 3888.9, 6822.8, 87.871, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), -3031.9, 6596.6, 337.433, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), -7729.9, 2130.6, 58.152, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), -6504.9, -2963.6, 96.067, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nalb"), -3159.2, -7711.4, 284.181, FourCC("nalb"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), 4737.1, 4055.3, 314.153, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), 5883.2, -378.2, 110.735, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), 5103.4, -4159.6, 129.709, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), 956.1, -5962.6, 232.236, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), -3842.7, -5186.3, 355.463, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), -5456.4, -781.6, 110.987, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), -4319.3, 3739.8, 7.537, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nskk"), -170.7, 5333.0, 325.821, FourCC("nskk"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), 9520.4, -216.5, 307.978, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), 7922.8, -7809.4, 307.978, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -198.6, -9701.0, 307.978, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -7556.2, -7604.9, 307.978, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -9432.0, -341.6, 307.978, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -7291.3, 7161.1, 307.978, FourCC("nhmc"))
    u = BlzCreateUnitWithSkin(p, FourCC("nhmc"), -14.1, 9184.5, 307.978, FourCC("nhmc"))
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
    SetPlayerStartLocation(Player(4), 4)
    SetPlayerColor(Player(4), ConvertPlayerColor(4))
    SetPlayerRacePreference(Player(4), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(4), true)
    SetPlayerController(Player(4), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(5), 5)
    SetPlayerColor(Player(5), ConvertPlayerColor(5))
    SetPlayerRacePreference(Player(5), RACE_PREF_ORC)
    SetPlayerRaceSelectable(Player(5), true)
    SetPlayerController(Player(5), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(6), 6)
    SetPlayerColor(Player(6), ConvertPlayerColor(6))
    SetPlayerRacePreference(Player(6), RACE_PREF_UNDEAD)
    SetPlayerRaceSelectable(Player(6), true)
    SetPlayerController(Player(6), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(7), 7)
    SetPlayerColor(Player(7), ConvertPlayerColor(7))
    SetPlayerRacePreference(Player(7), RACE_PREF_NIGHTELF)
    SetPlayerRaceSelectable(Player(7), true)
    SetPlayerController(Player(7), MAP_CONTROL_USER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
    SetPlayerTeam(Player(1), 0)
    SetPlayerTeam(Player(2), 0)
    SetPlayerTeam(Player(3), 0)
    SetPlayerTeam(Player(4), 0)
    SetPlayerTeam(Player(5), 0)
    SetPlayerTeam(Player(6), 0)
    SetPlayerTeam(Player(7), 0)
end

function InitAllyPriorities()
    SetStartLocPrioCount(0, 2)
    SetStartLocPrio(0, 0, 6, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(0, 1, 7, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(1, 2)
    SetStartLocPrio(1, 0, 2, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(1, 1, 7, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(2, 2)
    SetStartLocPrio(2, 0, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(2, 1, 3, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(3, 2)
    SetStartLocPrio(3, 0, 2, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(3, 1, 4, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(4, 2)
    SetStartLocPrio(4, 0, 3, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(4, 1, 5, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(5, 2)
    SetStartLocPrio(5, 0, 4, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(5, 1, 6, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(6, 2)
    SetStartLocPrio(6, 0, 0, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(6, 1, 5, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(7, 2)
    SetStartLocPrio(7, 0, 0, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(7, 1, 1, MAP_LOC_PRIO_HIGH)
end

function main()
    SetCameraBounds(-11008.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -11264.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 11008.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 10752.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -11008.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 10752.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 11008.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -11264.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    NewSoundEnvironment("Default")
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
    SetMapName("TRIGSTR_010")
    SetMapDescription("TRIGSTR_012")
    SetPlayers(8)
    SetTeams(8)
    SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
    DefineStartLocation(0, -8256.0, 3904.0)
    DefineStartLocation(1, 3904.0, 7872.0)
    DefineStartLocation(2, 8000.0, 3776.0)
    DefineStartLocation(3, 7936.0, -3904.0)
    DefineStartLocation(4, 3968.0, -8192.0)
    DefineStartLocation(5, -3776.0, -8256.0)
    DefineStartLocation(6, -8128.0, -4032.0)
    DefineStartLocation(7, -4160.0, 8000.0)
    InitCustomPlayerSlots()
    SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(2), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(3), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(4), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(5), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(6), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(7), MAP_CONTROL_USER)
    InitGenericPlayerSlots()
    InitAllyPriorities()
end

