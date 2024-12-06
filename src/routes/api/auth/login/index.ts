import type { Session, User } from "@/lib/types";
import { db } from "@/services";
import { Hono } from "hono";
import { setCookie } from "hono/cookie";

const router = new Hono();

router.post("/", async (c) => {
    const { email, password } =
        await c.req.json<Pick<User, "email" | "password">>();

    const user = (await db.login<User>(email, password)).data[0];
    const session = (await db.create_session<Session>(user.id)).data[0];
    console.log(session.expires_at);

    setCookie(c, "auth_session", session.id, {
        httpOnly: true,
        expires: session.expires_at,
    });

    return c.json({
        message: "Login successful",
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
