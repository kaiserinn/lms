DROP DATABASE IF EXISTS lms;
CREATE DATABASE lms;
USE lms;

DROP TABLE IF EXISTS account;
CREATE TABLE account (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    role ENUM('ADMIN', 'INSTRUCTOR', 'STUDENT') NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

DROP TABLE IF EXISTS session;
CREATE TABLE session (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES account(id)
);

DROP TABLE IF EXISTS course;
CREATE TABLE course (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

DROP TABLE IF EXISTS enrollment;
CREATE TABLE enrollment (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    student_id INT UNSIGNED NOT NULL,
    course_id INT UNSIGNED NOT NULL,
    status ENUM('ACTIVE', 'COMPLETED', 'DROPPED'),
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(student_id) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS course_instructor;
CREATE TABLE course_instructor (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    instructor_id INT UNSIGNED NOT NULL,
    course_id INT UNSIGNED NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(instructor_id) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS course_prerequisite;
CREATE TABLE course_prerequisite (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    course_id INT UNSIGNED NOT NULL,
    prerequisite_id INT UNSIGNED NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE,
    FOREIGN KEY(prerequisite_id) REFERENCES course(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS course_specification;
CREATE TABLE course_specification (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    course_id INT UNSIGNED NOT NULL,
    type ENUM('QUIZ', 'MID_TERM', 'FINAL') NOT NULL,
    weight TINYINT UNSIGNED NOT NULL CHECK (weight BETWEEN 0 AND 100),
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS attachment;
CREATE TABLE attachment (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    file_path VARCHAR(255) NOT NULL,
    owner INT UNSIGNED NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(owner) REFERENCES account(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS assignment;
CREATE TABLE assignment (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    type ENUM('QUIZ', 'MID_TERM', 'FINAL') NOT NULL,
    title VARCHAR(255),
    detail TEXT,
    due_date DATETIME,
    course_id INT UNSIGNED NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS post;
CREATE TABLE post (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    attachment_id INT UNSIGNED,
    course_id INT UNSIGNED NOT NULL,
    posted_by INT UNSIGNED NOT NULL,
    assignment_id INT UNSIGNED,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(attachment_id) REFERENCES attachment(id) ON DELETE CASCADE,
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE,
    FOREIGN KEY(posted_by) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY(assignment_id) REFERENCES assignment(id) ON DELETE SET NULL
);

DROP TABLE IF EXISTS grade;
CREATE TABLE grade (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    grade CHAR(2) NOT NULL,
    min_score TINYINT UNSIGNED NOT NULL,
    max_score TINYINT UNSIGNED NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    CHECK (min_score >= 0 AND max_score <= 100 AND min_score <= max_score)
);

DROP TABLE IF EXISTS submission;
CREATE TABLE submission (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    status ENUM('GRADED', 'NOT GRADED'),
    score TINYINT UNSIGNED CHECK (score BETWEEN 0 AND 100),
    grade_id INT UNSIGNED,
    submitted_at timestamp DEFAULT NOW(),
    submitted_by INT UNSIGNED NOT NULL,
    assignment_id INT UNSIGNED NOT NULL,
    attachment_id INT UNSIGNED,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    FOREIGN KEY(attachment_id) REFERENCES attachment(id) ON DELETE CASCADE,
    FOREIGN KEY(submitted_by) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY(assignment_id) REFERENCES assignment(id),
    FOREIGN KEY(grade_id) REFERENCES grade(id) ON DELETE CASCADE
);

CREATE OR REPLACE VIEW enrollment_view AS
    SELECT c.id, c.name, e.status, e.student_id
    FROM enrollment e
    INNER JOIN course c ON e.course_id = c.id;

CREATE OR REPLACE VIEW instructor_course_view AS
    SELECT c.id, c.name, ci.instructor_id
    FROM course_instructor ci
    INNER JOIN course c ON ci.course_id = c.id;

CREATE TRIGGER update_enrollment_on_completion
AFTER UPDATE ON submission
FOR EACH ROW
BEGIN
       IF NEW.status = 'GRADED' AND NEW.assignment_id IN (
              SELECT id FROM assignment WHERE type = 'FINAL'
       ) THEN
              UPDATE enrollment
              SET status = 'COMPLETED'
              WHERE student_id = NEW.submitted_by AND course_id = (
                     SELECT course_id FROM assignment WHERE id = NEW.assignment_id
              );
       END IF;
END;

CREATE TRIGGER prevent_duplicate_enrollment
    BEFORE INSERT ON enrollment
    FOR EACH ROW
BEGIN
    DECLARE enrollment_count INT;

    SELECT COUNT(*) INTO enrollment_count
    FROM enrollment
    WHERE student_id = NEW.student_id AND course_id = NEW.course_id;

    IF enrollment_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You are already enrolled in this course.';
    END IF;
END;

CREATE OR REPLACE TRIGGER cascade_delete_assignment
    BEFORE DELETE ON assignment
    FOR EACH ROW
BEGIN
    DELETE FROM submission
    WHERE assignment_id = OLD.id;
END;

CREATE OR REPLACE FUNCTION avg_score(student_id INT UNSIGNED, course_id INT UNSIGNED)
RETURNS DECIMAL(5, 2)
BEGIN
       DECLARE quiz DECIMAL;
       DECLARE mid_term DECIMAL;
       DECLARE final DECIMAL;

       SELECT AVG(s.score) * ((SELECT weight FROM course_specification cs WHERE cs.course_id = course_id AND cs.type = "QUIZ") / 100)
       INTO quiz
       FROM submission s
              INNER JOIN assignment a ON s.assignment_id = a.id
       WHERE s.submitted_by = student_id AND a.course_id = course_id AND a.type = "QUIZ";

       SELECT s.score * ((SELECT weight FROM course_specification cp WHERE cp.course_id = course_id AND cp.type = "MID_TERM") / 100)
       INTO mid_term
       FROM submission s
              INNER JOIN assignment a ON s.assignment_id = a.id
       WHERE s.submitted_by = student_id AND a.course_id = course_id AND a.type = "MID_TERM";

       SELECT s.score * ((SELECT weight FROM course_specification cp WHERE cp.course_id = course_id AND cp.type = "FINAL") / 100)
       INTO final
       FROM submission s
              INNER JOIN assignment a ON s.assignment_id = a.id
       WHERE s.submitted_by = student_id AND a.course_id = course_id AND a.type = "FINAL";

       RETURN quiz + mid_term + final;
END;

CREATE OR REPLACE FUNCTION course_completion(student_id INT UNSIGNED, course_id INT UNSIGNED)
RETURNS DECIMAL(5, 2)
BEGIN
    DECLARE total_assignments INT DEFAULT 0;
    DECLARE submitted_assignments INT DEFAULT 0;

    SELECT COUNT(*) INTO total_assignments
    FROM assignment a WHERE a.course_id = course_id;

    SELECT COUNT(*) INTO submitted_assignments FROM submission s
        INNER JOIN assignment a ON s.assignment_id = a.id
    WHERE submitted_by = student_id AND a.course_id = course_id;

    RETURN (submitted_assignments / total_assignments) * 100;
END;

CREATE FUNCTION get_grade(score INT)
RETURNS VARCHAR(2)
DETERMINISTIC
BEGIN
    DECLARE grade VARCHAR(2);

    IF score > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Score is outside the range';
    ELSEIF score BETWEEN 86 AND 100 THEN
        SET grade = 'A';
    ELSEIF score BETWEEN 76 AND 85 THEN
        SET grade = 'AB';
    ELSEIF score BETWEEN 66 AND 75 THEN
        SET grade = 'B';
    ELSEIF score BETWEEN 56 AND 65 THEN
        SET grade = 'BC';
    ELSEIF score BETWEEN 51 AND 55 THEN
        SET grade = 'C';
    ELSEIF score BETWEEN 41 AND 50 THEN
        SET grade = 'D';
    ELSE
        SET grade = 'E';
    END IF;

    RETURN grade;
END;

CREATE OR REPLACE PROCEDURE show_accounts ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Internal server error';
    END;

    START TRANSACTION;

    SELECT *
    FROM account;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_students ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Internal server error';
    END;

    START TRANSACTION;

    SELECT *
    FROM account
    WHERE role = 'STUDENT';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_instructors ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Internal server error';
    END;

    START TRANSACTION;

    SELECT *
    FROM account
    WHERE role = 'INSTRUCTOR';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_courses ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    SELECT *
    FROM course;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_student_courses (
    p_student_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE role = 'STUDENT' AND id = p_student_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided account is not a student';
    END IF;

    SELECT id, name, status
    FROM enrollment_view
    WHERE student_id = p_student_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_instructor_courses (
    p_instructor_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE role = 'INSTRUCTOR' AND id = p_instructor_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided account is not an instructor';
    END IF;

    SELECT id, name
    FROM instructor_course_view
    WHERE instructor_id = p_instructor_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_assignments ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    SELECT *
    FROM assignment;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_course_assignment (
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    SELECT a.id, a.title, a.detail, a.due_date
    FROM course c
    INNER JOIN assignment a ON c.id = a.course_id
    WHERE c.id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_posts ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    SELECT *
    FROM post;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_course_posts (
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    SELECT *
    FROM post p
    INNER JOIN course c ON p.course_id = c.id
    WHERE c.id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_attachments ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    SELECT *
    FROM attachment;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_reports (student_id INT, course_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Internal server error';
        END;

    START TRANSACTION;

    SELECT CONCAT(ac.first_name, ' ', ac.last_name) AS name, c.name, ag.title AS assignment, s.score
    FROM account ac
        INNER JOIN submission s ON ac.id = s.submitted_by
        INNER JOIN assignment ag ON s.assignment_id = ag.id
        INNER JOIN course c ON ag.course_id = c.id
    WHERE ac.id = student_id AND c.id = course_id;

    SELECT avg_score(student_id, course_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_transcript_with_score_by_id(student_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = student_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided ID is not a student';
    end if;

    SELECT CONCAT(ac.first_name, ' ', ac.last_name) AS name, c.name, ag.title AS assignment, s.score
    FROM account ac
        INNER JOIN submission s ON ac.id = s.submitted_by
        INNER JOIN assignment ag ON s.assignment_id = ag.id
        INNER JOIN course c ON ag.course_id = c.id
        INNER JOIN enrollment e ON c.id = e.course_id AND ac.id = e.student_id
    WHERE ac.id = student_id AND e.status = 'COMPLETED';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE show_transcript_by_id(student_id INT UNSIGNED)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = student_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The provided ID is not a student';
    END IF;

    SELECT
        CONCAT(ac.first_name, ' ', ac.last_name) AS name,
        c.name AS course_name,
        ag.title AS assignment,
        g.grade AS letter_grade
    FROM account ac
        INNER JOIN submission s ON ac.id = s.submitted_by
        INNER JOIN assignment ag ON s.assignment_id = ag.id
        INNER JOIN course c ON ag.course_id = c.id
        INNER JOIN enrollment e ON c.id = e.course_id AND ac.id = e.student_id
        INNER JOIN grade g ON s.score BETWEEN g.min_score AND g.max_score
    WHERE ac.id = student_id AND e.status = 'COMPLETED';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE enroll_student_to_course(
    student_id INT UNSIGNED,
    course_id INT UNSIGNED
)
BEGIN
    DECLARE prerequisite_count INT UNSIGNED DEFAULT 0;
    DECLARE completed_count INT UNSIGNED DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = student_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account is not a student.';
    END IF;

    IF EXISTS (
        SELECT e.course_id
        FROM enrollment e
        WHERE e.student_id = student_id
          AND e.course_id = course_id
          AND e.status = 'ACTIVE'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This student is already enrolled in this course.';
    END IF;

    SELECT COUNT(*)
    INTO prerequisite_count
    FROM course_prerequisite cp
    WHERE cp.course_id = course_id;

    IF prerequisite_count > 0 THEN
        SELECT COUNT(*)
        INTO completed_count
        FROM enrollment e
        INNER JOIN course_prerequisite cp
            ON e.course_id = cp.course_id
        WHERE e.course_id = course_id
            AND e.student_id = student_id
            AND e.status = 'COMPLETED';

        IF completed_count < prerequisite_count THEN
            SIGNAL SQLSTATE  '45000'
            SET MESSAGE_TEXT = 'This student has not completed all prerequisites.';
        END IF;
    END IF;

    INSERT INTO enrollment (student_id, course_id, status)
    VALUES (student_id, course_id, 'ACTIVE');

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE drop_course(
    p_student_id INT UNSIGNED,
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT e.course_id
        FROM enrollment e
        WHERE e.student_id = p_student_id
            AND e.course_id = p_course_id
            AND e.status = 'ACTIVE'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This student is not currently taking this course.';
    END IF;

    UPDATE enrollment
    SET status = 'DROPPED'
    WHERE student_id = p_student_id
        AND course_id = p_course_id
        AND status = 'ACTIVE';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE submit_assignment (
    IN p_student_id INT UNSIGNED,
    IN p_assignment_id INT UNSIGNED,
    IN p_attachment_id INT UNSIGNED
)
BEGIN
    DECLARE assignment_due_date DATETIME;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT due_date INTO assignment_due_date
    FROM assignment
    WHERE id = p_assignment_id;

    IF NOW() > assignment_due_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The assignment is past the due date.';
    END IF;

    INSERT INTO submission (status, submitted_by, assignment_id, attachment_id)
    VALUES
        ('NOT GRADED', p_student_id, p_assignment_id, p_attachment_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE grade_submission(
    p_instructor_id INT UNSIGNED,
    p_student_id INT UNSIGNED,
    p_submission_id INT UNSIGNED,
    p_score INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = p_instructor_id
            AND role IN ('ADMIN', 'INSTRUCTOR')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account is not authorized to grade student\'s submissions.';
    END IF;

    IF NOT EXISTS (
        SELECT id
        FROM submission
        WHERE id = p_submission_id
            AND submitted_by = p_student_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Submission not found or does not belong to the student.';
    END IF;

    IF p_score < 0 OR p_score > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Score must be between 0 and 100.';
    END IF;

    UPDATE submission
    SET score = p_score
    WHERE id = p_submission_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE assign_instructor_to_course(
    p_assigner_id INT UNSIGNED,
    p_instructor_id INT UNSIGNED,
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = p_assigner_id
            AND role = 'ADMIN'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account is not authorized to assign an instructor to a course.';
    END IF;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = p_instructor_id
            AND role = 'INSTRUCTOR'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided instructor ID does not have the role "INSTRUCTOR".';
    END IF;

    INSERT INTO course_instructor (instructor_id, course_id)
    VALUES (p_instructor_id, p_course_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE create_assignment(
    p_creator_id INT UNSIGNED,
    p_type ENUM('QUIZ', 'MID_TERM', 'FINAL'),
    p_title VARCHAR(255),
    p_detail TEXT,
    p_due_date DATETIME,
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE is_admin BOOL DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) > 0
    INTO is_admin
    FROM account
    WHERE id = p_creator_id
        AND role = 'ADMIN';

    IF NOT is_admin AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_creator_id
            AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF p_type IN ('MID_TERM', 'FINAL') AND EXISTS (
        SELECT id
        FROM assignment
        WHERE type IN ('MID_TERM', 'FINAL')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There is already a mid term or final assignment in this course.';
    END IF;

    INSERT INTO assignment (type, title, detail, due_date, course_id)
    VALUES (p_type, p_title, p_detail, p_due_date, p_course_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE edit_assignment(
    p_creator_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_type ENUM('QUIZ', 'MID_TERM', 'FINAL'),
    p_title VARCHAR(255),
    p_detail TEXT,
    p_due_date DATETIME,
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE is_admin BOOL DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) > 0
    INTO is_admin
    FROM account
    WHERE id = p_creator_id
        AND role = 'ADMIN';

    IF NOT is_admin AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_creator_id
            AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF p_type IN ('MID_TERM', 'FINAL') AND EXISTS (
        SELECT id
        FROM assignment
        WHERE type IN ('MID_TERM', 'FINAL')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There is already a mid term or final assignment in this course.';
    END IF;

    UPDATE assignment
    SET type = IFNULL(p_type, type),
        title = IFNULL(p_title, title),
        detail = IFNULL(p_detail, detail),
        due_date = IFNULL(p_due_date, due_date),
        course_id = IFNULL(p_course_id, course_id)
    WHERE id = p_assignment_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE drop_assignment (
    p_account_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED
)
BEGIN
    DECLARE course_to_be_deleted INT UNSIGNED;
    DECLARE is_admin BOOL DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT course_id
    INTO course_to_be_deleted
    FROM assignment
    WHERE id = p_assignment_id;

    SELECT COUNT(*) > 0
    INTO is_admin
    FROM account
    WHERE id = p_account_id
        AND role = 'ADMIN';

    IF NOT is_admin AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_account_id
            AND course_id = course_to_be_deleted
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    DELETE FROM assignment
    WHERE id = p_assignment_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE create_post(
    p_creator_id INT UNSIGNED,
    p_title VARCHAR(255),
    p_content TEXT,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_file_path VARCHAR(255),
    p_file_name VARCHAR(255)
)
BEGIN
    DECLARE is_admin BOOL DEFAULT FALSE;
    DECLARE attachment_id INT UNSIGNED DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) > 0
    INTO is_admin
    FROM account
    WHERE id = p_creator_id
        AND role = 'ADMIN';

    IF NOT is_admin AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_creator_id
            AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF p_file_path IS NOT NULL THEN
        INSERT INTO attachment (file_path, name)
        VALUES (p_file_path, p_file_name);

        SET attachment_id = LAST_INSERT_ID();
    END IF;

    INSERT INTO post (title, content, attachment_id, course_id, posted_by, assignment_id)
    VALUES (p_title, p_content, attachment_id, p_course_id, p_creator_id, p_assignment_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE edit_post(
    p_creator_id INT UNSIGNED,
    p_post_id INT UNSIGNED,
    p_title VARCHAR(255),
    p_content TEXT,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_attachment_id INT UNSIGNED
)
BEGIN
    DECLARE is_admin BOOL DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) > 0
    INTO is_admin
    FROM account
    WHERE id = p_creator_id
        AND role = 'ADMIN';

    IF NOT is_admin AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_creator_id
            AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    UPDATE post
    SET title = IFNULL(p_title, title),
        content = IFNULL(p_content, content),
        course_id = IFNULL(p_course_id, course_id),
        posted_by = IFNULL(p_creator_id, posted_by),
        assignment_id = IFNULL(p_assignment_id, assignment_id),
        attachment_id = IFNULL(p_attachment_id, attachment_id)
    WHERE id = p_post_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE drop_assignment(
    p_account_id INT UNSIGNED,
    p_post_id INT UNSIGNED
)
BEGIN
    DECLARE course_to_be_deleted INT UNSIGNED;
    DECLARE is_admin BOOL DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT course_id
    INTO course_to_be_deleted
    FROM post
    WHERE id = p_post_id;

    SELECT COUNT(*) > 0
    INTO is_admin
    FROM account
    WHERE id = p_account_id
        AND role = 'ADMIN';

    IF NOT is_admin AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_account_id
            AND course_id = course_to_be_deleted
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    DELETE FROM post
    WHERE id = p_post_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE create_course(
    p_account_id INT UNSIGNED,
    p_course_name VARCHAR(255),
    p_course_description TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = p_account_id
            AND role = 'ADMIN'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have the required permission.';
    end if;

    INSERT INTO course (name, description)
    VALUES (p_course_name, p_course_description);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE edit_course (
    p_account_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_course_name VARCHAR(255),
    p_course_description TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE id = p_account_id
            AND role = 'ADMIN'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This account doesn\'t have the required permission.';
    END IF;

    UPDATE course
    SET name = IFNULL(p_course_name, name),
        description = IFNULL(p_course_description, description)
    WHERE id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE delete_course (
    p_account_id INT UNSIGNED,
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE is_admin BOOL DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT COUNT(*) > 0
    INTO is_admin
    FROM account
    WHERE id = p_account_id
      AND role = 'ADMIN';

    IF NOT is_admin AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_account_id
          AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    DELETE FROM post
    WHERE id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE register (
    p_username VARCHAR(255),
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    p_fname VARCHAR(255),
    p_lname VARCHAR(255),
    p_role ENUM('ADMIN', 'INSTRUCTOR', 'STUDENT')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF p_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot be empty.';
    end if;

    IF LENGTH(p_username) < 3 OR p_username IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username must at least be 3 characters long.';
    END IF;

    IF LENGTH(p_password) < 8 OR p_password IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Password must at least be 8 characters long.';
    END IF;

    IF p_role IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role cannot be empty.';
    END IF;

    IF p_role = 'ADMIN' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not authorized.';
    END IF;

    IF EXISTS (
        SELECT id
        FROM account
        WHERE username = p_username OR email = p_email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username is taken.';
    END IF;

    IF EXISTS (
        SELECT id
        FROM account
        WHERE email = p_email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This email is already used.';
    END IF;

    INSERT INTO account (username, email, password, first_name, last_name, role)
    VALUES (p_username, p_email, PASSWORD(p_password), p_fname, p_lname, p_role);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_session(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT s.id, s.user_id, s.expires_at, a.id
    FROM session s
    INNER JOIN account a ON s.user_id = a.id
    WHERE s.id = p_session_id;

    COMMIT;
END ;

CREATE OR REPLACE PROCEDURE delete_session(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    DELETE FROM session
    WHERE id = p_session_id;

    COMMIT;
END ;

CREATE OR REPLACE PROCEDURE update_session(
    p_session_id VARCHAR(255),
    p_expires_at DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    UPDATE session
    SET expires_at = p_expires_at
    WHERE id = p_session_id;

    COMMIT;
END ;

CREATE OR REPLACE PROCEDURE validate_session(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE curr_time DATETIME DEFAULT NOW();
    DECLARE expires_at DATETIME;
    DECLARE session_id VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT id, expires_at
    INTO session_id, expires_at
    FROM session
    WHERE id = p_session_id;

    IF session_id IS NULL OR curr_time >= expires_at THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not authorized';
    END IF;

    IF curr_time >= expires_at - INTERVAL 12 HOUR THEN
        SET expires_at = curr_time + INTERVAL 1 DAY;
        UPDATE session SET expires_at = expires_at WHERE id = session_id;
    END IF;

    SELECT id, user_id, expires_at
    FROM session
    WHERE id = session_id;

    COMMIT;
END ;

CREATE OR REPLACE PROCEDURE create_session(
    p_user_id INT UNSIGNED
)
BEGIN
    DECLARE uuid VARCHAR(255) DEFAULT UUID();
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    INSERT INTO session (id, user_id, expires_at)
    VALUES
        (uuid, p_user_id, NOW() + INTERVAL 1 DAY);

    SELECT id, user_id, expires_at
    FROM session
    WHERE id = uuid;

    COMMIT;
END ;

CREATE OR REPLACE PROCEDURE logout(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    DELETE FROM session WHERE id = p_session_id;

    COMMIT;
END ;

CREATE OR REPLACE PROCEDURE login (
    p_email VARCHAR(255),
    p_password VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF p_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot be empty.';
    END IF;

    IF p_password IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Password cannot be empty.';
    END IF;

    IF NOT EXISTS (
        SELECT id
        FROM account
        WHERE email = p_email AND password = PASSWORD(p_password)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email or password is incorrect';
    END IF;

    SELECT id, username, email, first_name, last_name, role
    FROM account
    WHERE email = p_email AND password = PASSWORD(p_password);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE global_search (
    search_string VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT *
    FROM course
    WHERE name LIKE CONCAT('%', search_string, '%');

    SELECT *
    FROM assignment
    WHERE title LIKE CONCAT('%', search_string, '%');

    SELECT *
    FROM post
    WHERE title LIKE CONCAT('%', search_string, '%');

    COMMIT;
END;
