import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { logger } from "hono/logger";
import { apiRouter } from "./routes/api";

const app = new Hono();

app.use(logger());

app.onError((err, c) => {
    if (err instanceof HTTPException) {
        return c.json({ error: err.message }, err.status);
    }

    if (err instanceof Error) {
        if ("sqlState" in err && err.sqlState === "45000") {
            return c.json({ error: err.message }, 400);
        }
    }

    console.error(err);
    return c.json({ error: "Internal server error." }, 500);
});

app.route("/api", apiRouter);

export default {
    port: Bun.env.PORT || 3123,
    fetch: app.fetch,
};
