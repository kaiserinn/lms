import { Hono } from "hono";
import { logger } from "hono/logger";
import { errorHandler } from "./lib/utils/errorHandler";
import { validateBody } from "./middlewares/validateBody";
import { apiRouter } from "./routes/api";

const app = new Hono();

app.use(logger());

app.onError(errorHandler);

app.use(validateBody);
app.route("/api", apiRouter);

export default {
    port: Bun.env.PORT || 3123,
    fetch: app.fetch,
};
