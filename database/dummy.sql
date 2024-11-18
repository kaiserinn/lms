INSERT INTO account (username, email, password, first_name, last_name, role) VALUES
('student1', 'student1@example.com', 'password123', 'John', 'Doe', 'STUDENT'),
('student2', 'student2@example.com', 'password123', 'Jane', 'Smith', 'STUDENT'),
('student3', 'student3@example.com', 'password123', 'Alice', 'Johnson', 'STUDENT'),
('student4', 'student4@example.com', 'password123', 'Bob', 'Brown', 'STUDENT'),
('student5', 'student5@example.com', 'password123', 'Eve', 'Davis', 'STUDENT'),
('instructor1', 'instructor1@example.com', 'password123', 'Chris', 'Evans', 'INSTRUCTOR'),
('instructor2', 'instructor2@example.com', 'password123', 'Samuel', 'Jackson', 'INSTRUCTOR'),
('instructor3', 'instructor3@example.com', 'password123', 'Mark', 'Ruffalo', 'INSTRUCTOR'),
('admin1', 'admin1@example.com', 'password123', 'Tony', 'Stark', 'ADMIN'),
('admin2', 'admin2@example.com', 'password123', 'Steve', 'Rogers', 'ADMIN');

INSERT INTO course (name) VALUES
    ('Desain Web'),
    ('Struktur Data'),
    ('Basis Data'),
    ('Grafika Komputer'),
    ('Matematika Diskrit'),
    ('Kalkulus'),
    ('Fisika Dasar'),
    ('Kimia Dasar'),
    ('Arsitektur Komputer'),
    ('Aljabar Linier');

INSERT INTO course_prerequisite (course_id, prerequisite_id) VALUES
    (4, 2),
    (4, 3),
    (5, 2),
    (5, 6),
    (6, 10),
    (7, 6),
    (8, 7),
    (9, 1),
    (9, 3),
    (10, 5);

INSERT INTO enrollment (student_id, course_id, status) VALUES
    (1, 1, 'ACTIVE'),
    (1, 2, 'COMPLETED'),
    (1, 3, 'DROPPED'),
    (1, 4, 'ACTIVE'),
    (1, 5, 'COMPLETED'),

    (2, 4, 'ACTIVE'),
    (2, 5, 'DROPPED'),
    (2, 6, 'COMPLETED'),
    (2, 9, 'ACTIVE'),

    (3, 6, 'COMPLETED'),
    (3, 7, 'ACTIVE'),
    (3, 8, 'COMPLETED'),
    (3, 1, 'ACTIVE'),

    (4, 8, 'COMPLETED'),
    (4, 7, 'ACTIVE'),
    (4, 9, 'DROPPED'),
    (4, 10, 'ACTIVE'),

    (5, 9, 'ACTIVE'),
    (5, 10, 'DROPPED'),
    (5, 1, 'ACTIVE'),
    (5, 2, 'COMPLETED');

INSERT INTO course_instructor (instructor_id, course_id)
VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5);

INSERT INTO course_specification (course_id, type, weight) VALUES
    (1, 'QUIZ', 20), (1, 'MID_TERM', 40), (1, 'FINAL', 40),
    (2, 'QUIZ', 20), (2, 'MID_TERM', 40), (2, 'FINAL', 40),
    (3, 'QUIZ', 20), (3, 'MID_TERM', 40), (3, 'FINAL', 40),
    (4, 'QUIZ', 20), (4, 'MID_TERM', 40), (4, 'FINAL', 40),
    (5, 'QUIZ', 20), (5, 'MID_TERM', 40), (5, 'FINAL', 40),
    (6, 'QUIZ', 20), (6, 'MID_TERM', 40), (6, 'FINAL', 40),
    (7, 'QUIZ', 20), (7, 'MID_TERM', 40), (7, 'FINAL', 40),
    (8, 'QUIZ', 20), (8, 'MID_TERM', 40), (8, 'FINAL', 40),
    (9, 'QUIZ', 20), (9, 'MID_TERM', 40), (9, 'FINAL', 40),
    (10, 'QUIZ', 20), (10, 'MID_TERM', 40), (10, 'FINAL', 40);

INSERT INTO assignment (type, due_date, course_id, title) VALUES
    ('QUIZ', '2024-10-30 23:59:59', 1, 'Desain Web Quiz 1'),
    ('MID_TERM', '2024-11-15 23:59:59', 1, 'Desain Web Mid-Term Exam'),
    ('FINAL', '2024-12-15 23:59:59', 1, 'Desain Web Final Exam'),

    ('QUIZ', '2024-10-31 23:59:59', 2, 'Struktur Data Quiz 1'),
    ('MID_TERM', '2024-11-16 23:59:59', 2, 'Struktur Data Mid-Term Exam'),
    ('FINAL', '2024-12-16 23:59:59', 2, 'Struktur Data Final Exam'),

    ('QUIZ', '2024-11-01 23:59:59', 3, 'Basis Data Quiz 1'),
    ('MID_TERM', '2024-11-17 23:59:59', 3, 'Basis Data Mid-Term Exam'),
    ('FINAL', '2024-12-17 23:59:59', 3, 'Basis Data Final Exam'),

    ('QUIZ', NOW(), 4, 'Grafika Komputer Quiz 1'),
    ('MID_TERM', '2024-11-18 23:59:59', 4, 'Grafika Komputer Mid-Term Exam'),
    ('FINAL', '2024-12-18 23:59:59', 4, 'Grafika Komputer Final Exam'),

    ('QUIZ', '2024-11-03 23:59:59', 5, 'Matematika Diskrit Quiz 1'),
    ('MID_TERM', '2024-11-19 23:59:59', 5, 'Matematika Diskrit Mid-Term Exam'),
    ('FINAL', '2024-12-19 23:59:59', 5, 'Matematika Diskrit Final Exam'),

    ('QUIZ', '2024-11-04 23:59:59', 6, 'Kalkulus Quiz 1'),
    ('MID_TERM', '2024-11-20 23:59:59', 6, 'Kalkulus Mid-Term Exam'),
    ('FINAL', '2024-12-20 23:59:59', 6, 'Kalkulus Final Exam'),

    ('QUIZ', '2024-11-05 23:59:59', 7, 'Fisika Dasar Quiz 1'),
    ('MID_TERM', '2024-11-21 23:59:59', 7, 'Fisika Dasar Mid-Term Exam'),
    ('FINAL', '2024-12-21 23:59:59', 7, 'Fisika Dasar Final Exam'),

    ('QUIZ', '2024-11-06 23:59:59', 8, 'Kimia Dasar Quiz 1'),
    ('MID_TERM', '2024-11-22 23:59:59', 8, 'Kimia Dasar Mid-Term Exam'),
    ('FINAL', '2024-12-22 23:59:59', 8, 'Kimia Dasar Final Exam'),

    ('QUIZ', '2024-11-07 23:59:59', 9, 'Arsitektur Komputer Quiz 1'),
    ('MID_TERM', '2024-11-23 23:59:59', 9, 'Arsitektur Komputer Mid-Term Exam'),
    ('FINAL', '2024-12-23 23:59:59', 9, 'Arsitektur Komputer Final Exam'),

    ('QUIZ', '2024-11-08 23:59:59', 10, 'Aljabar Linier Quiz 1'),
    ('MID_TERM', '2024-11-24 23:59:59', 10, 'Aljabar Linier Mid-Term Exam'),
    ('FINAL', '2024-12-24 23:59:59', 10, 'Aljabar Linier Final Exam');

INSERT INTO grade (grade, min_score, max_score) VALUES
    ('A', 86, 100),
    ('AB', 76, 85),
    ('B', 66, 75),
    ('BC', 56, 65),
    ('C', 51, 55),
    ('D', 41, 50),
    ('E', 0, 40);

INSERT INTO submission (status, score, submitted_by, assignment_id)
VALUES
    ('GRADED', 86, 1, 4),
    ('GRADED', 75, 1, 5),
    ('GRADED', 60, 1, 6),
    ('GRADED', 70, 1, 13),
    ('GRADED', 90, 1, 14),
    ('GRADED', 90, 1, 15);

