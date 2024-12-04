import { validateSession } from "@/middlewares/validateSession";
import { Hono } from "hono";
import { accountsRouter } from "./accounts";
import { authRouter } from "./auth";
import { coursesRouter } from "./courses";
import { filesRouter } from "./files";
import { instructorsRouter } from "./instructors";
import { meRouter } from "./me";
import { studentsRouter } from "./students";

const router = new Hono();

router.route("/auth", authRouter);
router.use(validateSession);
router.route("/accounts", accountsRouter);
router.route("/students", studentsRouter);
router.route("/instructors", instructorsRouter);
router.route("/me", meRouter);
router.route("/courses", coursesRouter);
router.route("/files", filesRouter);

export { router as apiRouter };
