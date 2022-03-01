import common from "./src/common.mjs";

let module = typeof window === "undefined" ?
    "node" :
    "browser/index";
let { default: imported } = await import(`./src/${module}.mjs`);

export default Object.assign(common, imported);
