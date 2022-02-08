SELECT [ReadLatency]=CASE WHEN [num_of_reads]=0 THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads])END, [WriteLatency]=CASE WHEN [num_of_writes]=0 THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes])END, [Latency]=CASE WHEN([num_of_reads]=0 AND [num_of_writes]=0) THEN 0 ELSE ([io_stall] /([num_of_reads]+[num_of_writes]))END, [Latency Desc]=CASE WHEN([num_of_reads]=0 AND [num_of_writes]=0) THEN 'N/A' ELSE CASE WHEN([io_stall] /([num_of_reads]+[num_of_writes]))<2 THEN 'Excellent'
                                                                                                                                                                                                                                                                                                                                                                                                                     WHEN([io_stall] /([num_of_reads]+[num_of_writes]))<6 THEN 'Very good'
                                                                                                                                                                                                                                                                                                                                                                                                                     WHEN([io_stall] /([num_of_reads]+[num_of_writes]))<11 THEN 'Good'
                                                                                                                                                                                                                                                                                                                                                                                                                     WHEN([io_stall] /([num_of_reads]+[num_of_writes]))<21 THEN 'Poor'
                                                                                                                                                                                                                                                                                                                                                                                                                     WHEN([io_stall] /([num_of_reads]+[num_of_writes]))<101 THEN 'Bad'
                                                                                                                                                                                                                                                                                                                                                                                                                     WHEN([io_stall] /([num_of_reads]+[num_of_writes]))<501 THEN 'Worse' ELSE 'Worst' END END, [AvgBPerRead]=CASE WHEN [num_of_reads]=0 THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads])END, [AvgBPerWrite]=CASE WHEN [num_of_writes]=0 THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes])END, [AvgBPerTransfer]=CASE WHEN([num_of_reads]=0 AND [num_of_writes]=0) THEN 0 ELSE (([num_of_bytes_read]+[num_of_bytes_written])/([num_of_reads]+[num_of_writes]))END, LEFT([mf].[physical_name], 2) AS [Drive], DB_NAME([vfs].[database_id]) AS [DB], [mf].[physical_name]
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [vfs]
     JOIN sys.master_files AS [mf] ON [vfs].[database_id]=[mf].[database_id] AND [vfs].[file_id]=[mf].[file_id]
--WHERE DB_NAME ([vfs].[database_id])='DBA' -- db name
ORDER BY [Latency] DESC
-- ORDER BY [ReadLatency] DESC
-- ORDER BY [WriteLatency] DESC;
GO

----------------------------------------------
select left(mf.physical_name, 1)     as drive_letter
     , sample_ms
     , sum(vfs.num_of_writes)        as total_num_of_writes
     , sum(vfs.num_of_bytes_written) as total_num_of_bytes_written
     , sum(vfs.io_stall_write_ms)    as total_io_stall_write_ms
     , sum(vfs.num_of_reads)         as total_num_of_reads
     , sum(vfs.num_of_bytes_read)    as total_num_of_bytes_read
     , sum(vfs.io_stall_read_ms)     as total_io_stall_read_ms
     , sum(vfs.io_stall)             as total_io_stall
     , sum(vfs.size_on_disk_bytes)   as total_size_on_disk_bytes
from sys.master_files                             mf
    join sys.dm_io_virtual_file_stats(NULL, NULL) vfs
        on mf.database_id = vfs.database_id
           and mf.file_id = vfs.file_id
group by left(mf.physical_name, 1)
       , sample_ms
