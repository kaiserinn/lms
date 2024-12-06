import { db } from "@/services";
import { Hono } from "hono";

const router = new Hono();

router.post("/", async (c) => {
    const body = await c.req.json();

    await db.register(
        body.username,
        body.email,
        body.password,
        body.firstName,
        body.lastName,
        body.role,
    );

    return c.json({
        message: "Register successful",
    });
});

export { router as registerRouter };
