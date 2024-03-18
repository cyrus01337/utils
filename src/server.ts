import * as common from "./common";

import type { Payload } from "./types";

export * from "./common";

interface QuickResponseWithStatus {
    (status: number): Response;
    (status: number, payload: null): Response;

    <Type extends object>(status: number, payload: Type): Response;
}

export const quickResponseWithStatus: QuickResponseWithStatus = <
    ResponsePayloadType extends Payload<Status>,
    Status extends number = 200,
>(
    status: Status,
    payload?: ResponsePayloadType | undefined,
): Response =>
    payload ? Response.json(payload, { status }) : new Response(payload ?? null, { status });

export default {
    ...common,

    quickResponseWithStatus,
};
