import { db } from "@/db";
import type { Assignment, Course, LetterGrade } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { groupBy } from "@/lib/utils/groupBy";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const id = c.req.param("studentId");
    const detailed = c.req.query("detailed") === "true";

    if (detailed) {
        type DetailedTranscript = {
            id: number;
            name: string;
            description: string;
            final_score: number;
            final_grade: LetterGrade;
            assignment_id: number;
            assignment_title: string;
            assignment_type: Pick<Assignment, "type">;
            assignment_score: number;
            assignment_grade: LetterGrade;
        };

        const results = (
            await db.get_detailed_student_transcript_suboptimal<DetailedTranscript>(
                id,
            )
        ).data;

        const courses = groupBy(results, "id");
        const data = Object.entries(courses).map(([courseId, reports]) => {
            const report = reports[0];
            return {
                final_score: report.final_score,
                final_grade: report.final_grade,
                course: {
                    id: courseId,
                    name: report.name,
                    description: report.description,
                },
                reports: reports.map((report) => ({
                    id: report.assignment_id,
                    title: report.assignment_title,
                    type: report.assignment_type,
                    score: report.assignment_score,
                    grade: report.assignment_grade,
                })),
            };
        });

        return c.json({
            message: "Transcript data is sucessfully fetched",
            data: data,
        });
    }

    type Transcript = Course & {
        final_score: number;
        final_grade: LetterGrade;
    };
    const transcript = (await db.get_student_transcript<Transcript>(id)).data;

    return c.json({
        message: "Transcript data is sucessfully fetched",
        data: transcript.map((course) => ({
            course: {
                id: course.id,
                name: course.name,
                description: course.description,
            },
            final_score: course.final_score,
            final_grade: course.final_grade,
        })),
    });
});

export { router as transcriptRouter };
