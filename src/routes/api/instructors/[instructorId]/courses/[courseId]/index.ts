import { db } from "@/db";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isInstructor } from "@/middlewares/authorization";
import { HTTPException } from "hono/http-exception";

const router = createValidatedRouter();

router.delete("/", isInstructor, async (c) => {
    const courseId = c.req.param("courseId");
    const instructorId = c.req.param("instructorId");

    const user = c.get("user");

    if (user.role === "STUDENT" && user.id !== Number(instructorId)) {
        throw new HTTPException(403, {
            message: "You are not authorized to access this resource."
        });
    }

    await db.delete_course_instructor(instructorId, courseId);

    return c.json({
        message: "Instructor's course deleted successfully",
    });
});

export { router as singleInstructorCourseRouter };
