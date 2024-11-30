import { db } from "@/db";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { singleInstructorCourseRouter } from "./[courseId]";

const router = createValidatedRouter();

router.route("/:courseId", singleInstructorCourseRouter);

router.get("/", async (c) => {
    const instructorId = c.req.param("instructorId");

    const results = await db.get_instructor_courses(instructorId);

    return c.json({
        message: "Instructor's course data fetched successfully.",
        data: results.data,
    });
});

export { router as instructorCoursesRouter };
