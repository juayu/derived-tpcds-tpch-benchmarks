CREATE TABLE IF NOT EXISTS task_load_status(
	task_uuid uuid REFERENCES task_status (task_uuid),
    tablename VARCHAR(128), 
    dataset VARCHAR(15), 
    status VARCHAR(10), 
    load_start TIMESTAMP, 
    load_end TIMESTAMP, 
    rows_d BIGINT, 
    size_d INT, 
    query_id INT, 
    querytext VARCHAR(512)  
);
