import mysql, {
    type ProcedureCallPacket,
    type RowDataPacket,
} from "mysql2/promise";

export const pool = mysql.createPool({
    host: Bun.env.DB_HOST,
    port: Number(Bun.env.DB_PORT),
    user: Bun.env.DB_USER,
    password: Bun.env.DB_PASSWORD,
    database: Bun.env.DB_NAME,
});

export async function call<TData>(name: string, ...params: unknown[]) {
    return pool.query<ProcedureCallPacket<(TData & RowDataPacket)[]>>(
        `CALL ${name}(${params.map((_) => "?").join(", ")})`,
        params,
    );
}

export const db = new Proxy(
    {},
    {
        get(_, name) {
            return (...params: unknown[]) => call(name as string, params);
        },
    },
) as Record<
    string,
    <TData>(...params: unknown[]) => ReturnType<typeof call<TData>>
>;
