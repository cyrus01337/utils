export function constructURLWithSearchParams(url: string, params: Record<string, string>) {
    let search = "";

    for (const [key, value] of Object.entries(params)) {
        search += `&${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
    }

    return url + search;
}

export function sleep(milliseconds: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, milliseconds * 1000));
}

export function formDataToJson<Type>(formData: FormData) {
    return Object.fromEntries(formData.entries()) as Type;
}
