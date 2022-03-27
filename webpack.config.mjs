import rules from "webpack-rules";

export default {
    entry: {
        browser: "./src/browser.mjs",
        common: "./src/common.mjs",
        server: "./src/server.mjs"
    },
    experiments: {
        outputModule: true,
        topLevelAwait: true
    },
    externals: ["glob"],
    mode: "production",
    module: {
        rules: [
            rules.js()
        ]
    },
    output: {
        clean: true,
        library: {
            type: "module"
        },
        module: true
    },
    resolve: {
        enforceExtension: false,
        extensions: [".mjs"],
        preferRelative: true
    }
};
