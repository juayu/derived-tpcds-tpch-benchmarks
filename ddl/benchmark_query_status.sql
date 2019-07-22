CREATE TABLE IF NOT EXISTS benchmark_query_status(
	task_uuid uuid REFERENCES task_status (task_uuid),
    scale varchar(10),
    stream varchar(10),
    benchmark_query_template varchar(20),
    template_file_path varchar(255),
    query_order_in_stream smallint,
    tpc_benchmark varchar(10),
    pid int,
    client_starttime timestamp,
    client_endtime timestamp,
    redshift_query_start timestamp,
    redshift_query_end timestamp,
    total_queue_time_ms double precision, 
	total_compile_time_ms double precision,
    query_ids varchar(128)
)
