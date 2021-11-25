let CSSVars = {};


function doCSSVarConversion(value) {
    let asNumber = parseFloat(value);

    if (!isNaN(asNumber)) {
        return asNumber;
    }
}


let isOutOfBounds = element => !!element.querySelector(":hover");
function nullCallback() {}
function getCSSVar(property) {
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


function append(parent, ...elements) {
    for (const element of elements) {
        parent.appendChild(element);
    }
}


function toTitleCase(text) {
    let head = text[0];
    let tail = text.slice(1);

    return head.toUpperCase() + tail.toLowerCase();
}


function normaliseMultiLineString(text) {
    return text.trim().replaceAll(/\t/g, "").replaceAll(/[\n]+/g, " ").replaceAll(/ {2,}/g, " ");
}


function addMultipleEventsListener(element, ...args) {
    let listener = args[args.length - 1];

    if (typeof listener !== "function") {
        throw new Error("Callback not provided as final argument");
    }

    for (let event of args) {
        element.addEventListener(event, listener);
    }
}


function sleep(seconds) {
    return new Promise(resolve => setTimeout(resolve, seconds));
}


export default {
	addMultipleEventsListener,
	append,
	getCSSVar,
	getCSSVars,
    isOutOfBounds,
	normaliseMultiLineString,
	sleep,
	toTitleCase,
    nullCallback
};
