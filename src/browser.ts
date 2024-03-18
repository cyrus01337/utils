import * as common from "./common";

export * from "./common";

export function isOutOfBounds<Element extends HTMLElement>(element: Element) {
    return !!element.querySelector(":hover");
}

export default {
    ...common,

    isOutOfBounds,
};
