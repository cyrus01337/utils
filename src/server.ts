import * as common from "@/common";

// @ts-ignore: TODO: Fix complaint
export * from "@/common";

interface QuickResponseWithStatus {
    (status: number): Response;
    (status: number, payload: null): Response;

    <Type extends object>(status: number, payload: Type): Response;
}

export const quickResponseWithStatus: QuickResponseWithStatus = <Type extends object | null>(
    status = 200,
    payload?: Type,
): Response =>
    payload ? Response.json(payload, { status }) : new Response(payload ?? null, { status });

export default {
    ...common,

    quickResponseWithStatus,
};
