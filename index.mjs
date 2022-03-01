import path from "path";

import common from "./src/common.mjs";

let module = typeof window === "undefined" ?
    "node" :
    "browser/index";
let resolved = path.resolve(`./src/${module}.mjs`);
let { default: imported } = await import(resolved);

export default Object.assign(common, imported);
