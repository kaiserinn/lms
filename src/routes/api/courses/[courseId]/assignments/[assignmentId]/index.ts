import { unlink } from "node:fs/promises";
import { resolve } from "node:path";
import type { Assignment, Attachment, Course, Merge, User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isInstructor } from "@/middlewares/authorization";
import { db } from "@/services";
import { HTTPException } from "hono/http-exception";
import { submissionsRouter } from "./submissions";

const router = createValidatedRouter();

router.route("/submissions", submissionsRouter);

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");

    const assignment = (
        await db.get_course_assignment<
            Merge<[Assignment, User, Course, Attachment]>
        >(courseId, assignmentId)
    ).data[0];

    if (!assignment) {
        throw new HTTPException(404, {
            message: `No assignment found with ID ${assignmentId}`,
        });
    }

    return c.json({
        message: `Course's assignment with ID ${assignmentId} fetched successfully`,
        data: {
            id: assignment.id,
            type: assignment.type,
            title: assignment.title,
            content: assignment.content,
            due_date: assignment.due_date,
            course: {
                id: assignment.course_id,
                name: assignment.name,
                description: assignment.description,
            },
            posted_by: {
                id: assignment.created_by,
                first_name: assignment.first_name,
                last_name: assignment.last_name,
                username: assignment.username,
                email: assignment.email,
                role: assignment.role,
            },
            attachment: assignment.attachment_id
                ? {
                      id: assignment.attachment_id,
                      file_name: assignment.file_name,
                      file_path: assignment.file_path,
                  }
                : null,
        },
    });
});

router.use(isInstructor);

router.patch("/", async (c) => {
    const courseId = c.req.param("courseId");
    const assignmentId = c.req.param("assignmentId");
    const user = c.get("user");
    const body = await c.req.json<
        Pick<Assignment, "type" | "title" | "content"> & {
            due_date: string;
            attachment_id: number;
        }
    >();

    const assignment = (
        await db.edit_assignment<Merge<[Assignment, User, Course]>>(
            user.id,
            courseId,
            assignmentId,
            body.type,
            body.title,
            body.content,
            body.due_date ? new Date(body.due_date) : null,
            body.attachment_id,
        )
    ).data[0];

    return c.json({
        message: "Course's assignment is successfully updated.",
        data: {
            id: assignment.id,
            type: assignment.type,
            title: assignment.title,
            content: assignment.content,
            due_date: assignment.due_date,
            course: {
                id: assignment.course_id,
                name: assignment.name,
                description: assignment.description,
            },
            posted_by: {
                id: assignment.created_by,
                first_name: assignment.first_name,
                last_name: assignment.last_name,
                username: assignment.username,
                email: assignment.email,
                role: assignment.role,
            },
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

export { router as singleAssignmentRouter };
