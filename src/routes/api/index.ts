import { Hono } from "hono";
import { authRouter } from "./auth";
import { validateSession } from "@/middlewares/validateSession";
import { accountsRouter } from "./accounts";

const router = new Hono();

router.route("/auth", authRouter);
router.use(validateSession);
router.route("/accounts", accountsRouter);

export { router as apiRouter };
