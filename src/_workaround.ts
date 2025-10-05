export const DUMMY = "to make it look like a module"

compiletime(() => {
    //TODO: How to get rid of this?

    // Fixes issues when importing map-loot-parser.ts and errors from tstl about usage of Enums
        require("ts-node").register({
            transpileOnly: true,
            // compilerOptions: {
            //     module: "commonjs",
            //     esModuleInterop: true,
            //     allowSyntheticDefaultImports: true,
            // }
        });
    }
);