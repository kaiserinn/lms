import { db } from "@/db";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { singleStudentCourseRouter } from "./[courseId]";
import type { Course } from "@/lib/types";

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
    );

    return c.json({
        message: "Student's course data fetched successfully.",
        data: results.data,
    });
});

export { router as studentCoursesRouter };
