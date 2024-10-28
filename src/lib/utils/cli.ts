import mysql from "mysql2/promise";

export const pool = mysql.createPool({
    host: Bun.env.DB_HOST,
    port: Number(Bun.env.DB_PORT),
    user: Bun.env.DB_CLI_USER,
    password: Bun.env.DB_CLI_PASSWORD,
    database: Bun.env.DB_NAME,
    multipleStatements: true,
});

async function executeFile(filePath: string) {
    const file = Bun.file(filePath);
    await pool.query(await file.text());
}

const action = Bun.argv[2];

try {
    if (action === "drop" || action === "all") {
        await executeFile("./database/db.sql");
        console.log("Database dropped");
    }

    if (action === "seed" || action === "all") {
        await executeFile("./database/dummy.sql");
        console.log("Database seeded");
    }
} catch (error) {
    console.error("Error executing files:\n", error);
}

pool.end();
