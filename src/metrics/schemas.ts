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

// Shared by StructureDeath, WorkerDeath, UnitDeath, CreepDeny
const namedDeathFields: W3CEvents.Field[] = [
    f("name", "string"),
    f("typeId", "int"),
    f("level", "int"),
    f("isHero", "bool"),
    f("pointValue", "int"),
    f("x", "float"),
    f("y", "float"),
    f("killerPlayer", "int"),    // -1 if no player killer
    f("killerTypeId", "int"),    // 0 if no killer unit
    f("killerUnitName", "string"),
    f("killerX", "float"),
    f("killerY", "float"),
];

// Fields shared by all item transaction events
const heroItemFields: W3CEvents.Field[] = [
    f("hero", "string"),
    f("heroTypeId", "int"),
    f("item", "string"),
    f("itemTypeId", "int"),
    f("x", "float"),
    f("y", "float"),
];

// Additional shop context added to HeroItemBought and HeroItemSold
const shopContextFields: W3CEvents.Field[] = [
    f("shopName", "string"),
    f("shopTypeId", "int"),
    f("shopX", "float"),
    f("shopY", "float"),
];

const heroReviveFields: W3CEvents.Field[] = [
    f("hero", "string"),
    f("heroTypeId", "int"),
    f("x", "float"),
    f("y", "float"),
];

export const metricSchemas: W3CEvents.Schema[] = [
    schema("PlayerDetails", [
        f("player", "int"),
        f("sequence", "int"),
        f("name", "string"),
        f("race", "string"),          // "human" | "orc" | "undead" | "nightelf" | "other"
        f("team", "int"),
        f("startLocationId", "int"),
        f("startX", "float"),
        f("startY", "float"),
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
    schema("HeroItemDrop", heroItemFields),
    // HeroItemBought and HeroItemSold include shop context (needs validation per gap analysis)
    ...["HeroItemBought", "HeroItemSold"].map((name) =>
        schema(name, [...heroItemFields, ...shopContextFields])
    ),
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
    ...["StructureDeath", "WorkerDeath", "UnitDeath", "CreepDeny"].map((name) =>
        schema(name, namedDeathFields)
    ),
    schema("CreepKill", [
        f("name", "string"),
        f("typeId", "int"),
        f("level", "int"),
        f("pointValue", "int"),
        f("x", "float"),
        f("y", "float"),
        f("killingUnit", "string"),
        f("killingTypeId", "int"),
        f("killerX", "float"),
        f("killerY", "float"),
    ]),
    schema("UnitSummoned", [
        f("summoner", "string"),
        f("summonerTypeId", "int"),
        f("summonerX", "float"),
        f("summonerY", "float"),
        f("summoned", "string"),
        f("summonedTypeId", "int"),
        f("summonedX", "float"),
        f("summonedY", "float"),
    ]),
    schema("UnitOwnerChanged", [
        f("unit", "string"),
        f("typeId", "int"),
        f("x", "float"),
        f("y", "float"),
        f("previousOwner", "int"),
        f("newOwner", "int"),
    ]),
    // UnitSold: a unit purchased from a shop (mercenary, neutral hero, lab unit)
    schema("UnitSold", [
        f("soldUnit", "string"),
        f("soldTypeId", "int"),
        f("soldX", "float"),
        f("soldY", "float"),
        f("shopName", "string"),
        f("shopTypeId", "int"),
        f("shopX", "float"),
        f("shopY", "float"),
        f("buyerPlayer", "int"),
    ]),
    ...["HeroReviveStart", "HeroReviveCancel", "HeroReviveFinish"].map((name) =>
        schema(name, heroReviveFields)
    ),
    // SpellEvent: hero ability casts.
    schema("SpellEvent", [
        f("caster", "string"),
        f("casterTypeId", "int"),
        f("casterX", "float"),
        f("casterY", "float"),
        f("abilityId", "int"),
        f("ability", "string"),
        f("targetTypeId", "int"),    // 0 if no unit target
        f("target", "string"),       // "" if no unit target
        f("targetPlayer", "int"),    // -1 if no player unit target
        f("targetX", "float"),
        f("targetY", "float"),
    ]),
    // WorkerMineSnapshot: per-player worker count and resource amount at each gold mine
    schema("WorkerMineSnapshot", [
        f("mineTypeId", "int"),
        f("mineName", "string"),
        f("mineX", "float"),
        f("mineY", "float"),
        f("resourceAmount", "int"),
        f("workerCount", "int"),
    ]),
    schema("CombatStart", [
        f("targetPlayer", "int"),
        f("sourceCategory", "string"),
        f("sourceTypeId", "int"),
        f("sourceName", "string"),
        f("sourceX", "float"),
        f("sourceY", "float"),
        f("targetCategory", "string"),
        f("targetTypeId", "int"),
        f("targetName", "string"),
        f("targetX", "float"),
        f("targetY", "float"),
    ]),
    schema("CombatEnd", [
        f("targetPlayer", "int"),
    ]),
    schema("CombatSummary", [
        f("targetPlayer", "int"),
        f("sourceCategory", "string"),
        f("targetCategory", "string"),
        f("sourceTypeId", "int"),
        f("sourceName", "string"),
        f("targetTypeId", "int"),
        f("targetName", "string"),
        f("damage", "float"),
        f("eventCount", "int"),
        f("sourceX", "float"),
        f("sourceY", "float"),
        f("targetX", "float"),
        f("targetY", "float"),
    ]),
];
