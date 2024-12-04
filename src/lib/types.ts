type MergeRest<T> = T extends [infer Head, ...infer Rest]
    ? Omit<Head, "id"> & MergeRest<Rest>
    : unknown;

export type Merge<T extends Record<string, unknown>[]> = T extends [
    infer Head,
    ...infer Rest,
]
    ? Head & MergeRest<Rest>
    : never;

export type User = {
    id: number;
    username: string;
    email: string;
    password: string;
    first_name: string | null;
    last_name: string | null;
    role: "ADMIN" | "STUDENT" | "INSTRUCTOR";
};

export type Session = {
    id: string;
    user_id: number;
    expires_at: Date;
};

export type Course = {
    id: number;
    name: string;
    description: string | null;
};

export type CoursePrerequisite = {
    id: number;
    course_id: number;
    prerequisite_id: number;
};

export type CourseSpecification = {
    id: number;
    course_id: number;
    type: "QUIZ" | "MID_TERM" | "FINAL";
    weight: number;
};

export type LetterGrade = "A" | "AB" | "B" | "BC" | "C" | "D" | "E";

export type Grade = {
    min_score: number;
    max_score: number;
    grade: LetterGrade;
};

export type Enrollment = {
    id: number;
    student_id: number;
    course_id: number;
    status: "ACTIVE" | "COMPLETED" | "DROPPED";
};

export type CourseInstructor = {
    id: number;
    instructor_id: number;
    course_id: number;
};

export type Assignment = {
    id: number;
    type: "QUIZ" | "MID_TERM" | "FINAL";
    title: string;
    content: string | null;
    due_date: Date | null;
    course_id: Course | number;
    created_by: User | number;
    attachment_id: Attachment | number | null;
};

export type Submission = {
    id: number;
    score: number | null;
    status: "GRADED" | "NOT GRADED";
    title: string;
    content: string;
    submitted_by: User | number;
    submitted_at: Date;
    assignment_id: Assignment | number;
};

export type Post = {
    id: number;
    title: string;
    content: string | null;
    posted_by: User | number;
    course_id: Course | number;
};

export type Attachment = {
    id: number;
    file_name: string;
    file_path: string;
    owner: User | number;
};
