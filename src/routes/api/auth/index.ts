import { validateSession } from "@/middlewares/validateSession";
import { Hono } from "hono";
import { loginRouter } from "./login";
import { logoutRouter } from "./logout";
import { registerRouter } from "./register";

const router = new Hono();

router.route("/register", registerRouter);
router.route("/login", loginRouter);
router.use(validateSession);
router.route("/logout", logoutRouter);

export { router as authRouter };
