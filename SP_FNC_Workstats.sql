SELECT DB_NAME(st.dbid)                      DBName
     , OBJECT_SCHEMA_NAME(st.objectid, dbid) SchemaName
     , OBJECT_NAME(st.objectid, dbid)        StoredProcedure
     , MAX(cp.usecounts)                     Execution_count
--,cp.objtype
FROM sys.dm_exec_cached_plans                        cp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE DB_NAME(st.dbid) IS NOT NULL
      AND cp.objtype = 'proc'
--AND OBJECT_NAME(st.objectid, dbid) LIKE 'fnc_GetTaskMoreMinute'
GROUP BY cp.plan_handle
       , DB_NAME(st.dbid)
       , OBJECT_SCHEMA_NAME(objectid, st.dbid)
       , OBJECT_NAME(objectid, st.dbid)
--,cp.objtype
ORDER BY MAX(cp.usecounts) DESC
GO
