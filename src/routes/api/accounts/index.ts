import type { User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { db } from "@/services";
import { singleAccountRouter } from "./[id]";

const router = createValidatedRouter();

router.route("/:id", singleAccountRouter);

router.get("/", async (c) => {
    const filter = c.req.query();
    const results = await db.get_accounts<User>(
        filter["filter:any"],
        filter["filter:id"],
        filter["filter:username"],
        filter["filter:email"],
        filter["filter:first_name"],
        filter["filter:last_name"],
        filter["filter:role"],
    );

    return c.json({
        message: "Account data is successfully fetched.",
        data: results.data,
    });
});

export { router as accountsRouter };
