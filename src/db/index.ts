import mysql, { type ProcedureCallPacket, type RowDataPacket } from "mysql2/promise";

export const conn = await mysql.createConnection({
    host: Bun.env.DB_HOST || "localhost",
    port: Number(Bun.env.DB_PORT || "3306"),
    user: Bun.env.DB_USER || "monty",
    password: Bun.env.DB_PASSWORD || "some_pass",
    database: Bun.env.DB_NAME || "lms",
});

export async function call<TData>(name: string, ...params: unknown[]) {
    return conn.query<ProcedureCallPacket<(TData & RowDataPacket)[]>>(
        `CALL ${name}(${params.map(_ => "?").join(", ")})`,
        params
    );
}

export const db = new Proxy({}, {
    get: (_, name) => (...params: unknown[]) => call(name as string, params)
}) as Record<
    string,
    <TData>(...params: unknown[]) => ReturnType<typeof call<TData>>
>;
