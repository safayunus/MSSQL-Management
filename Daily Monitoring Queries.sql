
-- How to get instance name?

select @@SERVERNAME

-- How to get SQL Server version?

select @@version

-- How to show the full space percentage of the log files?


dbcc sqlperf(logspace)

-- How to show free space on disks?


exec xp_fixeddrives

-- How to get last restarted date of SQL Server?


select sqlserver_start_time
from sys.dm_os_sys_info

-- How to check databases size in SQL Server?


exec sp_helpdb
exec sp_helpdb 'AdventureWorks2019' ---> it returns details for spesific database
exec sp_databases
--- alternative

-- How to get blocking queries?


select *
from sys.sysprocesses
where blocked <> 0

-- List databases with state


select name
     , state_desc
from sys.databases



-- How to get all my databases last full, diff, tran backup info


select db_name
     , backup_type
     , backup_size_in_MB
     , backup_start_date
     , backup_finish_date
     , is_copy_only
     , physical_device_name
     , recovery_model_desc
from
(
    select d.database_id
         , d.name                                                      as db_name
         , case backup_types.Backup_Type
               when 'D' then
                   'Full Backup'
               when 'I' then
                   'Differential Backup'
               when 'L' then
                   'Transaction Log Backup'
           end                                                         as 'backup_type'
         , cast(bs.compressed_backup_size / 1048576 as decimal(15, 2)) as 'backup_size_in_MB'
         , bs.backup_start_date
         , bs.backup_finish_date
         , bs.is_copy_only
         , bmf.physical_device_name
         , d.recovery_model_desc
         , row_number() over (partition by d.database_id
                                         , backup_types.Backup_Type
                              order by bs.backup_start_date desc
                             )                                         as rwn
    from sys.databases as d
        cross join
        (
            select 'D' as Backup_Type
            union
            select 'I'
            union
            select 'L'
        )              as backup_types
        left join msdb.dbo.backupset         as bs
            on (
                   d.name = bs.database_name
                   and backup_types.Backup_Type = bs.type
               )
        left join msdb.dbo.backupmediafamily as bmf
            on bs.media_set_id = bmf.media_set_id
    where isnull(bs.is_copy_only, 0) = 0 --- if you want to filter copy_only backups
) as tbl
where tbl.rwn = 1
      and tbl.database_id > 4 --- eliminate system databases
order by tbl.database_id asc

-- How to get all indexes on a spesific table in SQL Server?



exec sp_helpindex 'HumanResources.Department'


-- How to list all indexes with last statistics updated date


SELECT OBJECT_NAME(object_id)          as table_name
     , name                            AS index_name
     , STATS_DATE(object_id, index_id) AS StatsUpdated
FROM sys.indexes
order by StatsUpdated desc

--How to list users and roles
select r.name as Role,
       m.name as Principal
from master.sys.server_role_members rm
    inner join master.sys.server_principals r
        on r.principal_id = rm.role_principal_id
           and r.type = 'R'
    inner join master.sys.server_principals m
        on m.principal_id = rm.member_principal_id

-- How to list logins and server  roles

SELECT spU.name, MAX(CASE WHEN srm.role_principal_id=3 THEN 1 END) AS sysadmin, MAX(CASE WHEN srm.role_principal_id=4 THEN 1 END) AS securityadmin, MAX(CASE WHEN srm.role_principal_id=5 THEN 1 END) AS serveradmin, MAX(CASE WHEN srm.role_principal_id=6 THEN 1 END) AS setupadmin, MAX(CASE WHEN srm.role_principal_id=7 THEN 1 END) AS processadmin, MAX(CASE WHEN srm.role_principal_id=8 THEN 1 END) AS diskadmin, MAX(CASE WHEN srm.role_principal_id=9 THEN 1 END) AS dbcreator, MAX(CASE WHEN srm.role_principal_id=10 THEN 1 END) AS bulkadmin
FROM sys.server_principals AS spR
     JOIN sys.server_role_members AS srm ON spR.principal_id=srm.role_principal_id
     JOIN sys.server_principals AS spU ON srm.member_principal_id=spU.principal_id
WHERE spR.[type]='R'
GROUP BY spU.name


-- List DB and owners
SELECT name, suser_sname(owner_sid) AS DBOwner FROM sys.databases


-- List Jobs and owners
SELECT s.name AS JobName, l.name AS JobOwner
FROM msdb..sysjobs s
LEFT JOIN master.sys.syslogins l ON s.owner_sid = l.sid
WHERE l.name IS NOT NULL
ORDER by l.name

-- number of connections per DB
SELECT DB_NAME(dbid) as DBName,
       COUNT(dbid) as NumberOfConnections,
       loginame as LoginName
FROM sys.sysprocesses
WHERE dbid > 0
GROUP BY dbid,
         loginame
