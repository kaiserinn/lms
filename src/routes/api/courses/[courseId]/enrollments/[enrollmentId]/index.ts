import type { Enrollment } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { db } from "@/services";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const id = c.req.param("enrollmentId");
    const enrollment = (await db.get_enrollment<Enrollment>(id)).data[0];

    return c.json({
        message: `Enrollment with ID ${id} fetched successfully.`,
        data: enrollment,
    });
});

export { router as singleEnrollmentRoute };
