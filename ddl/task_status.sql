CREATE TABLE IF NOT EXISTS task_status (
    task_uuid uuid PRIMARY KEY,
    task_name varchar(128),
    task_version varchar(12),
    task_path varchar(128),
    task_concurrency int,
    task_status varchar(24),
    task_request json,
    task_priority smallint,
    task_request_time timestamp without time zone,
    task_start_time timestamp without time zone,
    task_end_time timestamp without time zone
);
