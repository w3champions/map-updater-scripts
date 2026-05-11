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

const namedDeathFields: W3CEvents.Field[] = [
    f("name", "string"),
    f("typeId", "int"),
    f("dyingUnitX", "float"),
    f("dyingUnitY", "float"),
];

export const metricSchemas: W3CEvents.Schema[] = [
    schema("PlayerDetails", [
        f("player", "int"),
        f("sequence", "int"),
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
        ])
    ),
    schema("HeroLevel", [
        f("hero", "string"),
        f("heroTypeId", "int"),
        f("level", "int"),
        f("x", "float"),
        f("y", "float"),
    ]),
    schema("HeroSkill", [
        f("hero", "string"),
        f("heroTypeId", "int"),
        f("heroLevel", "int"),
        f("skill", "string"),
        f("skillId", "int"),
        f("skillLevel", "int"),
        f("x", "float"),
        f("y", "float"),
    ]),
    schema("HeroItemPickup", [
        f("hero", "string"),
        f("heroTypeId", "int"),
        f("item", "string"),
        f("itemTypeId", "int"),
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
        schema(name, namedDeathFields)
    ),
    schema("CreepKill", [
        f("name", "string"),
        f("typeId", "int"),
        f("killingUnit", "string"),
        f("killingTypeId", "int"),
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
    // CombatStart: fires on first player-vs-player damage after a gap
    schema("CombatStart", [
        f("targetPlayer", "int"),
        f("sourceCategory", "string"),   // "hero" | "unit" | "worker"
        f("sourceTypeId", "int"),
        f("sourceX", "float"),
        f("sourceY", "float"),
        f("targetCategory", "string"),   // "hero" | "unit" | "worker" | "structure"
        f("targetTypeId", "int"),
        f("targetX", "float"),
        f("targetY", "float"),
    ]),
    // CombatEnd: fires ~1 second after last player-vs-player damage in a fight
    schema("CombatEnd", [
        f("targetPlayer", "int"),
    ]),
    // CombatSummary: 5-second delta window per (sourcePlayer x targetPlayer x sourceCategory x targetCategory)
    schema("CombatSummary", [
        f("targetPlayer", "int"),           // -1 for creep/neutral
        f("sourceCategory", "string"),      // "hero" | "unit" | "worker"
        f("targetCategory", "string"),      // "hero" | "unit" | "worker" | "structure" | "creep"
        f("sourceHeroTypeId", "int"),       // hero type if sourceCategory = "hero", else 0
        f("targetHeroTypeId", "int"),       // hero type if targetCategory = "hero", else 0
        f("damage", "float"),
        f("eventCount", "int"),
        f("sourceX", "float"),
        f("sourceY", "float"),
        f("targetX", "float"),
        f("targetY", "float"),
    ]),
];
