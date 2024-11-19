import { db } from "@/db";
import { Hono } from "hono";
import { deleteCookie, getCookie } from "hono/cookie";

const router = new Hono();

router.delete("/", async (c) => {
    const token = getCookie(c, "auth_session");
    await db.logout(token);

    deleteCookie(c, "auth_session");

    return c.json({ message: "Logout successful" });
});

export { router as logoutRouter };
