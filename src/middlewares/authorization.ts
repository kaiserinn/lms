import { db } from "@/services";
import type { MiddlewareHandler } from "hono";
import { getCookie } from "hono/cookie";

export const isAdmin: MiddlewareHandler = async (c, next) => {
    const token = getCookie(c, "auth_session");

    await db.check_admin(token);

    await next();
};

export const isInstructor: MiddlewareHandler = async (c, next) => {
    const token = getCookie(c, "auth_session");
    console.log(token);

    await db.check_instructor(token);

    await next();
};

export const isStudent: MiddlewareHandler = async (c, next) => {
    const token = getCookie(c, "auth_session");

    await db.check_student(token);

    await next();
};
