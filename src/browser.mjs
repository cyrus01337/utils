import common from "./common";

let CSSVars = {};


function append(parent, ...elements) {
    for (const element of elements) {
        parent.appendChild(element);
    }
}


function doCSSVarConversion(value) {
    let asNumber = parseFloat(value);

    if (!isNaN(asNumber)) {
        return asNumber;
    }
}


function getCSSVar(property) {
    let cached = CSSVars[property];

    if (cached) return cached;

    let computedStyle = window.getComputedStyle(document.documentElement);
    let value = computedStyle.getPropertyValue(property);
    let converted = doCSSVarConversion(value);
    CSSVars[property] = converted;

    return converted;
}


function getCSSVars() {
    let computedStyle = window.getComputedStyle(
        document.documentElement
    );

    for (const property of computedStyle) {
        let cached = CSSVars[property];

        if (!cached && property.startsWith("--")) {
            let value = computedStyle.getPropertyValue(
                property
            );
            CSSVars[property] = doCSSVarConversion(value);
        }
    }

    return CSSVars;
}


let isOutOfBounds = element => !!element.querySelector(":hover");


export default Object.assign(common, {
    append,
    getCSSVar,
    getCSSVars,
    isOutOfBounds,
});
