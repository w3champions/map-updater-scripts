export function initialize(config?: W3CEventsConfig): void;
export function register_all_schemas(schemas: Schema[]): void;
export function event(name: string, payload: EventPayload): void;
export function track(name: string, getter: () => EventPayload | EventPayload[], interval: number): () => void;
export function end_game(playerResults: W3CEventsGameEndPlayer[]): void;
export function boolField(name: string): Field;
export function byteField(name: string, options?: IntegerFieldOptions): Field;
export function shortField(name: string, options?: IntegerFieldOptions): Field;
export function intField(name: string, options?: IntegerFieldOptions): Field;
export function floatField(name: string): Field;
export function stringField(name: string): Field;
export function field(name: string, field_type: FieldType, options?: FieldOptions): Field;
export function schema(name: string, fields: Field[], options?: SchemaOptions): Schema;

export type FieldType = "bool" | "byte" | "short" | "int" | "number" | "float" | "string";
export type EventPrimitive = string | number | boolean;
export type EventPayload = Record<string, EventPrimitive>;

export interface Field {
    name: string;
    field_type: FieldType;
    num_of_bits?: number;
    unsigned?: boolean;
    minimum?: number;
    maximum?: number;
}

export interface IntegerFieldOptions {
    num_of_bits?: number;
    unsigned?: boolean;
    minimum?: number;
    maximum?: number;
}

export type FieldOptions = IntegerFieldOptions;

export interface SchemaOptions {
    version?: number;
    use_base?: boolean;
}

export interface Schema {
    version: number;
    name: string;
    use_base?: boolean;
    fields: Field[];
}

export interface W3CEventsConfig {
    checksum: ChecksumConfig;
    base_schema: BooleanConfig;
    logging: BooleanConfig;
}

export interface ChecksumConfig extends BooleanConfig {
    interval?: number;
}

export interface BooleanConfig {
    enabled: boolean;
}

export interface W3CEventsGameEndPlayer {
    player: number;
    won: boolean;
}
