import * as W3CEvents from "../lua/w3cEvents";

const f = W3CEvents.field;
const schema = W3CEvents.schema;
const withoutDefaults = { include_defaults: false };

const namedUnitFields: W3CEvents.Field[] = [
    f("name", "string"),
    f("typeId", "int"),
    f("unitType", "string"),
    f("x", "float"),
    f("y", "float"),
];

const namedEventFields: W3CEvents.Field[] = [
    f("name", "string"),
    f("dyingUnitX", "float"),
    f("dyingUnitY", "float"),
];

export const metricSchemas: W3CEvents.Schema[] = [
    schema("PlayerDetails", [
        f("player", "int"),
        f("name", "string"),
    ], withoutDefaults),
    schema("PlayerState", [
        f("gold", "int"),
        f("gold_upkeep", "int"),
        f("wood", "int"),
        f("wood_upkeep", "int"),
        f("food_cap", "int"),
        f("food_used", "int"),
    ]),
    schema("HeroDamage", [
        f("hero", "string"),
        f("creepDone", "float"),
        f("creepTaken", "float"),
        f("structureDone", "float"),
        f("structureTaken", "float"),
        f("heroDone", "float"),
        f("heroTaken", "float"),
        f("workerDone", "float"),
        f("workerTaken", "float"),
        f("unitDone", "float"),
        f("unitTaken", "float"),
    ]),
    ...["UnitStarted", "UnitCancelled", "UnitTrained"].map((name) =>
        schema(name, namedUnitFields)
    ),
    ...["StructureStart", "StructureCancel", "StructureBuilt", "UpgradeStart", "UpgradeCancel", "UpgradeComplete"].map((name) =>
        schema(name, namedUnitFields)
    ),
        ...["ResearchStart", "ResearchCancel", "ResearchComplete"].map((name) => 
        schema(name, [
            f("name", "string"),
            f("researchId", "int"),
            f("building", "string"),
            f("buildingTypeId", "int"),
            f("buildingX", "float"),
            f("buildingY", "float"),
        ])),
    schema("HeroLevel", [
        f("hero", "string"),
        f("level", "int"),
        f("x", "float"),
        f("y", "float"),
    ]),
    schema("HeroSkill", [
        f("hero", "string"),
        f("heroLevel", "int"),
        f("skill", "string"),
        f("skillLevel", "int"),
        f("x", "float"),
        f("y", "float"),
    ]),
    schema("HeroItemPickup", [
        f("item", "string"),
        f("slot", "int"),
        f("x", "float"),
        f("y", "float"),
    ]),
    ...["HeroItemDrop", "HeroItemBought", "HeroItemSold"].map((name) =>
        schema(name, [
            f("hero", "string"),
            f("heroTypeId", "int"),
            f("item", "string"),
            f("itemTypeId", "int"),
            f("x", "float"),
            f("y", "float"),
        ])
    ),
    ...["StructureDeath", "WorkerDeath", "UnitDeath", "CreepDeny"].map((name) =>
        schema(name, namedEventFields)
    ),
    schema("CreepKill", [
        f("name", "string"),
        f("killingUnit", "string"),
        f("dyingUnitX", "float"),
        f("dyingUnitY", "float"),
    ]),
    schema("HeroXp", [
        f("name", "string"),
        f("heroTypeId", "int"),
        f("xp", "int"),
        f("source", "string"),
        f("sourcePlayer", "int"),
    ]),
    schema("HeroItemUse", [
       f("hero", "string"),
       f("heroTypeId", "int"),
       f("item", "string"),
       f("itemTypeId", "int"),
       f("heroX", "float"),
       f("heroY", "float"),
       f("targetX", "float"),
       f("targetY", "float"),
       f("targetTypeId", "int"),
       f("target", "string"),
       f("targetPlayer", "int"), 
    ]),
];
