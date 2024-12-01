import { db } from "@/db";
import type { Merge, Post, User } from "@/lib/types";
import { isInstructor } from "@/middlewares/authorization";
import { createValidatedRouter } from "@/lib/utils/createValidatedRouter";
import { singlePostRouter } from "./[postId]";

const router = createValidatedRouter();

router.route("/:postId", singlePostRouter);

router.get("/", async (c) => {
    const courseId = c.req.param("courseId");
    const filter = c.req.query();

    const posts = (
        await db.get_posts<Merge<[Post, User]>>(
            courseId,
            filter["filter:any"],
            filter["filter:id"],
            filter["filter:title"],
            filter["filter:content"],
            filter["filter:posted_by"],
        )
    ).data;

    return c.json({
        message: "Course data is successfully fetched.",
        data: posts.map((post) => ({
            id: post.id,
            title: post.title,
            content: post.content,
            course_id: post.course_id,
            posted_by: {
                id: post.posted_by,
                first_name: post.first_name,
                last_name: post.last_name,
                username: post.username,
                email: post.email,
                role: post.role,
            },
        })),
    });
});

router.use(isInstructor);

router.post("/", async (c) => {
    const body = await c.req.json<Pick<Post, "title" | "content">>();
    const courseId = c.req.param("courseId");
    const user = c.get("user");

    const post = (
        await db.add_post<Post>(user.id, courseId, body.title, body.content)
    ).data[0];

    return c.json({
        message: "Post created successfully",
        data: post,
    });
});

export { router as postsRouter };
