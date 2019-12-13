
SELECT
    OBJECT_NAME(ind.OBJECT_ID)        AS TableName,
    object_schema_name(ind.object_id) AS ObjectSchema,
    ind.name                          AS IndexName,
    indexstats.index_type_desc        AS IndexType,
    indexstats.avg_fragmentation_in_percent,
	 'ALTER INDEX ' +  ind.name  + ' ON ' + object_schema_name(ind.object_id) + '.' + OBJECT_NAME(ind.OBJECT_ID) + ' REBUILD; '
  FROM 
	sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
    INNER JOIN sys.indexes ind ON ind.object_id = indexstats.object_id
                                  AND ind.index_id = indexstats.index_id
  WHERE
    indexstats.avg_fragmentation_in_percent > 5
    AND ind.Name IS NOT NULL-- AND indexstats.page_count > 1000
  ORDER BY indexstats.avg_fragmentation_in_percent DESC

