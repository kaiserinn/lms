export type Branded<TType extends string> = {
    __branded: TType
};

export type User = Branded<'user'> & {
    id: number;
    username: string;
    first_name: string;
    email: string;
    password: string;
    last_name: string;
    role: "ADMIN" | "STUDENT" | "INSTRUCTOR";
};

export type Session = Branded<'session'> & {
    id: string;
    user_id: number;
    expires_at: Date;
};
