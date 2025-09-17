
export function require(file: string): void;
export function event(name: string, value: EventPayload | NestedEventPrimitiveObject): void;
export function track(name: string, getter: () => EventPayload | NestedEventPrimitiveObject, interval: number): void;
export function flush(): void;
export function init(options: Options | string): void;


export interface Options {
    prefix: string,
    byteBudget?: number,
    flushInterval?: number,
}

export interface Event {
    name: string,
    time: Number,
    value: EventPayload | NestedEventPrimitiveObject,
}

export type EventPrimitive = string | number | boolean;
export type NestedEventPrimitiveObject = {
    [key: string]: EventPrimitive | NestedEventPrimitiveObject;
};

export interface EventPayload {
    player?: number,
    value: EventPrimitive | NestedEventPrimitiveObject
}