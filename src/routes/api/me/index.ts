import type { Session, User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { db } from "@/services";
import { deleteCookie, getCookie } from "hono/cookie";
import { HTTPException } from "hono/http-exception";

const router = createValidatedRouter();

router.get("/", async (c) => {
    return c.json({
        message: "User data fetched successfully.",
        data: c.get("user"),
    });
});

router.patch("/", async (c) => {
    const token = getCookie(c, "auth_session");
    const body = await c.req.json<
        Omit<User, "role"> & { confirmation_password: string }
    >();

    const user = (
        await db.edit_account<User>(
            c.get("user").id,
            body.username,
            body.email,
            body.first_name,
            body.last_name,
            null,
            body.password,
            body.confirmation_password,
        )
    ).data[0];

    return c.json({
        message: "Profile updated successfully.",
        data: user,
    });
});

router.delete("/", async (c) => {
    const token = getCookie(c, "auth_session");
    const user = c.get("user");
    const setHeader = (await db.delete_account<User>(user.id)).setHeader;

    if (!setHeader.affectedRows) {
        throw new HTTPException(401, {
            message: "No authorization included in the request.",
        });
    }

    await db.logout(token);
    deleteCookie(c, "auth_session");

    return c.json({
        message: "Your account is successfully closed.",
    });
});

export { router as meRouter };
