import mysql, {
    type ProcedureCallPacket,
    type ResultSetHeader,
} from "mysql2/promise";

export const pool = mysql.createPool({
    host: Bun.env.DB_HOST,
    port: Number(Bun.env.DB_PORT),
    user: Bun.env.DB_USER,
    password: Bun.env.DB_PASSWORD,
    database: Bun.env.DB_NAME,
});

type ReturnedResult = Record<string, unknown>;

export async function call<TData extends ReturnedResult | ReturnedResult[]>(
    name: string,
    ...params: unknown[]
) {
    const [queryResult] = await pool.query<ProcedureCallPacket>(
        `CALL ${name}(${params.map((_) => "?").join(", ")})`,
        params,
    );

    type TypedResult<TData> = TData extends unknown[]
        ? {
            [Key in keyof TData]: TData[Key][];
        }
        : TData[];

    if (Array.isArray(queryResult)) {
        const result = queryResult.length > 2 ? queryResult : queryResult[0];
        return {
            data: result as TypedResult<TData>,
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
    <TData extends ReturnedResult | ReturnedResult[]>(
        ...params: unknown[]
    ) => ReturnType<typeof call<TData>>
>;
