import type { Course, CourseInstructor, User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { db } from "@/services";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const id = c.req.param("courseInstructorId");

    type JoinedCourseInstructor = CourseInstructor &
        Pick<User, "first_name" | "last_name"> &
        Omit<Course, "description">;

    const courseInstructor = (
        await db.get_course_instructor<JoinedCourseInstructor>(id)
    ).data[0];

    if (!courseInstructor) {
        return c.json({
            message: `No course's instructor found with ID ${id} on this course.`,
        });
    }

    return c.json({
        message: `Course's instructor with ID ${id} fetched successfully.`,
        data: courseInstructor,
    });
});

export { router as singleCourseInstructorRouter };
