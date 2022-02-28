import dedent from "dedent-js";

const WORD = /[a-z][a-z0-9]*(?:\b)*/gi;


function addMultipleEventsListener(element, ...args) {
    let listener = args[args.length - 1];

    if (typeof listener !== "function") {
        throw new Error("Callback not provided as final argument");
    }

    for (const event of args) {
        element.addEventListener(event, listener);
    }
}


function extractAsObject(from, to, attributes) {
    let toSupplied = true;

    if (to && !attributes) {
        toSupplied = false;
        attributes = to;
        to = {};
    }

    for (const key of attributes) {
        to[key] = from[key];
    }

    if (!toSupplied) {
        return to;
    }
}


function format(text, properties) {
    let doActualFormat = (_, matched) => properties[matched] || matched;

    return text.replaceAll(/{([a-z0-9_]+)}/ig, doActualFormat);
}


function isObjectEmpty(object) {
    if (!(object && Object.getPrototypeOf(object) === Object.prototype)) return;

    let keys = Object.keys(object);

    return keys.length === 0;
}


let normaliseMultilineString = (text) => dedent(text);
function sleep(seconds) {
    return new Promise(resolve => setTimeout(resolve, seconds));
}


function toTitleCase(text) {
    let toJoin = [];

    for (const word of text.match(WORD)) {
        let head = word[0],
            tail = word.slice(1);
        let title = head.toUpperCase() + tail.toLowerCase();

        toJoin.push(title);
    }

    return toJoin.join(" ");
}


function nullCallback() {}


export default {
    addMultipleEventsListener,
    extractAsObject,
    format,
    isObjectEmpty,
    normaliseMultilineString,
    sleep,
    toTitleCase,
    nullCallback
};
