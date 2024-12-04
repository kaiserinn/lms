import { db } from "@/db";
import type { Assignment, Attachment, Course, Merge, User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isInstructor } from "@/middlewares/authorization";
import { singleAssignmentRouter } from "./[assignmentId]";

const router = createValidatedRouter();

router.route("/:assignmentId", singleAssignmentRouter);

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const filters = c.req.query();

    const assignments = (
        await db.get_course_assignments<
            Merge<[Assignment, User, Course, Attachment]>
        >(
            courseId,
            filters["filter:any"],
            filters["filter:id"],
            filters["filter:title"],
            filters["filter:due_date"],
        )
    ).data;

    return c.json({
        message: "Course's assignment data is successfully fetched.",
        data: assignments.map((assignment) => ({
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
        })),
    });
});

router.use(isInstructor);

router.post("/", async (c) => {
    const courseId = c.req.param("courseId");
    const user = c.get("user");
    const body = await c.req.json<
        Pick<Assignment, "type" | "title" | "content"> & {
            due_date: string;
            attachment_id: number;
        }
    >();

    const assignment = (
        await db.add_assignment<Merge<[Assignment, User, Course, Attachment]>>(
            user.id,
            courseId,
            body.type,
            body.title,
            body.content,
            body.due_date ? new Date(body.due_date) : null,
            body.attachment_id,
        )
    ).data[0];

    return c.json({
        message: "Course's assignment is successfully created.",
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

export { router as assignmentsRouter };
