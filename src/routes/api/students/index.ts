import { db } from "@/db";
import type { User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { singleStudentRouter } from "./[studentId]";

const router = createValidatedRouter();

router.route("/:studentId", singleStudentRouter);

router.get("/", async (c) => {
    const filter = c.req.query();
    const results = await db.get_accounts<User>(
        filter["filter:any"],
        filter["filter:id"],
        filter["filter:username"],
        filter["filter:email"],
        filter["filter:first_name"],
        filter["filter:last_name"],
        "STUDENT"
    );

    return c.json({
        message: "Student data is successfully fetched.",
        data: results.data,
    });
});

export { router as studentsRouter };
