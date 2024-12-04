import { db } from "@/db";
import type { Course } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isAdmin } from "@/middlewares/authorization";
import { singleCourseRouter } from "./[courseId]";

const router = createValidatedRouter();

router.route("/:courseId", singleCourseRouter);

router.get("/", async (c) => {
    const filters = c.req.query();
    const results = await db.get_courses<Course>(
        filters["filter:any"],
        filters["filter:id"],
        filters["filter:name"],
        filters["filter:description"],
    );

    return c.json({
        message: "Course data is successfully fetched.",
        data: results.data,
    });
});

router.use(isAdmin);

router.post("/", async (c) => {
    const body = await c.req.json<Course>();

    const course = (await db.add_course<Course>(body.name, body.description))
        .data[0];

    return c.json({
        message: "Course created successfully",
        data: course,
    });
});

export { router as coursesRouter };
