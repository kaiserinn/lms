import { db } from "@/db";
import type { User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isAdmin } from "@/middlewares/authorization";
import { HTTPException } from "hono/http-exception";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const id = c.req.param("id");
    const account = (await db.get_account<User>(id)).data[0];

    if (!account) {
        throw new HTTPException(404, {
            message: `No account found with ID ${id}.`,
        });
    }

    return c.json({
        message: `Account with ID ${id} fetched successfully.`,
        data: account,
    });
});

router.delete("/", async (c) => {
    const id = c.req.param("id");
    const user = (await db.get_account<User>(id)).data[0];

    if (!(user.role === "ADMIN" || user.id === Number(id))) {
        throw new HTTPException(403);
    }

    const setHeader = (await db.delete_account<User>(id)).setHeader;
    if (!setHeader.affectedRows) {
        throw new HTTPException(404, {
            message: `No account found with ID ${id}.`,
        });
    }

    return c.json({
        message: `Account with ID ${id} deleted successfully.`,
    });
});

router.use(isAdmin);

router.patch("/", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json<User & { confirmation_password: string }>();

    const account = (
        await db.edit_account<User>(
            id,
            body.username,
            body.email,
            body.first_name,
            body.last_name,
            body.role,
            body.password,
            body.confirmation_password,
        )
    ).data[0];

    return c.json({
        message: `Account with ID ${id} updated successfully.`,
        data: account,
    });
});

export { router as singleAccountRouter };
