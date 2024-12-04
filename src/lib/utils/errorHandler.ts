import type { ErrorHandler } from "hono";
import { HTTPException } from "hono/http-exception";
import type { StatusCode } from "hono/utils/http-status";

const sqlStateToHttpStatus: Record<string, StatusCode> = {
    "45000": 400, // Bad Request
    "45401": 401, // Unauthorized
    "45403": 403, // Forbidden
    "45404": 404, // Not Found
};

export const errorHandler: ErrorHandler = (err, c) => {
    if (err instanceof HTTPException) {
        return c.json({ error: err.message }, err.status);
    }

    if ("sqlState" in err) {
        const sqlState = err.sqlState as string;

        if (sqlState.startsWith("45")) {
            const status = sqlStateToHttpStatus[sqlState] || 400;
            return c.json({ error: err.message }, status);
        }

        if (sqlState === "23000") {
            return c.json({ error: "Constraint error: " }, 400);
        }
    }

    console.error(err);
    return c.json({ error: "Internal server error." }, 500);
};
