import common from "./common";

let module = typeof window === "undefined" ?
    "server" :
    "browser";
let { default: imported } = await import(`./${module}`);

export default Object.assign(common, imported);
