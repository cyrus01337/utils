import rules from "webpack-rules";

export default {
    devtool: "source-map",
    entry: "./src/browser.mjs",
    mode: "production",
    module: {
        rules: [
            rules.js()
        ]
    },
    output: {
        clean: true,
        filename: "browser.mjs"
    },
    resolve: {
        extensions: [".mjs"],
        preferRelative: true
    }
};
