import { Hono } from "hono";
import { authRouter } from "./auth";
import { validateSession } from "@/middlewares/validateSession";
import { accountsRouter } from "./accounts";
import { studentsRouter } from "./students";
import { instructorsRouter } from "./instructors";

const router = new Hono();

router.route("/auth", authRouter);
router.use(validateSession);
router.route("/accounts", accountsRouter);
router.route("/students", studentsRouter);
router.route("/instructors", instructorsRouter);

export { router as apiRouter };
