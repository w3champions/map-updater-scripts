import * as W3CEvents from "../lua/w3cEvents";

const f = W3CEvents.field;
const schema = W3CEvents.schema;

const actorFields: W3CEvents.Field[] = [
    f("issuerTypeId", "int", { unsigned: true }),
    f("issuerOwner", "int", { num_of_bits: 5, unsigned: true }),
    f("orderId", "int", { unsigned: true }),
];

export const orderContextSchemas: W3CEvents.Schema[] = [
    schema("OrderContextUnit", [
        ...actorFields,
        f("targetTypeId", "int", { unsigned: true }),
        f("targetOwner", "int", { num_of_bits: 5, unsigned: true }),
        f("targetIsHero", "bool"),
        f("targetIsStructure", "bool"),
        f("targetX", "short", { unsigned: true }),
        f("targetY", "short", { unsigned: true }),
        f("visible", "bool"),
        f("fogged", "bool"),
        f("masked", "bool"),
        f("recentlySeenBucket", "int", { num_of_bits: 3, unsigned: true }),
        f("revealSource", "int", { num_of_bits: 3, unsigned: true }),
    ]),
    schema("OrderContextPoint", [
        ...actorFields,
        f("pointX", "short", { unsigned: true }),
        f("pointY", "short", { unsigned: true }),
        f("nearHiddenEnemy", "bool"),
        f("nearestHiddenEnemyType", "int", { unsigned: true }),
        f("nearestHiddenEnemyOwner", "int", { num_of_bits: 5, unsigned: true }),
        f("distanceBucket", "int", { num_of_bits: 3, unsigned: true }),
        f("recentlySeenBucket", "int", { num_of_bits: 3, unsigned: true }),
        f("revealSource", "int", { num_of_bits: 3, unsigned: true }),
    ]),
];
