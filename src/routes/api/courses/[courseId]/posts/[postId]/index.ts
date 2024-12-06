import type { Course, Merge, Post, User } from "@/lib/types";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { isInstructor } from "@/middlewares/authorization";
import { db } from "@/services";
import { HTTPException } from "hono/http-exception";

const router = createValidatedRouter();

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const postId = c.req.param("postId");

    const post = (
        await db.get_post<Merge<[Post, User, Course]>>(courseId, postId)
    ).data[0];

    return c.json({
        message: `Post with ID ${postId} fetched successfully`,
        data: {
            id: post.id,
            title: post.title,
            content: post.content,
            course_id: {
                id: post.course_id,
                name: post.name,
                description: post.description,
            },
            posted_by: {
                id: post.posted_by,
                first_name: post.first_name,
                last_name: post.last_name,
                username: post.username,
                email: post.email,
                role: post.role,
            },
        },
    });
});

router.use(isInstructor);

router.patch("/", async (c) => {
    const body = await c.req.json<Pick<Post, "title" | "content">>();
    const postId = c.req.param("postId");
    const courseId = c.req.param("courseId");
    const user = c.get("user");

    const post = (
        await db.edit_post<Post>(
            user.id,
            postId,
            courseId,
            body.title,
            body.content,
        )
    ).data[0];

    return c.json({
        message: "Post updated successfully",
        data: post,
    });
});

router.delete("/", async (c) => {
    const postId = c.req.param("postId");
    const courseId = c.req.param("courseId");
    const user = c.get("user");
    const setHeader = (await db.delete_post(user.id, postId, courseId))
        .setHeader;

    if (!setHeader.affectedRows) {
        throw new HTTPException(404, {
            message: `No post found with ID ${postId}`,
        });
    }

    return c.json({
        message: `Post with ID ${postId} deleted successfully`,
    });
});

export { router as singlePostRouter };
