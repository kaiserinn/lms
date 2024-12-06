import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { db } from "@/services";
import { deleteCookie } from "hono/cookie";

const router = createValidatedRouter();

router.delete("/", async (c) => {
    const token = c.get("session").id;
    console.log(c.get("user"));
    console.log(c.get("session"));
    await db.logout(token);

    deleteCookie(c, "auth_session");

    return c.json({ message: "Logout successful" });
});

export { router as logoutRouter };
