    declare function require(file: string): void;
    declare function event(name: string, value: EventPayload): void;
    declare function track(name: string, getter: () => EventPayload, interval: number): void;
    declare function flush(): void;
    declare function init(options: Options | string): void;

    export interface Options {
        prefix: string,
        byteBudget?: number,
        flushInterval?: number,
    }

    export interface Event {
        name: string,
        time: Number,
        value: EventPayload
    }

    export interface EventPayload {
        player: number,
        value: string | number | { [key: string]: (string|number) }
    }