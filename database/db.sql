DROP DATABASE IF EXISTS lms;
CREATE DATABASE lms;
USE lms;

CREATE OR REPLACE TABLE account (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    role ENUM('ADMIN', 'INSTRUCTOR', 'STUDENT') NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW()
);

CREATE OR REPLACE TABLE session (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES account(id)
);

CREATE OR REPLACE TABLE course (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW()
);

CREATE OR REPLACE TABLE enrollment (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    student_id INT UNSIGNED NOT NULL,
    course_id INT UNSIGNED NOT NULL,
    status ENUM('ACTIVE', 'COMPLETED', 'DROPPED'),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(student_id) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE course_instructor (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    instructor_id INT UNSIGNED NOT NULL,
    course_id INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(instructor_id) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE course_prerequisite (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    course_id INT UNSIGNED NOT NULL,
    prerequisite_id INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE,
    FOREIGN KEY(prerequisite_id) REFERENCES course(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE course_specification (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    course_id INT UNSIGNED NOT NULL,
    type ENUM('QUIZ', 'MID_TERM', 'FINAL') NOT NULL,
    weight TINYINT UNSIGNED NOT NULL CHECK (weight BETWEEN 0 AND 100),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE attachment (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    file_name VARCHAR(255),
    file_path VARCHAR(255) NOT NULL,
    owner INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(owner) REFERENCES account(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE assignment (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    type ENUM('QUIZ', 'MID_TERM', 'FINAL') NOT NULL,
    title VARCHAR(255),
    content TEXT,
    due_date DATETIME,
    course_id INT UNSIGNED NOT NULL,
    created_by INT UNSIGNED NOT NULL,
    attachment_id INT UNSIGNED,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE,
    FOREIGN KEY(attachment_id) REFERENCES attachment(id) ON DELETE CASCADE,
    FOREIGN KEY(created_by) REFERENCES account(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE post (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    course_id INT UNSIGNED NOT NULL,
    posted_by INT UNSIGNED NOT NULL,
    attachment_id INT UNSIGNED,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(course_id) REFERENCES course(id) ON DELETE CASCADE,
    FOREIGN KEY(attachment_id) REFERENCES attachment(id) ON DELETE CASCADE,
    FOREIGN KEY(posted_by) REFERENCES account(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE grade (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    grade CHAR(2) NOT NULL,
    min_score TINYINT UNSIGNED NOT NULL,
    max_score TINYINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    CHECK (min_score >= 0 AND max_score <= 100 AND min_score <= max_score)
);

CREATE OR REPLACE TABLE submission (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    status ENUM('GRADED', 'NOT GRADED'),
    score TINYINT UNSIGNED CHECK (score BETWEEN 0 AND 100),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    submitted_at DATETIME DEFAULT NOW(),
    submitted_by INT UNSIGNED NOT NULL,
    attachment_id INT UNSIGNED,
    assignment_id INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY(submitted_by) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY(attachment_id) REFERENCES attachment(id) ON DELETE CASCADE,
    FOREIGN KEY(assignment_id) REFERENCES assignment(id) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE student_course_grade (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    student_id INT UNSIGNED NOT NULL,
    course_id INT UNSIGNED NOT NULL,
    final_score INT UNSIGNED,
    final_grade CHAR(2) NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (student_id) REFERENCES account(id),
    FOREIGN KEY (course_id) REFERENCES course(id)
);

CREATE OR REPLACE view submission_detail_view AS
    SELECT
        sub.id,
        sub.title,
        sub.content,
        sub.status,
        sub.score,
        sub.submitted_at,
        sub.assignment_id,
        ag.type,
        ag.title AS assignment_title,
        ag.due_date,
        ag.course_id,
        sub.submitted_by,
        acc.username,
        acc.email,
        acc.first_name,
        acc.last_name,
        acc.role,
        c.name,
        c.description,
        sub.attachment_id,
        at.file_name,
        at.file_path
    FROM submission sub
        INNER JOIN account acc ON sub.submitted_by = acc.id
        INNER JOIN assignment ag ON sub.assignment_id = ag.id
        INNER JOIN course c ON ag.course_id = c.id
        LEFT JOIN attachment at ON sub.attachment_id = at.id;

CREATE OR REPLACE VIEW course_assignment_detail_view AS
    SELECT
        ag.id,
        ag.type,
        ag.title,
        ag.content,
        ag.due_date,
        ag.course_id,
        c.name,
        c.description,
        ag.created_by,
        a.username,
        a.email,
        a.first_name,
        a.last_name,
        a.role,
        ag.attachment_id,
        at.file_name,
        at.file_path,
        at.owner
    FROM course c
        INNER JOIN assignment ag ON c.id = ag.course_id
        INNER JOIN account a ON ag.created_by = a.id
        LEFT JOIN attachment at on a.id = at.owner;

CREATE OR REPLACE VIEW enrollment_view AS
    SELECT c.id, c.name, e.status, e.student_id
    FROM enrollment e
    INNER JOIN course c ON e.course_id = c.id;

CREATE OR REPLACE VIEW instructor_course_view AS
    SELECT c.id, c.name, ci.instructor_id
    FROM course_instructor ci
    INNER JOIN course c ON ci.course_id = c.id;

CREATE OR REPLACE TRIGGER update_enrollment_on_completion
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

        INSERT INTO student_course_grade
            (course_id, student_id, final_score, final_grade)
        SELECT
            course_id,
            student_id,
            avg_score(student_id, course_id) AS final_score,
            get_grade(avg_score(student_id, course_id)) AS final_grade
        FROM enrollment
        WHERE status = 'COMPLETED' AND student_id = NEW.submitted_by;
    END IF;
END;

CREATE OR REPLACE TRIGGER prevent_duplicate_enrollment
    BEFORE INSERT ON enrollment
    FOR EACH ROW
BEGIN
    DECLARE enrollment_count INT;

    SELECT COUNT(*) INTO enrollment_count
    FROM enrollment
    WHERE student_id = NEW.student_id AND course_id = NEW.course_id AND status = 'ACTIVE';

    IF enrollment_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This student is already enrolled in this course.';
    END IF;
END;

CREATE OR REPLACE TRIGGER delete_attachment_on_assignment_delete
    BEFORE DELETE ON assignment
    FOR EACH ROW
BEGIN
    DELETE FROM attachment
    WHERE id IN (
        SELECT attachment_id FROM assignment
        WHERE id = OLD.id
    );
END;

CREATE OR REPLACE TRIGGER cascade_delete_assignment
    BEFORE DELETE ON assignment
    FOR EACH ROW
BEGIN
    DELETE FROM submission
    WHERE assignment_id = OLD.id;
END;

CREATE OR REPLACE FUNCTION avg_score(p_student_id INT UNSIGNED, p_course_id INT UNSIGNED)
RETURNS DECIMAL(5, 2)
BEGIN
       DECLARE quiz DECIMAL;
       DECLARE mid_term DECIMAL;
       DECLARE final DECIMAL;

       SELECT AVG(s.score) * ((SELECT weight FROM course_specification cs WHERE cs.course_id = p_course_id AND cs.type = "QUIZ") / 100)
       INTO quiz
       FROM submission s
              INNER JOIN assignment a ON s.assignment_id = a.id
       WHERE s.submitted_by = p_student_id AND a.course_id = p_course_id AND a.type = "QUIZ";

       SELECT s.score * ((SELECT weight FROM course_specification cp WHERE cp.course_id = p_course_id AND cp.type = "MID_TERM") / 100)
       INTO mid_term
       FROM submission s
              INNER JOIN assignment a ON s.assignment_id = a.id
       WHERE s.submitted_by = p_student_id AND a.course_id = p_course_id AND a.type = "MID_TERM" LIMIT 1;

       SELECT s.score * ((SELECT weight FROM course_specification cp WHERE cp.course_id = p_course_id AND cp.type = "FINAL") / 100)
       INTO final
       FROM submission s
              INNER JOIN assignment a ON s.assignment_id = a.id
       WHERE s.submitted_by = p_student_id AND a.course_id = p_course_id AND a.type = "FINAL" LIMIT 1;

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

CREATE OR REPLACE FUNCTION get_grade(score INT)
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

CREATE OR REPLACE FUNCTION id_from_session(
    p_session_id VARCHAR(255)
)
RETURNS INT UNSIGNED
RETURN (SELECT user_id FROM session WHERE id = p_session_id);

CREATE OR REPLACE FUNCTION is_admin(
    p_id INT UNSIGNED
)
RETURNS BOOLEAN
RETURN (SELECT role = 'ADMIN' FROM account WHERE id = p_id);

CREATE OR REPLACE FUNCTION is_instructor(
    p_id INT UNSIGNED
)
RETURNS BOOLEAN
RETURN (SELECT role IN ('INSTRUCTOR', 'ADMIN') FROM account WHERE id = p_id);

CREATE OR REPLACE FUNCTION is_student(
    p_id INT UNSIGNED
)
RETURNS BOOLEAN
RETURN (SELECT role IN ('STUDENT', 'ADMIN') FROM account WHERE id = p_id);

CREATE OR REPLACE PROCEDURE get_accounts(
    p_filter_any VARCHAR(255),
    p_id VARCHAR(255),
    p_username VARCHAR(255),
    p_email VARCHAR(255),
    p_first_name VARCHAR(255),
    p_last_name VARCHAR(255),
    p_role VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT id, username, email, first_name, last_name, role
    FROM account
    WHERE
        (
            p_filter_any IS NULL OR
            id LIKE CONCAT('%', p_filter_any, '%') OR
            username LIKE CONCAT('%', p_filter_any, '%') OR
            email LIKE CONCAT('%', p_filter_any, '%') OR
            first_name LIKE CONCAT('%', p_filter_any, '%') OR
            last_name LIKE CONCAT('%', p_filter_any, '%') OR
            role LIKE CONCAT('%', p_filter_any, '%')
        ) AND
        (p_id IS NULL OR id LIKE CONCAT('%', p_id, '%')) AND
        (p_username IS NULL OR username LIKE CONCAT('%', p_username, '%')) AND
        (p_email IS NULL OR email LIKE CONCAT('%', p_email, '%')) AND
        (p_first_name IS NULL OR first_name LIKE CONCAT('%', p_first_name, '%')) AND
        (p_last_name IS NULL OR last_name LIKE CONCAT('%', p_last_name, '%')) AND
        (p_role IS NULL OR role LIKE CONCAT('%', p_role, '%'));

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_account(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT id, username, email, first_name, last_name, role
    FROM account
    WHERE id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_student(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT id, username, email, first_name, last_name, role
    FROM account
    WHERE id = p_id AND role = 'STUDENT';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_instructor(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT id, username, email, first_name, last_name, role
    FROM account
    WHERE id = p_id AND role = 'INSTRUCTOR';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE delete_account(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    DELETE FROM account
    WHERE id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE edit_account(
    p_id INT UNSIGNED,
    p_username VARCHAR(255),
    p_email VARCHAR(255),
    p_first_name VARCHAR(255),
    p_last_name VARCHAR(255),
    p_role VARCHAR(255),
    p_password VARCHAR(255),
    p_confirmation_password VARCHAR(255)
)
BEGIN
    DECLARE new_password VARCHAR(255) DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM account
        WHERE id = p_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Student not found';
    end if;

    IF LENGTH(p_username) < 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Username must at least be 3 characters long.';
    END IF;

    IF LENGTH(p_password) < 8 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Password must at least be 8 characters long.';
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
            SET MESSAGE_TEXT = 'This email is taken.';
    END IF;

    IF NOT (p_password = p_confirmation_password) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Password and confirmation password do not match.';
    end if;

    IF p_password IS NOT NULL THEN
        SET new_password = PASSWORD(p_password);
    END IF;

    IF p_role NOT IN ('STUDENT', 'INSTRUCTOR', 'ADMIN') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Role does not exist';
    END IF;

    UPDATE account SET
       username = IFNULL(p_username, username),
       email = IFNULL(p_email, email),
       password = IFNULL(new_password, password),
       first_name = IFNULL(p_first_name, first_name),
       last_name = IFNULL(p_last_name, last_name),
       role = IFNULL(p_role, role)
    WHERE id = p_id;

    SELECT id, username, email, first_name, last_name, role
    FROM account
    WHERE id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE close_account(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE account_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT user_id INTO account_id
    FROM session
    WHERE id = p_session_id;

    DELETE FROM account
    WHERE id = account_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_courses(
    p_filter_any VARCHAR(255),
    p_id VARCHAR(255),
    p_name VARCHAR(255),
    p_description TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT
        id,
        name,
        description
    FROM course
    WHERE
        (
            p_filter_any IS NULL OR
            id LIKE CONCAT('%', p_filter_any, '%') OR
            name LIKE CONCAT('%', p_filter_any, '%') OR
            description LIKE CONCAT('%', p_filter_any, '%')
        ) AND
        (p_id IS NULL OR id LIKE CONCAT('%', p_id, '%')) AND
        (p_name IS NULL OR name LIKE CONCAT('%', p_name, '%')) AND
        (p_description IS NULL OR description LIKE CONCAT('%', p_description, '%'));

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_course(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
        END;

    START TRANSACTION;

    SELECT id, name, description
    FROM course
    WHERE id = p_id;

    SELECT c.id, c.name, c.description
    FROM course_prerequisite cp
        INNER JOIN course c ON cp.course_id = c.id
    WHERE c.id = p_id;

    SELECT cs.id, cs.type, cs.weight
    FROM course_specification cs
        INNER JOIN course c ON cs.course_id = c.id
    WHERE c.id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE add_course(
    p_name VARCHAR(255),
    p_description TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF LENGTH(p_name) = 0 OR p_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name cannot be empty.';
    END IF;

    INSERT INTO course (name, description)
    VALUES (p_name, p_description);

    SELECT id, name, description
    FROM course
    WHERE id = last_insert_id();

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE edit_course (
    p_id INT UNSIGNED,
    p_name VARCHAR(255),
    p_description TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF LENGTH(p_name) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Name cannot be empty.';
    END IF;

    UPDATE course SET
        name = IFNULL(p_name, name),
        description = IFNULL(p_description, description)
    WHERE id = p_id;

    SELECT id, name, description
    FROM course
    WHERE id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE delete_course(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    DELETE FROM course
    WHERE id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_enrollments(
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT e.id, e.student_id, a.first_name, a.last_name, c.id, c.name, e.status
    FROM enrollment e
        INNER JOIN account a ON e.student_id = a.id
        INNER JOIN course c ON e.course_id = c.id
    WHERE c.id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_enrollment(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT e.id, e.student_id, a.first_name, a.last_name, c.id, c.name, e.status
    FROM enrollment e
        INNER JOIN account a ON e.student_id = a.id
        INNER JOIN course c ON e.course_id = c.id
    WHERE e.id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_course_instructors(
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT ci.id, ci.instructor_id, a.first_name, a.last_name, c.id, c.name as 'course_name'
    FROM course_instructor ci
        INNER JOIN account a ON ci.instructor_id = a.id
        INNER JOIN course c ON ci.course_id = c.id
    WHERE c.id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_course_instructor(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT ci.id, ci.instructor_id, a.first_name, a.last_name, c.id as 'course_id', c.name as 'course_name'
    FROM course_instructor ci
         INNER JOIN account a ON ci.instructor_id = a.id
         INNER JOIN course c ON ci.course_id = c.id
    WHERE ci.id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_student_courses(
    p_id INT UNSIGNED,
    p_filter_any VARCHAR(255),
    p_course_id VARCHAR(255),
    p_name VARCHAR(255),
    p_description TEXT,
    p_status VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM account
        WHERE id = p_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The provided account is not an student.';
    END IF;

    SELECT e.id, c.id as course_id, c.name as course_name, c.description as course_description, e.status
    from account a
        INNER JOIN enrollment e ON a.id = e.student_id
        INNER JOIN course c ON e.course_id = c.id
    WHERE
        a.id = p_id AND
        (
            p_filter_any IS NULL OR
            c.id LIKE CONCAT('%', p_filter_any, '%') OR
            c.name LIKE CONCAT('%', p_filter_any, '%') OR
            c.description LIKE CONCAT('%', p_filter_any, '%') OR
            e.status LIKE CONCAT('%', p_filter_any, '%')
        ) AND
        (p_course_id IS NULL OR c.id LIKE CONCAT('%', p_course_id, '%')) AND
        (p_name IS NULL OR c.name LIKE CONCAT('%', p_name, '%')) AND
        (p_description IS NULL OR c.description LIKE CONCAT('%', p_description, '%')) AND
        (p_status IS NULL OR e.status LIKE CONCAT('%', p_status, '%'));

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_instructor_courses(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM account
        WHERE id = p_id AND role = 'INSTRUCTOR'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided account is not an instructor.';
    END IF;

    SELECT ci.id, c.id as course_id, c.name as course_name, c.description as course_description
    from account a
        INNER JOIN course_instructor ci ON a.id = ci.instructor_id
        INNER JOIN course c ON ci.course_id = c.id
    WHERE a.id = p_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE delete_course_instructor(
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
        SELECT 1 FROM account
        WHERE id = p_instructor_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'The provided account does not exists.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'The provided course does not exists.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM account
        WHERE id = p_instructor_id AND role = 'INSTRUCTOR'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The provided account is not an instructor.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course_instructor
        WHERE instructor_id = p_instructor_id AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'This instructor is not currently assigned to this course.';
    END IF;

    DELETE FROM course_instructor
    WHERE instructor_id = p_instructor_id AND course_id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_course_assignments(
    p_course_id INT UNSIGNED,
    p_filter_any VARCHAR(255),
    p_assignment_id INT UNSIGNED,
    p_title VARCHAR(255),
    p_due_date DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
        SET MESSAGE_TEXT = 'Course does not exist.';
    end if;

    SELECT * FROM course_assignment_detail_view
    WHERE
        course_id = p_course_id
        AND (p_filter_any IS NULL OR title LIKE CONCAT('%', p_filter_any, '%'))
        AND (p_assignment_id IS NULL OR id = p_assignment_id)
        AND (p_title IS NULL OR title LIKE CONCAT('%', p_title, '%'))
        AND (p_due_date IS NULL OR due_date = p_due_date);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_course_assignment(
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Course does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM assignment
        WHERE id = p_assignment_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Assignment does not exist.';
    END IF;

    SELECT * FROM course_assignment_detail_view
    WHERE course_id = p_course_id AND id = p_assignment_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_course_reports (
    p_student_id INT,
    p_course_id INT
)
BEGIN
    DECLARE final_score INT DEFAULT avg_score(p_student_id, p_course_id);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT
        ag.id,
        ag.title,
        ag.type,
        s.score,
        get_grade(s.score) AS grade
    FROM account ac
        INNER JOIN submission s ON ac.id = s.submitted_by
        INNER JOIN assignment ag ON s.assignment_id = ag.id
        INNER JOIN course c ON ag.course_id = c.id
    WHERE ac.id = p_student_id AND c.id = p_course_id;

    SELECT
        final_score,
        get_grade(final_score) AS final_grade;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_student_transcript(
    p_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM account
        WHERE id = p_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided ID is not a student.';
    END IF;

    SELECT
        c.id,
        c.name,
        c.description,
        avg_score(p_id, c.id) AS final_score,
        get_grade(avg_score(p_id, c.id)) AS final_grade
    FROM enrollment e
        INNER JOIN course c ON e.course_id = c.id
    WHERE
        e.student_id = p_id AND
        e.status = 'COMPLETED';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_detailed_student_transcript(
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
        WHERE id = p_student_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The provided ID is not a student';
    END IF;

    SELECT
        c.id,
        c.name,
        c.description,
        scg.final_score,
        scg.final_grade,
        ag.id AS assignment_id,
        ag.title AS assignment_title,
        ag.type AS assignment_type,
        s.score AS assignment_score,
        g.grade AS assignment_grade
    FROM account ac
        INNER JOIN submission s ON ac.id = s.submitted_by
        INNER JOIN assignment ag ON s.assignment_id = ag.id
        INNER JOIN course c ON ag.course_id = c.id
        INNER JOIN enrollment e ON c.id = e.course_id AND ac.id = e.student_id
        INNER JOIN grade g ON s.score BETWEEN g.min_score AND g.max_score
        INNER JOIN student_course_grade scg on ac.id = scg.student_id
    WHERE ac.id = p_student_id AND e.status = 'COMPLETED';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_detailed_student_transcript_suboptimal(
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
        WHERE id = p_student_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The provided ID is not a student';
    END IF;

    SELECT
        c.id,
        c.name,
        c.description,
        avg_score(e.student_id, c.id) AS final_score,
        get_grade(avg_score(e.student_id, c.id)) AS final_grade,
        ag.id AS assignment_id,
        ag.title AS assignment_title,
        ag.type AS assignment_type,
        s.score AS assignment_score,
        g.grade AS assignment_grade
    FROM account ac
        INNER JOIN submission s ON ac.id = s.submitted_by
        INNER JOIN assignment ag ON s.assignment_id = ag.id
        INNER JOIN course c ON ag.course_id = c.id
        INNER JOIN enrollment e ON c.id = e.course_id AND ac.id = e.student_id
        INNER JOIN grade g ON s.score BETWEEN g.min_score AND g.max_score
    WHERE ac.id = p_student_id AND e.status = 'COMPLETED';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE enroll_student_to_course(
    p_student_id INT UNSIGNED,
    p_course_id INT UNSIGNED
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
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Course does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM account
        WHERE id = p_student_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'This account does not have the appropriate role.';
    END IF;

    SELECT COUNT(*)
    INTO prerequisite_count
    FROM course_prerequisite cp
    WHERE cp.course_id = p_course_id;

    IF prerequisite_count > 0 THEN
        SELECT COUNT(*)
        INTO completed_count
        FROM enrollment e
        INNER JOIN course_prerequisite cp
            ON e.course_id = cp.course_id
        WHERE e.course_id = p_course_id
            AND e.student_id = p_student_id
            AND e.status = 'COMPLETED';

        IF completed_count < prerequisite_count THEN
            SIGNAL SQLSTATE  '45000'
            SET MESSAGE_TEXT = 'This student has not completed all prerequisites.';
        END IF;
    END IF;

    INSERT INTO enrollment (student_id, course_id, status)
    VALUES (p_student_id, p_course_id, 'ACTIVE');

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
        SELECT 1 FROM account
        WHERE id = p_student_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'The provided account does not exists.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'The provided course does not exists.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM account
        WHERE id = p_student_id AND role = 'STUDENT'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The provided account is not a student.';
    END IF;

    IF NOT EXISTS (
        SELECT e.course_id
        FROM enrollment e
        WHERE e.student_id = p_student_id
            AND e.course_id = p_course_id
            AND e.status = 'ACTIVE'
    ) THEN
        SIGNAL SQLSTATE '45404'
        SET MESSAGE_TEXT = 'This student is not currently taking this course.';
    END IF;

    UPDATE enrollment
    SET status = 'DROPPED'
    WHERE student_id = p_student_id
        AND course_id = p_course_id
        AND status = 'ACTIVE';

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE grade_submission(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
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

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT 1 FROM course_instructor
        WHERE id = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45403'
        SET MESSAGE_TEXT = 'Not authorized for this course.';
    END IF;

    IF p_score < 0 OR p_score > 100 OR p_score IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Score must be between 0 and 100.';
    END IF;

    UPDATE submission
    SET score = p_score
    WHERE id = p_submission_id AND assignment_id = p_assignment_id;

    CALL get_submission(p_course_id, p_assignment_id, p_submission_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE assign_instructor_to_course(
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

    IF EXISTS (
        SELECT 1 FROM course_instructor
        WHERE instructor_id = p_instructor_id AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This instructor is already assigned to this course.';
    END IF;

    INSERT INTO course_instructor (instructor_id, course_id)
    VALUES (p_instructor_id, p_course_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE add_assignment(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_type VARCHAR(255),
    p_title VARCHAR(255),
    p_content TEXT,
    p_due_date DATETIME,
    p_attachment_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_user_id
          AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF p_type NOT IN ('QUIZ', 'MID_TERM', 'FINAL') OR p_type IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Type is not valid.';
    END IF;

    IF LENGTH(p_title) = 0 OR p_title IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Title cannot be empty.';
    END IF;

    IF p_due_date < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Date is not valid.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Course does not exist.';
    END IF;

    IF p_type IN ('MID_TERM', 'FINAL') AND EXISTS (
        SELECT id
        FROM assignment
        WHERE type IN ('MID_TERM', 'FINAL')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There is already a mid term or final assignment in this course.';
    END IF;

    INSERT INTO assignment
        (type, title, content, due_date, course_id, created_by, attachment_id)
    VALUES
        (p_type,p_title, p_content, p_due_date, p_course_id, p_user_id, p_attachment_id);

    CALL get_course_assignment(p_course_id, LAST_INSERT_ID());

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE edit_assignment(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_type VARCHAR(255),
    p_title VARCHAR(255),
    p_content TEXT,
    p_due_date DATETIME,
    p_attachment_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_user_id
          AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF p_type NOT IN ('QUIZ', 'MID_TERM', 'FINAL') AND p_type IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Type is not valid.';
    END IF;

    IF p_due_date < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Date is not valid.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Course does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM attachment
        WHERE id = p_attachment_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Attachment does not exist.';
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
        content = IFNULL(p_content, content),
        due_date = IFNULL(p_due_date, due_date),
        attachment_id = IFNULL(p_attachment_id, attachment_id)
    WHERE id = p_assignment_id;

    CALL get_course_assignment(p_course_id, p_assignment_id);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE delete_assignment(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT instructor_id
        FROM course_instructor
        WHERE instructor_id = p_user_id
            AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45403'
        SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    SELECT at.file_path
    FROM attachment at
         INNER JOIN assignment ag ON at.id = ag.attachment_id
    WHERE ag.id = p_assignment_id;

    DELETE FROM assignment
    WHERE id = p_assignment_id AND course_id = p_course_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_submissions(
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_filter_any VARCHAR(255),
    p_submission_id INT UNSIGNED,
    p_status VARCHAR(255),
    p_title VARCHAR(255),
    p_submitted_by INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM assignment
        WHERE id = p_assignment_id AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
        SET MESSAGE_TEXT = 'Assignment does not exist.';
    END IF;

    SELECT
        sub.id,
        sub.status,
        sub.score,
        sub.title,
        sub.content,
        sub.submitted_at,
        sub.assignment_id,
        sub.submitted_by
    FROM submission sub
        INNER JOIN assignment ag ON sub.assignment_id = ag.id
    WHERE
        sub.assignment_id = p_assignment_id
        AND ag.course_id = p_course_id
        AND (p_assignment_id IS NULL OR sub.assignment_id = p_assignment_id)
        AND (
            p_filter_any IS NULL OR sub.status LIKE CONCAT('%', p_filter_any, '%')
            OR sub.title LIKE CONCAT('%', p_filter_any, '%')
            OR ag.title LIKE CONCAT('%', p_filter_any, '%')
        )
        AND (p_submission_id IS NULL OR sub.id = p_submission_id)
        AND (p_status IS NULL OR sub.status = p_status)
        AND (p_title IS NULL OR sub.title = p_title)
        AND (p_submitted_by IS NULL OR sub.submitted_by = p_submitted_by);

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_submission(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_submission_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT is_instructor(p_user_id) AND NOT EXISTS (
        SELECT 1 FROM submission
        WHERE id = p_submission_id AND submitted_by = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'You are not authorized to access this resouce.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Course does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM assignment
        WHERE id = p_assignment_id AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Assignment does not exist.';
    END IF;

    SELECT * FROM submission_detail_view
    WHERE
        assignment_id = p_assignment_id
        AND course_id = p_course_id
        AND id = p_submission_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE delete_submission(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_submission_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT 1 FROM submission
        WHERE submitted_by = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'This account doesn\'t have permission to delete this submission.';
    END IF;

    SELECT at.file_path
    FROM attachment at
         INNER JOIN submission sub ON at.id = sub.attachment_id
    WHERE sub.id = p_submission_id;

    DELETE FROM submission
    WHERE assignment_id = p_assignment_id AND id = p_submission_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE add_submission(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_assignment_id INT UNSIGNED,
    p_attachment_id INT UNSIGNED,
    p_title VARCHAR(255),
    p_content TEXT
)
BEGIN
    DECLARE assignment_due_date DATETIME;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT 1 FROM enrollment
        WHERE student_id = p_user_id AND status = 'ACTIVE'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This student is not actively enrolled in the course';
    END IF;

    SELECT due_date INTO assignment_due_date
    FROM assignment
    WHERE id = p_assignment_id;

    IF NOW() > assignment_due_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The assignment is past the due date.';
    END IF;

    INSERT INTO submission (status, submitted_by, assignment_id, attachment_id, title, content)
    VALUES
        ('NOT GRADED', p_user_id, p_assignment_id, p_attachment_id, p_title, p_content);

    CALL get_submission(p_course_id, p_assignment_id, LAST_INSERT_ID());

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE add_attachment(
    p_user_id INT UNSIGNED,
    p_file_name VARCHAR(255),
    p_file_path VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF LENGTH(p_file_name) = 0 OR p_file_path IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'File name cannot be empty.';
    END IF;

    IF LENGTH(p_file_path) = 0 OR p_file_path IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'File name cannot be empty.';
    END IF;

    INSERT INTO attachment
        (file_name, file_path, owner)
    VALUES
        (p_file_name, p_file_path, p_user_id);

    SELECT
        at.id,
        at.file_name,
        at.file_path,
        at.owner,
        ac.username,
        ac.email,
        ac.first_name,
        ac.last_name,
        ac.role
    FROM attachment at
        INNER JOIN account ac
    WHERE at.id = LAST_INSERT_ID();

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_posts(
    p_course_id INT UNSIGNED,
    p_filter_any VARCHAR(255),
    p_id INT UNSIGNED,
    p_title VARCHAR(255),
    p_content TEXT,
    p_posted_by INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT
        p.id,
        p.title,
        p.content,
        p.course_id,
        p.posted_by,
        a.first_name,
        a.last_name,
        a.username,
        a.email,
        a.role
    FROM post p
        INNER JOIN account a ON p.posted_by = a.id
    WHERE
        p.course_id = p_course_id AND
        (
            p_filter_any IS NULL OR
            p.id LIKE CONCAT('%', p_filter_any, '%') OR
            p.title LIKE CONCAT('%', p_filter_any, '%') OR
            p.content LIKE CONCAT('%', p_filter_any, '%') OR
            p.posted_by LIKE CONCAT('%', p_filter_any, '%')
        ) AND
        (p_id IS NULL OR p.id = p_id) AND
        (p_title IS NULL OR p.title LIKE CONCAT('%', p_title, '%')) AND
        (p_content IS NULL OR p.content LIKE CONCAT('%', p_content, '%')) AND
        (p_posted_by IS NULL OR p.posted_by = p_posted_by);

   COMMIT;
END;

CREATE OR REPLACE PROCEDURE get_post(
    p_course_id INT UNSIGNED,
    p_post_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT
        p.id,
        p.title,
        p.content,
        p.posted_by,
        a.first_name,
        a.last_name,
        a.username,
        a.email,
        a.role,
        p.course_id,
        c.name,
        c.description
    FROM post p
        INNER JOIN account a ON p.posted_by = a.id
        INNER JOIN course c ON p.course_id = c.id
    WHERE
        p.course_id = p_course_id AND p.id = p_post_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE add_post(
    p_user_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_title VARCHAR(255),
    p_content TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT 1
        FROM course_instructor
        WHERE instructor_id = p_user_id
          AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF LENGTH(p_title) = 0 OR p_title IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Title cannot be empty.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
        SET MESSAGE_TEXT = 'Course does not exist.';
    end if;

    INSERT INTO post
        (title, content, course_id, posted_by)
    VALUES
        (p_title, p_content, p_course_id, p_user_id);

    SELECT title, content, course_id, post.posted_by
    FROM post
    WHERE id = LAST_INSERT_ID();

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE edit_post(
    p_user_id INT UNSIGNED,
    p_post_id INT UNSIGNED,
    p_course_id INT UNSIGNED,
    p_title VARCHAR(255),
    p_content TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT 1
        FROM course_instructor
        WHERE instructor_id = p_user_id
          AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Course does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM post
        WHERE id = p_post_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Post does not exist.';
    END IF;

    UPDATE post
    SET title = IFNULL(p_title, title),
        content = IFNULL(p_content, content),
        posted_by = IFNULL(p_user_id, posted_by)
    WHERE id = p_post_id;

    SELECT title, content, course_id, posted_by
    FROM post
    WHERE id = p_post_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE delete_post(
    p_user_id INT UNSIGNED,
    p_post_id INT UNSIGNED,
    p_course_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_admin(p_user_id) AND NOT EXISTS (
        SELECT 1
        FROM course_instructor
        WHERE instructor_id = p_user_id
          AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This account doesn\'t have permission for this course.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM course
        WHERE id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Course does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM post
        WHERE id = p_post_id
    ) THEN
        SIGNAL SQLSTATE '45404'
            SET MESSAGE_TEXT = 'Post does not exist.';
    END IF;

    DELETE FROM post
    WHERE id = p_post_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE register (
    p_username VARCHAR(255),
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    p_fname VARCHAR(255),
    p_lname VARCHAR(255),
    p_role VARCHAR(255)
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

    IF p_role NOT IN ('STUDENT', 'INSTRUCTOR') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role does not exist.';
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

    SELECT id, user_id, expires_at
    FROM session
    WHERE id = p_session_id;

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
        SIGNAL SQLSTATE '45401'
        SET MESSAGE_TEXT = 'No authorization included in the request.';
    END IF;

    IF curr_time >= expires_at - INTERVAL 12 HOUR THEN
        SET expires_at = curr_time + INTERVAL 1 DAY;
        UPDATE session SET expires_at = expires_at WHERE id = session_id;
    END IF;

    SELECT id, user_id, expires_at
    FROM session
    WHERE id = session_id;

    CALL get_account_from_session(p_session_id);

    COMMIT;
END;

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
END;

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

CREATE OR REPLACE PROCEDURE get_account_from_session(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT a.id, a.username, a.email, a.first_name, a.last_name, a.role
    FROM session s
        INNER JOIN account a ON s.user_id = a.id
    WHERE s.id = p_session_id;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE check_admin(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_admin(id_from_session(p_session_id)) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'You are not authorized to access this resource.';
    END IF;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE check_instructor(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_instructor(id_from_session(p_session_id)) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'You are not authorized to access this resource.';
    END IF;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE check_student(
    p_session_id VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    IF NOT is_student(id_from_session(p_session_id)) THEN
        SIGNAL SQLSTATE '45403'
            SET MESSAGE_TEXT = 'You are not authorized to access this resource.';
    END IF;

    COMMIT;
END;
