import type { MiddlewareHandler } from "hono";
import { HTTPException } from "hono/http-exception";

const validateBody: MiddlewareHandler = async (c, next) => {
    if (!["POST", "PUT", "PATCH"].includes(c.req.method)) {
        return next();
    }

    const contentType = c.req.header("Content-Type") ?? "";

    if (
        !contentType.startsWith("application/json") &&
        !contentType.startsWith("multipart/form-data")
    ) {
        throw new HTTPException(415, {
            message: "Unsupported Media Type",
        });
    }

    await next();
};

export { validateBody };
