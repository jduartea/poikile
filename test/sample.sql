-- Poikile Theme — SQL Test File
--
-- Colors vary by variant — see PALETTE.md for hex values per theme.
--
-- Scopes to verify:
--   keyword.other.DML.sql          → keyword  (SELECT, INSERT, UPDATE, DELETE, FROM, WHERE, JOIN, ON, GROUP BY, ORDER BY, HAVING, LIMIT, OFFSET, UNION)
--   keyword.other.DDL.sql          → keyword  (CREATE, ALTER, DROP, TRUNCATE, TABLE, INDEX, VIEW, DATABASE, SCHEMA)
--   keyword.other.sql              → keyword  (AS, IN, BETWEEN, LIKE, EXISTS, IS, NOT, NULL, AND, OR, DISTINCT, ALL, ANY, CASE, WHEN, THEN, ELSE, END)
--   keyword.other.alias.sql        → keyword  (AS)
--   storage.type.sql               → type  (INT, VARCHAR, TEXT, BOOLEAN, DATE, TIMESTAMP, FLOAT, DECIMAL, SERIAL, UUID)
--   support.function.sql           → function  (COUNT, SUM, AVG, MIN, MAX, COALESCE, CAST, NOW, UPPER, LOWER, LENGTH)
--   entity.name.function.sql       → function  (user-defined function names)
--   constant.other.table-name.sql  → type  (table names)
--   string.quoted.single.sql       → string  (string values)
--   constant.numeric.sql           → number  (numbers)
--   keyword.operator.comparison.sql → fg.subtle (=, <>, <, >, <=, >=)
--   keyword.operator.star.sql      → fg.subtle  (*)
--   comment                        → fg.muted  italic

-- ═══════════════════════════════════════════════════════════════════════
-- DDL: Schema & Table Definitions
-- ═══════════════════════════════════════════════════════════════════════

CREATE SCHEMA IF NOT EXISTS poikile;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE poikile.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'viewer'
        CHECK (role IN ('admin', 'editor', 'viewer', 'guest')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    login_count INT NOT NULL DEFAULT 0,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Tasks table
CREATE TABLE poikile.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled')),
    priority SMALLINT NOT NULL DEFAULT 2
        CHECK (priority BETWEEN 1 AND 4),
    assignee_id UUID REFERENCES poikile.users(id) ON DELETE SET NULL,
    due_date DATE,
    estimated_hours DECIMAL(5, 2),
    actual_hours DECIMAL(5, 2),
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Task comments
CREATE TABLE poikile.task_comments (
    id SERIAL PRIMARY KEY,
    task_id UUID NOT NULL REFERENCES poikile.tasks(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES poikile.users(id),
    body TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_tasks_status ON poikile.tasks(status);
CREATE INDEX idx_tasks_assignee ON poikile.tasks(assignee_id) WHERE assignee_id IS NOT NULL;
CREATE INDEX idx_tasks_priority_status ON poikile.tasks(priority DESC, status);
CREATE INDEX idx_tasks_tags ON poikile.tasks USING GIN(tags);
CREATE INDEX idx_tasks_metadata ON poikile.tasks USING GIN(metadata jsonb_path_ops);
CREATE UNIQUE INDEX idx_users_email_lower ON poikile.users(LOWER(email));

-- ═══════════════════════════════════════════════════════════════════════
-- DML: Inserts
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO poikile.users (email, name, password_hash, role) VALUES
    ('ada@example.com', 'Ada Lovelace', crypt('password123', gen_salt('bf')), 'admin'),
    ('alan@example.com', 'Alan Turing', crypt('password456', gen_salt('bf')), 'editor'),
    ('grace@example.com', 'Grace Hopper', crypt('password789', gen_salt('bf')), 'viewer');

INSERT INTO poikile.tasks (title, description, status, priority, assignee_id, tags, estimated_hours)
SELECT
    'Task ' || generate_series AS title,
    'Description for task ' || generate_series AS description,
    CASE (generate_series % 4)
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'running'
        WHEN 2 THEN 'completed'
        ELSE 'failed'
    END AS status,
    (generate_series % 4) + 1 AS priority,
    (SELECT id FROM poikile.users ORDER BY RANDOM() LIMIT 1) AS assignee_id,
    ARRAY['batch', 'auto-generated'] AS tags,
    ROUND((RANDOM() * 40)::NUMERIC, 1) AS estimated_hours
FROM generate_series(1, 50);

-- ═══════════════════════════════════════════════════════════════════════
-- Queries: SELECT Patterns
-- ═══════════════════════════════════════════════════════════════════════

-- Basic select with joins
SELECT
    t.id,
    t.title,
    t.status,
    t.priority,
    u.name AS assignee_name,
    u.email AS assignee_email,
    COUNT(c.id) AS comment_count
FROM poikile.tasks t
LEFT JOIN poikile.users u ON u.id = t.assignee_id
LEFT JOIN poikile.task_comments c ON c.task_id = t.id
WHERE t.status != 'cancelled'
  AND t.created_at >= NOW() - INTERVAL '30 days'
GROUP BY t.id, t.title, t.status, t.priority, u.name, u.email
HAVING COUNT(c.id) > 0
ORDER BY t.priority DESC, t.created_at ASC
LIMIT 25
OFFSET 0;

-- Subquery and EXISTS
SELECT u.id, u.name, u.email
FROM poikile.users u
WHERE EXISTS (
    SELECT 1
    FROM poikile.tasks t
    WHERE t.assignee_id = u.id
      AND t.status = 'running'
      AND t.priority >= 3
)
AND u.is_active = TRUE;

-- CTE (Common Table Expression)
WITH task_stats AS (
    SELECT
        assignee_id,
        COUNT(*) AS total_tasks,
        COUNT(*) FILTER (WHERE status = 'completed') AS completed_tasks,
        AVG(actual_hours) AS avg_hours,
        MAX(completed_at) AS last_completion
    FROM poikile.tasks
    WHERE assignee_id IS NOT NULL
    GROUP BY assignee_id
),
ranked_users AS (
    SELECT
        u.id,
        u.name,
        ts.total_tasks,
        ts.completed_tasks,
        ROUND(
            (ts.completed_tasks::DECIMAL / NULLIF(ts.total_tasks, 0)) * 100,
            1
        ) AS completion_rate,
        RANK() OVER (ORDER BY ts.completed_tasks DESC) AS rank
    FROM poikile.users u
    JOIN task_stats ts ON ts.assignee_id = u.id
)
SELECT *
FROM ranked_users
WHERE rank <= 10
ORDER BY completion_rate DESC NULLS LAST;

-- Window functions
SELECT
    id,
    title,
    priority,
    status,
    created_at,
    ROW_NUMBER() OVER (PARTITION BY status ORDER BY created_at) AS row_num,
    LAG(title) OVER (ORDER BY created_at) AS previous_task,
    LEAD(title) OVER (ORDER BY created_at) AS next_task,
    SUM(estimated_hours) OVER (
        PARTITION BY assignee_id
        ORDER BY created_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_hours
FROM poikile.tasks
WHERE priority IN (3, 4)
ORDER BY created_at;

-- CASE expressions
SELECT
    t.id,
    t.title,
    CASE t.priority
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Critical'
        ELSE 'Unknown'
    END AS priority_label,
    CASE
        WHEN t.status = 'completed' AND t.actual_hours <= t.estimated_hours THEN 'On time'
        WHEN t.status = 'completed' AND t.actual_hours > t.estimated_hours THEN 'Over estimate'
        WHEN t.due_date < CURRENT_DATE AND t.status NOT IN ('completed', 'cancelled') THEN 'Overdue'
        ELSE 'In progress'
    END AS time_status,
    COALESCE(t.actual_hours, t.estimated_hours, 0) AS hours
FROM poikile.tasks t;

-- UNION
SELECT id, title, 'high_priority' AS source
FROM poikile.tasks
WHERE priority >= 3

UNION ALL

SELECT id, title, 'overdue' AS source
FROM poikile.tasks
WHERE due_date < CURRENT_DATE
  AND status NOT IN ('completed', 'cancelled')

ORDER BY title;

-- JSON operations
SELECT
    id,
    title,
    metadata->>'category' AS category,
    metadata->'config'->>'retry_count' AS retry_count,
    jsonb_array_length(COALESCE(metadata->'history', '[]'::JSONB)) AS history_count
FROM poikile.tasks
WHERE metadata @> '{"urgent": true}'
   OR metadata ? 'escalated';

-- ═══════════════════════════════════════════════════════════════════════
-- DML: Updates & Deletes
-- ═══════════════════════════════════════════════════════════════════════

UPDATE poikile.tasks
SET
    status = 'cancelled',
    updated_at = NOW(),
    metadata = metadata || '{"cancelled_reason": "stale"}'::JSONB
WHERE status = 'pending'
  AND created_at < NOW() - INTERVAL '90 days';

DELETE FROM poikile.task_comments
WHERE created_at < NOW() - INTERVAL '1 year';

-- ═══════════════════════════════════════════════════════════════════════
-- DDL: Views & Functions
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW poikile.active_tasks AS
SELECT
    t.id,
    t.title,
    t.status,
    t.priority,
    u.name AS assignee,
    t.due_date,
    CURRENT_DATE - t.due_date AS days_overdue
FROM poikile.tasks t
LEFT JOIN poikile.users u ON u.id = t.assignee_id
WHERE t.status NOT IN ('completed', 'cancelled', 'failed');

CREATE OR REPLACE FUNCTION poikile.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tasks_update_timestamp
    BEFORE UPDATE ON poikile.tasks
    FOR EACH ROW
    EXECUTE FUNCTION poikile.update_timestamp();

-- ═══════════════════════════════════════════════════════════════════════
-- DDL: Alter & Drop
-- ═══════════════════════════════════════════════════════════════════════

ALTER TABLE poikile.tasks ADD COLUMN archived BOOLEAN DEFAULT FALSE;
ALTER TABLE poikile.tasks ALTER COLUMN title SET NOT NULL;
ALTER TABLE poikile.users ADD CONSTRAINT chk_email CHECK (email ~* '^[^@]+@[^@]+\.[^@]+$');

-- TRUNCATE poikile.task_comments;
-- DROP TABLE IF EXISTS poikile.tasks CASCADE;
-- DROP SCHEMA poikile CASCADE;
