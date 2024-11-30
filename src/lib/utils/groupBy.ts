export function groupBy<T>(array: T[], key: keyof T): Record<string, T[]> {
    return array.reduce(
        (result, currentItem) => {
            const groupKey = String(currentItem[key]);
            if (!result[groupKey]) {
                result[groupKey] = [];
            }
            result[groupKey].push(currentItem);
            return result;
        },
        {} as Record<string, T[]>,
    );
}
