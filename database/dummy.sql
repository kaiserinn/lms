INSERT INTO account (username, email, password, first_name, last_name, role) VALUES
    ('student1', 'student1@example.com', PASSWORD('password'), 'John', 'Doe', 'STUDENT'),
    ('student2', 'student2@example.com', PASSWORD('password'), 'Jane', 'Smith', 'STUDENT'),
    ('student3', 'student3@example.com', PASSWORD('password'), 'Alice', 'Johnson', 'STUDENT'),
    ('student4', 'student4@example.com', PASSWORD('password'), 'Bob', 'Brown', 'STUDENT'),
    ('student5', 'student5@example.com', PASSWORD('password'), 'Eve', 'Davis', 'STUDENT'),
    ('instructor1', 'instructor1@example.com', PASSWORD('password'), 'Chris', 'Evans', 'INSTRUCTOR'),
    ('instructor2', 'instructor2@example.com', PASSWORD('password'), 'Samuel', 'Jackson', 'INSTRUCTOR'),
    ('instructor3', 'instructor3@example.com', PASSWORD('password'), 'Mark', 'Ruffalo', 'INSTRUCTOR'),
    ('admin1', 'admin1@example.com', PASSWORD('password'), 'Tony', 'Stark', 'ADMIN'),
    ('admin2', 'admin2@example.com', PASSWORD('password'), 'Steve', 'Rogers', 'ADMIN');

INSERT INTO course (id, name) VALUES
    (1, 'Desain Web'),
    (2, 'Struktur Data'),
    (3, 'Basis Data'),
    (4, 'Grafika Komputer'),
    (5, 'Matematika Diskrit'),
    (6, 'Kalkulus'),
    (7, 'Fisika Dasar'),
    (8, 'Kimia Dasar'),
    (9, 'Arsitektur Komputer'),
    (10, 'Aljabar Linier');

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
    (6, 1),
    (7, 1),
    (8, 1),
    (6, 2),
    (8, 2),
    (7, 3),
    (8, 4),
    (8, 5);

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

INSERT INTO assignment (type, due_date, course_id, title, created_by) VALUES
    ('QUIZ', '2025-10-30 23:59:59', 1, 'Desain Web Quiz 1', 6),
    ('MID_TERM', '2025-11-15 23:59:59', 1, 'Desain Web Mid-Term Exam', 7),
    ('FINAL', '2025-12-15 23:59:59', 1, 'Desain Web Final Exam', 8),

    ('QUIZ', '2024-10-31 23:59:59', 2, 'Struktur Data Quiz 1', 6),
    ('MID_TERM', '2024-11-16 23:59:59', 2, 'Struktur Data Mid-Term Exam', 8),
    ('FINAL', '2024-12-16 23:59:59', 2, 'Struktur Data Final Exam', 8),

    ('QUIZ', '2024-11-01 23:59:59', 3, 'Basis Data Quiz 1', 7),
    ('MID_TERM', '2024-11-17 23:59:59', 3, 'Basis Data Mid-Term Exam', 7),
    ('FINAL', '2024-12-17 23:59:59', 3, 'Basis Data Final Exam', 7),

    ('QUIZ', NOW(), 4, 'Grafika Komputer Quiz 1', 8),
    ('MID_TERM', '2024-11-18 23:59:59', 4, 'Grafika Komputer Mid-Term Exam', 8),
    ('FINAL', '2024-11-18 23:59:59', 4, 'Grafika Komputer Final Exam', 8),

    ('QUIZ', '2024-11-03 23:59:59', 5, 'Matematika Diskrit Quiz 1', 8),
    ('MID_TERM', '2024-11-19 23:59:59', 5, 'Matematika Diskrit Mid-Term Exam', 8),
    ('FINAL', '2024-12-19 23:59:59', 5, 'Matematika Diskrit Final Exam', 8),

    ('QUIZ', '2024-11-04 23:59:59', 6, 'Kalkulus Quiz 1', 6),
    ('MID_TERM', '2024-11-20 23:59:59', 6, 'Kalkulus Mid-Term Exam', 6),
    ('FINAL', '2024-12-20 23:59:59', 6, 'Kalkulus Final Exam', 6),

    ('QUIZ', '2024-11-05 23:59:59', 7, 'Fisika Dasar Quiz 1', 7),
    ('MID_TERM', '2024-11-21 23:59:59', 7, 'Fisika Dasar Mid-Term Exam', 7),
    ('FINAL', '2024-12-21 23:59:59', 7, 'Fisika Dasar Final Exam', 7),

    ('QUIZ', '2024-11-06 23:59:59', 8, 'Kimia Dasar Quiz 1', 8),
    ('MID_TERM', '2024-11-22 23:59:59', 8, 'Kimia Dasar Mid-Term Exam', 8),
    ('FINAL', '2024-12-22 23:59:59', 8, 'Kimia Dasar Final Exam', 8),

    ('QUIZ', '2024-11-07 23:59:59', 9, 'Arsitektur Komputer Quiz 1', 8),
    ('MID_TERM', '2024-11-23 23:59:59', 9, 'Arsitektur Komputer Mid-Term Exam', 8),
    ('FINAL', '2024-12-23 23:59:59', 9, 'Arsitektur Komputer Final Exam', 8),

    ('QUIZ', '2024-11-08 23:59:59', 10, 'Aljabar Linier Quiz 1', 8),
    ('MID_TERM', '2024-11-24 23:59:59', 10, 'Aljabar Linier Mid-Term Exam', 8),
    ('FINAL', '2024-12-24 23:59:59', 10, 'Aljabar Linier Final Exam', 8);

INSERT INTO grade (grade, min_score, max_score) VALUES
    ('A', 86, 100),
    ('AB', 76, 85),
    ('B', 66, 75),
    ('BC', 56, 65),
    ('C', 51, 55),
    ('D', 41, 50),
    ('E', 0, 40);

INSERT INTO submission (status, score, submitted_by, assignment_id, title, content)
VALUES
    ('GRADED', 86, 1, 4, 'Quiz Submission: Desain Web Quiz 1', 'Completed the quiz with all required answers.'),
    ('GRADED', 75, 1, 5, 'Mid-Term Submission: Desain Web Mid-Term', 'Submitted answers for the mid-term exam.'),
    ('GRADED', 60, 1, 6, 'Final Exam Submission: Desain Web Final', 'Completed the final exam. Some questions were skipped.'),
    ('GRADED', 70, 1, 13, 'Quiz Submission: Matematika Diskrit Quiz 1', 'Finished the quiz with detailed solutions.'),
    ('GRADED', 90, 1, 14, 'Mid-Term Submission: Matematika Diskrit Mid-Term', 'Answered all questions in the mid-term.'),
    ('GRADED', 90, 1, 15, 'Final Exam Submission: Matematika Diskrit Final', 'Well-prepared for the final exam.'),

    ('GRADED', 84, 2, 16, 'Quiz Submission: Kalkulus Quiz 1', 'Detailed solutions were provided for all quiz questions.'),
    ('GRADED', 95, 2, 17, 'Mid-Term Submission: Kalkulus Mid-Term', 'Scored excellently on the mid-term exam.'),
    ('GRADED', 70, 2, 18, 'Final Exam Submission: Kalkulus Final', 'The final exam was challenging but manageable.'),

    ('GRADED', 92, 3, 16, 'Quiz Submission: Kalkulus Quiz 1', 'All questions solved with precision.'),
    ('GRADED', 88, 3, 17, 'Mid-Term Submission: Kalkulus Mid-Term', 'Provided answers to all sections of the mid-term.'),
    ('GRADED', 90, 3, 18, 'Final Exam Submission: Kalkulus Final', 'High-quality responses in the final exam.'),

    ('GRADED', 82, 3, 22, 'Quiz Submission: Grafika Komputer Quiz 1', 'Solid performance in the computer graphics quiz.'),
    ('GRADED', 78, 3, 23, 'Mid-Term Submission: Grafika Komputer Mid-Term', 'Successfully tackled all mid-term challenges.'),
    ('GRADED', 80, 3, 24, 'Final Exam Submission: Grafika Komputer Final', 'Answers were comprehensive and detailed.'),

    ('GRADED', 72, 4, 22, 'Quiz Submission: Grafika Komputer Quiz 1', 'Attempted most questions with good accuracy.'),
    ('GRADED', 88, 4, 23, 'Mid-Term Submission: Grafika Komputer Mid-Term', 'Mid-term exam was completed successfully.'),
    ('GRADED', 70, 4, 24, 'Final Exam Submission: Grafika Komputer Final', 'Final exam was moderately challenging.'),

    ('GRADED', 75, 5, 4, 'Quiz Submission: Desain Web Quiz 1', 'Additional attempt to perfect previous submission.'),
    ('GRADED', 95, 5, 5, 'Mid-Term Submission: Desain Web Mid-Term', 'Revised submission with improved answers.'),
    ('GRADED', 72, 5, 6, 'Final Exam Submission: Desain Web Final', 'Updated final exam answers for clarity.');

INSERT INTO post (title, content, course_id, posted_by) VALUES
-- Posts related to course 1: 'Desain Web' (Instructors: 6, 7, 8)
('Welcome to Desain Web', 'Welcome to the Desain Web course! Feel free to ask questions.', 1, 6),
('Desain Web Quiz Reminder', 'Reminder: Complete the quiz by the due date.', 1, 7),

-- Posts related to course 2: 'Struktur Data' (Instructors: 6, 8)
('Introduction to Struktur Data', 'This course will cover essential data structures.', 2, 6),
('Mid-Term Exam Preparation', 'Here are tips and resources for the mid-term exam.', 2, 8),

-- Posts related to course 3: 'Basis Data' (Instructor: 7)
('Database Normalization Basics', 'Learn the fundamentals of database normalization.', 3, 7),
('Final Exam Guidelines', 'The final exam will be comprehensive and cover all topics.', 3, 7),

-- Posts related to course 4: 'Grafika Komputer' (Instructor: 8)
('Intro to Computer Graphics', 'This post introduces the exciting world of computer graphics.', 4, 8),
('Quiz 1 Solutions Discussion', 'Join us for a discussion on the solutions for Quiz 1.', 4, 8),

-- Posts related to course 5: 'Matematika Diskrit' (Instructor: 8)
('Welcome to Matematika Diskrit', 'Let’s dive into discrete mathematics together!', 5, 8),
('Mid-Term Tips and Tricks', 'Some tips to ace the mid-term exam.', 5, 8);
