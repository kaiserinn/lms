import { unlink } from "node:fs/promises";
import { resolve } from "node:path";
import type {
    Assignment,
    Attachment,
    Course,
    Merge,
    Submission,
    User,
} from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isInstructor } from "@/middlewares/authorization";
import { db } from "@/services";
import { HTTPException } from "hono/http-exception";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");
    const submissionId = c.req.param("submissionId");
    const user = c.get("user");

    const submission = (
        await db.get_submission<
            Merge<
                [
                    Submission,
                    Omit<Assignment, "created_by">,
                    User,
                    Course,
                    Attachment,
                ]
            >
        >(user.id, courseId, assignmentId, submissionId)
    ).data[0];

    if (!submission) {
        throw new HTTPException(404, {
            message: `No submission found with ID ${submissionId} in this assignment/course`,
        });
    }

    return c.json({
        message: `Assignment's submission with ID ${submissionId} fetched successfully`,
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

router.delete("/", async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");
    const submissionId = c.req.param("submissionId");
    const user = c.get("user");

    const results = await db.delete_submission<Pick<Attachment, "file_path">>(
        user.id,
        courseId,
        assignmentId,
        submissionId,
    );

    if (!results.setHeader.affectedRows) {
        throw new HTTPException(404, {
            message: `No submission found with ID ${submissionId}`,
        });
    }

    const attachment = results.data[0];
    if (attachment) {
        await unlink(resolve(Bun.main, "../..", attachment.file_path));
    }

    return c.json({
        message: `Submission with ID ${submissionId} deleted successfully`,
    });
});

router.patch("/", isInstructor, async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");
    const submissionId = c.req.param("submissionId");
    const user = c.get("user");
    const body = await c.req.json<{ score: number }>();

    const submission = (
        await db.grade_submission<
            Merge<
                [
                    Submission,
                    Omit<Assignment, "created_by">,
                    User,
                    Course,
                    Attachment,
                ]
            >
        >(user.id, courseId, assignmentId, submissionId, body.score)
    ).data[0];

    if (!submission) {
        throw new HTTPException(404, {
            message: `No submission found with ID ${submissionId}`,
        });
    }

    return c.json({
        message: "Submission is successfully graded.",
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

router.delete("/", async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");
    const user = c.get("user");

    const results = await db.delete_assignment<Pick<Attachment, "file_path">>(
        user.id,
        courseId,
        assignmentId,
    );

    if (!results.setHeader.affectedRows) {
        throw new HTTPException(404, {
            message: `No assignment found with ID ${assignmentId}`,
        });
    }

    const attachment = results.data[0];
    if (attachment) {
        await unlink(resolve(Bun.main, "../..", attachment.file_path));
    }

    return c.json({
        message: `Assignment with ID ${assignmentId} deleted successfully`,
    });
});

export { router as singleSubmissionRouter };
