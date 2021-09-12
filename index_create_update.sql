SELECT object_schema_name(objects.parent_object_id) AS Object_Schema_Name, 
    object_name(objects.parent_object_id) AS Object_Name, 
    sys.indexes.name AS Index_Name,
    sys.objects.create_date, sys.objects.modify_date
FROM sys.objects
JOIN sys.indexes
    ON objects.parent_object_id = indexes.object_id
    AND objects.name = indexes.name
    -- Check for Unique Constraint & Primary key
    AND objects.type IN ('UQ','PK')
	order by 5 desc 