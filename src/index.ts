import { Hono } from "hono";
import { logger } from "hono/logger";
import { apiRouter } from "./routes/api";
import { errorHandler } from "./lib/utils/errorHandler";

const app = new Hono();

app.use(logger());

app.onError(errorHandler);

app.route("/api", apiRouter);

export default {
    port: Bun.env.PORT || 3123,
    fetch: app.fetch,
};
