

export function enableWorkerCount() {
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

    SetTextTagTextBJ(textTag, mine.workers + "/5", 16);
    SetTextTagPos(textTag, GetUnitX(mine.id) - 50, GetUnitY(mine.id) - 250, 0);

    if (mine.workers == 5) {
        SetTextTagColorBJ(textTag, 0, 100, 0, 100);
    } else {
        SetTextTagColorBJ(textTag, 100, 100, 30, 100);
    }
    SetTextTagVisibility(textTag, mine.workers > 0 && !IsPlayerEnemy(GetTriggerPlayer(), GetLocalPlayer()));
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