import { Hono } from "hono";
import type { User, Session } from "../types";

export function createValidatedRouter() {
    type Variables = {
        user: User;
        session: Session;
    };

    return new Hono<{ Variables: Variables }>();
}
