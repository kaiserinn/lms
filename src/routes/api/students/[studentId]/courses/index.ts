import { db } from "@/db";
import type { Course } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { singleStudentCourseRouter } from "./[courseId]";

const router = createValidatedRouter();

router.route("/:courseId", singleStudentCourseRouter);

router.get("/", async (c) => {
    const studentId = c.req.param("studentId");

    const filter = c.req.query();
    const results = await db.get_student_courses<Course>(
        studentId,
        filter["filter:any"],
        filter["filter:id"],
        filter["filter:name"],
        filter["filter:description"],
        filter["filter:status"],
    );

    return c.json({
        message: "Student's course data fetched successfully.",
        data: results.data,
    });
});

export { router as studentCoursesRouter };
