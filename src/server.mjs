import path from "path";

import glob from "glob";

import common from "./common.mjs";


function generateWebpackEntryPoints() {
    let entries = {};
    let directories = glob.sync("./src/routes/**/entry.mjs");
    let names = directories.map(route => route.toLowerCase())
        .map(lowered => path.dirname(lowered))
        .map(parent => path.basename(parent));

    for (let i = 0; i < directories.length; i++) {
        let name = names[i];
        let directory = directories[i];
        let actualName = name === "routes" ?
            "index" :
            name;

        entries[actualName] = directory;
    }

    return entries;
}


async function getAllRoutes(cwd) {
    let routes = [];
    // here, we slice the array to skip the first element and avoid recursive imports
    let directories = glob.sync("./**/", { absolute: true, cwd })
        .slice(1);

    for (const directory of directories) {
        let { default: imported } = await import(`${directory}/index.mjs`);

        routes.push(imported);
    }

    return routes;
}


export default Object.assign(common, {
    generateWebpackEntryPoints,
    getAllRoutes
});
