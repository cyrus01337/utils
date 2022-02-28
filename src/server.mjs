import glob from "glob";


async function getAllRoutes(cwd) {
    let routes = [];
    // here, we slice the array to skip the first element and avoid recursive imports
    let directories = glob.sync("./**/", { absolute: true, cwd })
        .slice(1);

    for (const directory of directories) {
        let { default: imported } = await import(directory);

        routes.push(imported);
    }

    return routes;
}


export default {
    getAllRoutes
};
