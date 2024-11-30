import { db } from "@/db";
import type { User } from "@/lib/types";
import { HTTPException } from "hono/http-exception";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const id = c.req.param("id");
    const instructor = (await db.get_instructor<User>(id)).data[0];

    if (!instructor) {
        throw new HTTPException(404, {
            message: `No instructor found with ID ${id}.`,
        });
    }

    return c.json({
        message: `Instructor with ID ${id} fetched successfully.`,
        data: instructor,
    });
});

export { router as singleInstructorRouter };
