import { db } from "@/db";
import type { Enrollment } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isStudent } from "@/middlewares/authorization";
import { HTTPException } from "hono/http-exception";
import { singleEnrollmentRoute } from "./[enrollmentId]";

const router = createValidatedRouter();

router.route("/:enrollmentId", singleEnrollmentRoute);

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const results = await db.get_enrollments<Enrollment>(courseId);

    return c.json({
        message: "Enrollment data fetched successfully.",
        data: results.data,
    });
});

router.post("/:studentId", isStudent, async (c) => {
    const courseId = c.req.param("courseId");
    const studentId = c.req.param("studentId");

    const user = c.get("user");

    if (user.role === "STUDENT" && user.id !== Number(studentId)) {
        throw new HTTPException(403, {
            message: "You are not authorized to access this resource.",
        });
    }

    await db.enroll_student_to_course(studentId, courseId);

    return c.json({
        message: "Course enrolled successfully",
    });
});

export { router as enrollmentsRouter };
