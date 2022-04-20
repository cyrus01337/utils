import common from "./common.mjs";

let CSSVars = {};


export function append(parent, ...elements) {
    for (const element of elements) {
        parent.appendChild(element);
    }
}


function _doCSSVarConversion(value) {
    let asNumber = parseFloat(value);

    if (!isNaN(asNumber)) {
        return asNumber;
    }
}


export function getCSSVar(property) {
    let cached = CSSVars[property];

    if (cached) return cached;

    let computedStyle = window.getComputedStyle(document.documentElement);
    let value = computedStyle.getPropertyValue(property);
    let converted = _doCSSVarConversion(value);
    CSSVars[property] = converted;

    return converted;
}


export function getCSSVars() {
    let computedStyle = window.getComputedStyle(
        document.documentElement
    );

    for (const property of computedStyle) {
        let cached = CSSVars[property];

        if (!cached && property.startsWith("--")) {
            let value = computedStyle.getPropertyValue(
                property
            );
            CSSVars[property] = _doCSSVarConversion(value);
        }
    }

    return CSSVars;
}


export let isOutOfBounds = element => !!element.querySelector(":hover");
export default Object.assign(common, {
    append,
    getCSSVar,
    getCSSVars,
    isOutOfBounds,
});
