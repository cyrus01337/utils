const WORD = /[a-z][a-z0-9]*(?:\b)*/gi;


export function addMultipleEventsListener(element, ...args) {
    let listener = args[args.length - 1];

    if (typeof listener !== "function") {
        throw new Error("Callback not provided as final argument");
    }

    for (const event of args) {
        element.addEventListener(event, listener);
    }
}


export function constructURLWithSearchParams(url, params) {
    let search = "";

    for (const [key, value] of Object.entries(params)) {
        search += `&${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
    }

    return url + search;
}


let _createTiming = (_type, amount) => ({
    type: _type,
    amount
});


export let createInterval = delay => _createTiming("interval", delay);
export let createTimestamp = timestamp => _createTiming("timestamp", timestamp);
export function createCycle(callback, timing = _createTiming(1000)) {
    let id;
    let isTimestamp = timing.type === "timestamp";
    let delay = !isTimestamp && timing.amount > 0 ?
        timing.amount :
        1000;

    if (isTimestamp) {
        function timestampCycleHandler() {
            let now = Date.now() / 1000;
            let amount = timing.amount;
            let destination = amount instanceof Date ?
                amount.getTime() :
                amount;
            let secondsUntilDestination = destination - now;

            if (secondsUntilDestination <= 0) {
                callback();
                clearInterval(id);
            }
        }

        callback = timestampCycleHandler;
    }

    id = setInterval(callback, delay);

    return id;
}


export function extractAsObject(from, to, attributes) {
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


export function format(text, properties) {
    let doActualFormat = (_, matched) => properties[matched] || matched;

    return text.replaceAll(/{([a-z0-9_]+)}/ig, doActualFormat);
}


export function isObjectEmpty(object) {
    if (!(object && Object.getPrototypeOf(object) === Object.prototype)) return;

    let keys = Object.keys(object);

    return keys.length === 0;
}


export let kmap = (iterable, callback) => iterable.map((_, key) => callback(key));
export function nullCallback() {}
export function random(obj) {
    if (!isNaN(obj)) {
        return Math.floor(Math.random() * obj);
    } else if (typeof obj === "string") {
        let head = random(obj.length - 1);

        return obj.substring(head, head + 1);
    } else if (obj instanceof Array) {
        let index = random(obj.length);

        return obj[index];
    } else if (obj instanceof Object) {
        let keys = Object.keys(obj);
        let index = random(keys.length);
        let key = keys[index];

        return obj[key];
    }
}


export function sleep(seconds) {
    return new Promise(resolve => setTimeout(resolve, seconds));
}


// I love you Danny :)
//
// https://github.com/Rapptz/discord.py/blob/06c257760bdedd39c37a7eb12f0338ac60b48c20/discord/utils.py#L658-L676
export async function sleepUntil(timestamp) {
    let now = Date.now() / 1000;
    let destination = timestamp instanceof Date ?
        timestamp.getTime() :
        timestamp;
    let secondsUntilDone = destination - now;

    await sleep(secondsUntilDone);
}


export function toTitleCase(text) {
    let toJoin = [];

    for (const word of text.match(WORD)) {
        let head = word[0],
            tail = word.slice(1);
        let title = head.toUpperCase() + tail.toLowerCase();

        toJoin.push(title);
    }

    return toJoin.join(" ");
}


export let vmap = (iterable, callback) => iterable.map(value => callback(value));
export default {
    addMultipleEventsListener,
    constructURLWithSearchParams,
    createCycle,
    createInterval,
    createTimestamp,
    extractAsObject,
    format,
    isObjectEmpty,
    kmap,
    nullCallback,
    random,
    sleep,
    sleepUntil,
    toTitleCase,
    vmap
};
