import mysql from "mysql2/promise";

export const db = await mysql.createConnection({
    host: Bun.env.DB_HOST || "localhost",
    port: Number(Bun.env.DB_PORT || "3306"),
    user: Bun.env.DB_USER || "monty",
    password: Bun.env.DB_PASSWORD || "some_pass",
    database: Bun.env.DB_NAME || "lms"
});
