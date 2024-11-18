import { db } from "@/db";
import type { Session, User } from "@/lib/types";
import { Hono } from "hono";
import { setCookie } from "hono/cookie";

const router = new Hono();

router.post("/", async (c) => {
    const { email, password } = await c.req.json<{
        email: string;
        password: string;
    }>();

    const [[[user]]] = await db.login<User>(email, password);
    const [[[session]]] = await db.create_session<Session>(user.id);

    setCookie(c, "auth_session", session.id, {
        httpOnly: true,
        expires: session.expires_at,
    });

    return c.json({
        message: "Login berhasil",
        data: {
            id: user.id,
            username: user.username,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
        },
    });
});

export { router as loginRouter };
