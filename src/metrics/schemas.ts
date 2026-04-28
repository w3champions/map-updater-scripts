import * as W3CEvents from "../lua/w3cEvents";

const f = W3CEvents.field;
const schema = W3CEvents.schema;
const withBase = { use_base: true };

const namedUnitFields: W3CEvents.Field[] = [
    f("name", "string"),
    f("typeId", "int"),
];

const namedEventFields: W3CEvents.Field[] = [
    f("name", "string"),
];

export const metricSchemas: W3CEvents.Schema[] = [
    schema("PlayerDetails", [
        f("player", "int"),
        f("name", "string"),
    ]),
    schema("PlayerState", [
        f("gold", "int"),
        f("gold_upkeep", "int"),
        f("wood", "int"),
        f("wood_upkeep", "int"),
        f("food_cap", "int"),
        f("food_used", "int"),
    ], withBase),
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
    ], withBase),
    ...["UnitStarted", "UnitCancelled", "UnitTrained", "HeroCancelled", "HeroTrained"].map((name) =>
        schema(name, namedUnitFields, withBase)
    ),
    ...["StructureStart", "StructureCancel", "StructureBuilt"].map((name) =>
        schema(name, namedUnitFields, withBase)
    ),
    schema("ResearchDone", namedEventFields, withBase),
    schema("HeroLevel", [
        f("hero", "string"),
        f("level", "int"),
    ], withBase),
    schema("HeroSkill", [
        f("hero", "string"),
        f("heroLevel", "int"),
        f("skill", "string"),
        f("skillLevel", "int"),
    ], withBase),
    schema("HeroItemPickup", [
        f("item", "string"),
        f("slot", "int"),
    ], withBase),
    ...["HeroItemDrop", "HeroItemBought", "HeroItemSold"].map((name) =>
        schema(name, [f("item", "string")], withBase)
    ),
    ...["StructureDeath", "WorkerDeath", "UnitDeath", "CreepKill", "CreepDeny"].map((name) =>
        schema(name, namedEventFields, withBase)
    ),
    schema("HeroXp", [
        f("name", "string"),
        f("xp", "int"),
        f("source", "string"),
    ], withBase),
];
