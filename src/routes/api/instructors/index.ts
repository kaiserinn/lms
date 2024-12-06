import type { User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { db } from "@/services";
import { singleInstructorRouter } from "./[instructorId]";

const router = createValidatedRouter();

router.route("/:instructorId", singleInstructorRouter);

router.get("/", async (c) => {
    const filter = c.req.query();
    const results = await db.get_accounts<User>(
        filter["filter:any"],
        filter["filter:id"],
        filter["filter:username"],
        filter["filter:email"],
        filter["filter:first_name"],
        filter["filter:last_name"],
        "INSTRUCTOR",
    );

    return c.json({
        message: "Instructor data is successfully fetched.",
        data: results.data,
    });
});

export { router as instructorsRouter };
