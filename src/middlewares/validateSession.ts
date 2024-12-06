import type { Session, User } from "@/lib/types";
import { db } from "@/services";
import type { MiddlewareHandler } from "hono";
import { getCookie } from "hono/cookie";

export const validateSession: MiddlewareHandler = async (c, next) => {
    const token = getCookie(c, "auth_session");

    const [session, user] = (await db.validate_session<[Session, User]>(token))
        .data;

    c.set("user", user[0]);
    c.set("session", session[0]);

    await next();
};
