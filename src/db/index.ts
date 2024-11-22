import mysql, {
    type ProcedureCallPacket,
    type ResultSetHeader,
} from "mysql2/promise";
import type { Branded } from "@/lib/types";

export const pool = mysql.createPool({
    host: Bun.env.DB_HOST,
    port: Number(Bun.env.DB_PORT),
    user: Bun.env.DB_USER,
    password: Bun.env.DB_PASSWORD,
    database: Bun.env.DB_NAME,
});

export async function call<TData extends Branded<string> | Branded<string>[]>(
    name: string,
    ...params: unknown[]
) {
    const [queryResult] = await pool.query<ProcedureCallPacket>(
        `CALL ${name}(${params.map((_) => "?").join(", ")})`,
        params,
    );

    type TypedData<T> = Omit<T, "__branded">;
    type TypedResult<TData> = TData extends unknown[]
        ? {
            [Key in keyof TData]: TypedData<TData[Key]>[];
        }
        : TypedData<TData>[];

    if (Array.isArray(queryResult)) {
        const result = queryResult.length > 2 ? queryResult : queryResult[0];
        return {
            data: result as unknown as TypedResult<TData>,
            setHeader: queryResult.pop() as ResultSetHeader,
        };
    }

    return {
        data: [] as unknown as TypedResult<TData>,
        setHeader: queryResult,
    };
}

export const db = new Proxy(
    {},
    {
        get(_, name: string) {
            return (...params: unknown[]) => call(name, params);
        },
    },
) as Record<
    string,
    <TData extends Branded<string> | Branded<string>[]>(
        ...params: unknown[]
    ) => ReturnType<typeof call<TData>>
>;
