import type {
    Assignment,
    Attachment,
    Course,
    Merge,
    Submission,
    User,
} from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isStudent } from "@/middlewares/authorization";
import { db } from "@/services";
import { singleSubmissionRouter } from "./[submissionId]";

const router = createValidatedRouter();

router.route("/:submissionId", singleSubmissionRouter);

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");
    const filters = c.req.query();

    const user = c.get("user");

    if (user.role === "STUDENT") {
        filters["filter:submitted_by"] = `${user.id}`;
    }

    const results = await db.get_submissions<Submission>(
        courseId,
        assignmentId,
        filters["filter:any"],
        filters["filter:id"],
        filters["filter:status"],
        filters["filter:title"],
        filters["filter:submitted_by"],
    );

    return c.json({
        message: "Assignment's submission data is successfully fetched.",
        data: results.data,
    });
});

router.use(isStudent);

router.post("/", async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");
    const user = c.get("user");

    const body = await c.req.json<
        Pick<Submission, "title" | "content"> & {
            attachment_id: number;
        }
    >();

    const submission = (
        await db.add_submission<
            Merge<
                [
                    Submission,
                    Omit<Assignment, "created_by">,
                    User,
                    Course,
                    Attachment,
                ]
            >
        >(
            user.id,
            courseId,
            assignmentId,
            body.attachment_id,
            body.title,
            body.content,
        )
    ).data[0];

    return c.json({
        message: "Assignment submitted successfully.",
        data: {
            id: submission.id,
            status: submission.status,
            score: submission.score,
            title: submission.title,
            content: submission.content,
            submitted_at: submission.submitted_at,
            assignment: {
                id: submission.assignment_id,
                type: submission.type,
                title: submission.title,
                due_date: submission.due_date,
            },
            course: {
                id: submission.course_id,
                name: submission.name,
                description: submission.description,
            },
            submitted_by: {
                id: submission.submitted_by,
                first_name: submission.first_name,
                last_name: submission.last_name,
                username: submission.username,
                email: submission.email,
                role: submission.role,
            },
            attachment: submission.attachment_id
                ? {
                      id: submission.attachment_id,
                      file_name: submission.file_name,
                      file_path: submission.file_path,
                  }
                : null,
        },
    });
});

export { router as submissionsRouter };
