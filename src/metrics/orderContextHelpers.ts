export const GRID_SIZE = 64;
export const RECENTLY_SEEN_NEVER = 6;

export function quantizeCoord(value: number) {
    return Math.max(0, Math.floor(value / GRID_SIZE) * GRID_SIZE);
}

export function getDistanceBucket(distance: number) {
    if (distance <= 200) {
        return 0;
    } else if (distance <= 500) {
        return 1;
    } else if (distance <= 900) {
        return 2;
    }

    return 3;
}

export function getRecentlySeenBucketFromDelta(deltaSeconds?: number) {
    if (deltaSeconds === undefined) {
        return RECENTLY_SEEN_NEVER;
    }

    const delta = Math.max(0, deltaSeconds);
    if (delta === 0) {
        return 0;
    } else if (delta <= 3) {
        return 1;
    } else if (delta <= 8) {
        return 2;
    } else if (delta <= 15) {
        return 3;
    } else if (delta <= 30) {
        return 4;
    }

    return 5;
}
