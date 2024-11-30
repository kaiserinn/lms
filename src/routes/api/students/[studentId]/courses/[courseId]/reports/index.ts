import { db } from "@/db";
import type { Assignment, LetterGrade, Submission } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isStudent } from "@/middlewares/authorization";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const studentId = c.req.param("studentId");

    type Report = Pick<Assignment, "id" | "title" | "type"> &
        Pick<Submission, "score"> & { grade: LetterGrade };

    const [reports, final_grade] = (
        await db.get_course_reports<
            [Report, { final_grade: LetterGrade; final_score: number }]
        >(studentId, courseId)
    ).data;

    return c.json({
        message: "Course report data is successfully fetched",
        data: {
            ...final_grade[0],
            reports: reports,
        },
    });
});

export { router as courseReportsRouter };
