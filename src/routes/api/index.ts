import { Hono } from "hono";
const router = new Hono();

router.get("/", (c) => c.text("Hello, World!"));

export { router as apiRouter };

