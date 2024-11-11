import { Hono } from "hono";
import { loginRouter } from "./login";
import { registerRouter } from "./register";
import { logoutRouter } from "./logout";

const router = new Hono();

router.route("/register", registerRouter);
router.route("/login", loginRouter);
router.route("/logout", logoutRouter);

export { router as authRouter };
