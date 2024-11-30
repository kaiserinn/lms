import { db } from "@/db";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isStudent } from "@/middlewares/authorization";
import { HTTPException } from "hono/http-exception";

const router = createValidatedRouter();

router.delete("/", isStudent, async (c) => {
    const courseId = c.req.param("courseId");
    const studentId = c.req.param("studentId");

    const user = c.get("user");

    if (user.role === "STUDENT" && user.id !== Number(studentId)) {
        throw new HTTPException(403, {
            message: "You are not authorized to access this resource."
        });
    }

    await db.drop_course(studentId, courseId);

    return c.json({
        message: "Course dropped successfully",
    });
});

export { router as singleStudentCourseRouter };
