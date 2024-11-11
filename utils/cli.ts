import { conn } from "@/db";

async function executeFile(filePath: string) {
    const file = Bun.file(filePath);
    const statements = (await file.text()).split("$$");

    for (const statement of statements) {
        const trimmed = statement.trim();
        if (trimmed && trimmed !== "DELIMITER") {
            await conn.query(trimmed);
        }
    }
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

conn.end();
