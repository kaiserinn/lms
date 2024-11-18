import mysql from "mysql2/promise";

export const pool = mysql.createPool({
    host: "localhost",
    port: 3306,
    user: "monty",
    password: "some_pass",
    database: "lms",
    multipleStatements: true
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
