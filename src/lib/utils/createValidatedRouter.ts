import { Hono } from "hono";
import type { Session, User } from "../types";

export function createValidatedRouter() {
    type Variables = {
        user: User;
        session: Session;
    };

    return new Hono<{ Variables: Variables }>();
}
