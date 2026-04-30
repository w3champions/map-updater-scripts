import * as W3CEvents from "../lua/w3cEvents";

const f = W3CEvents.field;
const schema = W3CEvents.schema;
const withoutDefaults = { include_defaults: false };

const namedUnitFields: W3CEvents.Field[] = [
    f("name", "string"),
    f("typeId", "int"),
    f("unitType", "string"),
];

const namedEventFields: W3CEvents.Field[] = [
    f("name", "string"),
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
    ...["StructureStart", "StructureCancel", "StructureBuilt"].map((name) =>
        schema(name, namedUnitFields)
    ),
    schema("ResearchDone", namedEventFields),
    schema("HeroLevel", [
        f("hero", "string"),
        f("level", "int"),
    ]),
    schema("HeroSkill", [
        f("hero", "string"),
        f("heroLevel", "int"),
        f("skill", "string"),
        f("skillLevel", "int"),
    ]),
    schema("HeroItemPickup", [
        f("item", "string"),
        f("slot", "int"),
    ]),
    ...["HeroItemDrop", "HeroItemBought", "HeroItemSold"].map((name) =>
        schema(name, [f("item", "string")])
    ),
    ...["StructureDeath", "WorkerDeath", "UnitDeath", "CreepKill", "CreepDeny"].map((name) =>
        schema(name, namedEventFields)
    ),
    schema("HeroXp", [
        f("name", "string"),
        f("xp", "int"),
        f("source", "string"),
    ]),
];
