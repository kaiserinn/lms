import { Hono } from "hono";
import { authRouter } from "./auth";
import { validateSession } from "@/middlewares/validateSession";
import { coursesRouter } from "./courses";
import { accountsRouter } from "./accounts";
import { meRouter } from "./me";
import { studentsRouter } from "./students";
import { instructorsRouter } from "./instructors";

const router = new Hono();

router.route("/auth", authRouter);
router.use(validateSession);
router.route("/accounts", accountsRouter);
router.route("/students", studentsRouter);
router.route("/instructors", instructorsRouter);
router.route("/me", meRouter);
router.route("/courses", coursesRouter);

export { router as apiRouter };
