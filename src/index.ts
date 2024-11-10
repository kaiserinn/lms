import { Hono } from "hono";
import { logger } from "hono/logger";
import { apiRouter } from "./routes/api";

const app = new Hono();

app.use(logger());

app.route("/api", apiRouter);

export default {
    port: Bun.env.PORT || 3123,
    fetch: app.fetch,
};
