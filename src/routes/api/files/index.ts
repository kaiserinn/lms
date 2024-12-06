import { extname } from "node:path";
import type { Attachment, Merge, User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { nanoid } from "@/lib/utils/nanoid";
import { db } from "@/services";
import { serveStatic } from "hono/bun";
import { HTTPException } from "hono/http-exception";

const UPLOAD_DIR = "public/uploads";
const ALLOWED_FILE_TYPES = [".jpg", ".jpeg", ".png", ".pdf", ".webp", ".zip"];
const MAX_FILE_SIZE = 10 * 1000 * 1000; // 10 MB

const router = createValidatedRouter();

router.get(
    "/*",
    serveStatic({
        root: "./",
        rewriteRequestPath: (path) =>
            path.replace(/^\/api\/files/, "/public/uploads"),
    }),
);

router.post("/", async (c) => {
    const contentType = c.req.header("Content-Type") ?? "";
    if (!contentType?.startsWith("multipart/form-data")) {
        throw new HTTPException(415, {
            message: "Unsupported Media Type",
        });
    }

    const body = await c.req.parseBody();
    const file = body.file as File | undefined;

    if (!file) {
        throw new HTTPException(400, {
            message: "File is required.",
        });
    }

    if (file.size > MAX_FILE_SIZE) {
        throw new HTTPException(413, {
            message: "File is too large.",
        });
    }

    const fileExtension = extname(file.name).toLowerCase();
    if (!ALLOWED_FILE_TYPES.includes(fileExtension)) {
        throw new HTTPException(415, {
            message: "Unsupported file type.",
        });
    }

    const sanitizedFileName = file.name
        .replace(/\s+/g, "_")
        .replace(/[^a-zA-Z0-9_.-]/g, "");
    const newFileName = `${nanoid()}_${sanitizedFileName}`;

    await Bun.write(`${UPLOAD_DIR}/${newFileName}`, file);

    const user = c.get("user");
    const attachment = (
        await db.add_attachment<Merge<[Attachment, User]>>(
            user.id,
            newFileName,
            `public/uploads/${newFileName}`,
        )
    ).data[0];

    return c.json({
        id: attachment.id,
        file_name: attachment.file_name,
        file_path: attachment.file_path,
        owner: {
            id: attachment.owner,
            first_name: attachment.first_name,
            last_name: attachment.last_name,
            username: attachment.username,
            email: attachment.email,
            role: attachment.role,
        },
    });
});

export { router as filesRouter };
