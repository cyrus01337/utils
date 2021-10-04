let CSSVars = {};


function doCSSVarConversion(value) {
    let asNumber = parseFloat(value);

    if (!isNaN(asNumber)) {
        return asNumber;
    }
}


export function append(parent, ...elements) {
    for (let element of elements) {
        parent.appendChild(element);
    }
}


export function toTitleCase(text) {
    let head = text[0];
    let tail = text.slice(1);

    // cleaner than format string here
    return head.toUpperCase() + tail.toLowerCase();
}


export function getCSSVar(property) {
    let cached = CSSVars[property];

    if (cached) {
        return cached;
    }

    let computedStyle = window.getComputedStyle(document.documentElement);
    let value = computedStyle.getPropertyValue(property);
    let converted = doCSSVarConversion(value);
    CSSVars[property] = converted;

    return converted;
}


export function getCSSVars() {
    let computedStyle = window.getComputedStyle(document.documentElement);

    for (let property of computedStyle) {
        let cached = CSSVars[property];

        if (!cached && property.startsWith("--")) {
            let value = computedStyle.getPropertyValue(property);
            CSSVars[property] = doCSSVarConversion(value);
        }
    }

    return CSSVars;
}
