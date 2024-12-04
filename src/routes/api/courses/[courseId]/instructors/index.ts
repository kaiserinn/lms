import { db } from "@/db";
import type { Course, CourseInstructor, User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isInstructor } from "@/middlewares/authorization";
import { HTTPException } from "hono/http-exception";
import { singleCourseInstructorRouter } from "./[instructorId]";

const router = createValidatedRouter();

router.route("/:courseInstructorId", singleCourseInstructorRouter);

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");

    type JoinedCourseInstructor = CourseInstructor &
        Pick<User, "first_name" | "last_name"> &
        Omit<Course, "description">;

    const results =
        await db.get_course_instructors<JoinedCourseInstructor>(courseId);

    return c.json({
        message: "Course's instructor data fetched successfully.",
        data: results.data,
    });
});

router.post("/:instructorId", isInstructor, async (c) => {
    const courseId = c.req.param("courseId");
    const instructorId = c.req.param("instructorId");

    const user = c.get("user");

    if (user.role === "INSTRUCTOR" && user.id !== Number(instructorId)) {
        throw new HTTPException(403, {
            message: "You are not authorized to access this resource.",
        });
    }

    await db.assign_instructor_to_course(instructorId, courseId);

    return c.json({
        message: "Course assigned successfully",
    });
});

export { router as courseInstructorsRouter };
