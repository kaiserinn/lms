import type { User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { db } from "@/services";
import { HTTPException } from "hono/http-exception";
import { studentCoursesRouter } from "./courses";
import { transcriptRouter } from "./transcript";

const router = createValidatedRouter();

router.route("/courses", studentCoursesRouter);
router.route("/transcript", transcriptRouter);

router.get("/", async (c) => {
    const id = c.req.param("studentId");
    const student = (await db.get_student<User>(id)).data[0];

    if (!student) {
        throw new HTTPException(404, {
            message: `No student found with ID ${id}.`,
        });
    }

    return c.json({
        message: `Student with ID ${id} fetched successfully.`,
        data: student,
    });
});

export { router as singleStudentRouter };
