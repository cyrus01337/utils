import common from "./common";

let module = typeof window === "undefined" ?
    "server" :
    "browser";
let { default: imported } = await import(`./${module}.mjs`);

export default Object.assign(common, imported);
