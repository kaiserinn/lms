import { db } from "@/db";
import type { MiddlewareHandler } from "hono";
import { getCookie } from "hono/cookie";

export const validateSession: MiddlewareHandler = async (c, next) => {
    const token = getCookie(c, "auth_session");
    
    await db.validate_session(token);

    await next();
}
