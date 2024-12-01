import { db } from "@/db";
import type {
    Course,
    CourseSpecification,
} from "@/lib/types";
import { isAdmin } from "@/middlewares/authorization";
import { HTTPException } from "hono/http-exception";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { postsRouter } from "./posts";

const router = createValidatedRouter();

router.route("/posts", postsRouter);

router.get("/", async (c) => {
    const id = c.req.param("courseId");

    const [courses, coursePrerequisites, courseSpecifications] = (
        await db.get_course<[Course, Course, CourseSpecification]>(id)
    ).data;
    const course = courses[0];

    if (!course) {
        throw new HTTPException(404, {
            message: `No course found with ID ${id}`,
        });
    }

    return c.json({
        message: `Course with ID ${id} fetched successfully`,
        data: {
            ...course,
            prerequisites: coursePrerequisites,
            specifications: courseSpecifications,
        },
    });
});

router.use(isAdmin);

router.patch("/", async (c) => {
    const id = c.req.param("courseId");
    const body = await c.req.json<Course>();

    const course = (
        await db.edit_course<Course>(id, body.name, body.description)
    ).data[0];

    return c.json({
        message: `Course with ID ${id} updated successfully`,
        data: course,
    });
});

router.delete("/", async (c) => {
    const id = c.req.param("courseId");
    const setHeader = (await db.delete_course(id)).setHeader;

    if (!setHeader.affectedRows) {
        throw new HTTPException(404, {
            message: `No course found with ID ${id}`,
        });
    }

    return c.json({
        message: `Course with ID ${id} deleted successfully`,
    });
});

export { router as singleCourseRouter };
