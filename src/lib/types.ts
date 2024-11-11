export type User = {
    id: number;
    username: string;
    first_name: string;
    email: string;
    password: string;
    last_name: string
    role: "ADMIN" | "STUDENT" | "INSTRUCTOR";
};

export type Session = {
    id: string;
    user_id: number;
    expires_at: Date;
};
