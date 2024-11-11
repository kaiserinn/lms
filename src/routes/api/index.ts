import { Hono } from "hono";
import { authRouter } from "./auth";
import { call } from "@/db";

const router = new Hono();

router.route("/auth", authRouter);

export { router as apiRouter };

