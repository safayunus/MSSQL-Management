SELECT o.name AS [Table]        
      , i.name AS [Index]
      , c.name AS [Column]
      , i.type_desc as [Index Type]
      , i.is_primary_key
      , TYPE_NAME(c.system_type_id) as Datatype
      , dc.name AS DefaultConstraint
      , dc.definition as SQLFunction
 FROM sys.objects o
 INNER JOIN sys.indexes i ON i.object_id = o.object_id
 INNER JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id = i.index_id
 INNER JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id = ic.column_id
 INNER JOIN sys.default_constraints as dc on dc.parent_object_id=c.object_id
 WHERE
     i.index_id = 1
     AND i.is_primary_key = 1
     AND c.system_type_id in ('36')
 ORDER BY
     o.name;