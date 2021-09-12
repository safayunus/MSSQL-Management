SELECT OS.* , S.Session_Id , S.waiting_tasks_count , S.wait_time_ms , S.max_wait_time_ms , S.signal_wait_time_ms 
FROM sys.dm_os_wait_stats OS INNER JOIN sys.dm_exec_session_wait_stats S ON OS.wait_type = S.wait_type where session_id<> 51


