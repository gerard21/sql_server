--Query fragmentation on RF tables
DECLARE @tableName NVARCHAR(500)
DECLARE @schemaName NVARCHAR(500)
DECLARE @indexName NVARCHAR(500)
DECLARE @indexType NVARCHAR(55)
DECLARE @percentFragment DECIMAL(11, 2)

DECLARE FragmentedTableList CURSOR FOR
  SELECT
    OBJECT_NAME(ind.OBJECT_ID)        AS TableName,
    object_schema_name(ind.object_id) AS ObjectSchema,
    ind.name                          AS IndexName,
    indexstats.index_type_desc        AS IndexType,
    indexstats.avg_fragmentation_in_percent
  FROM 
	sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
    INNER JOIN sys.indexes ind ON ind.object_id = indexstats.object_id
                                  AND ind.index_id = indexstats.index_id
  WHERE
    indexstats.avg_fragmentation_in_percent > 5
    AND ind.Name IS NOT NULL AND indexstats.page_count > 1000
  ORDER BY indexstats.avg_fragmentation_in_percent DESC

OPEN FragmentedTableList

FETCH NEXT FROM FragmentedTableList
INTO @tableName, @schemaName, @indexName, @indexType, @percentFragment

WHILE @@FETCH_STATUS = 0
  BEGIN
    PRINT 'Processing ' + @indexName + 'on table ' + @schemaName + '.' + @tableName + ' which is ' +
          cast(@percentFragment AS NVARCHAR(50)) + ' fragmented'

    IF (@percentFragment > 30)
      BEGIN
        EXEC ( 'ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName + ' REBUILD; ')
        PRINT 'Finished rebuilding ' + @indexName + 'on table ' + @schemaName + '.' + @tableName
      END
    ELSE
      BEGIN
        EXEC ( 'ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName + ' REORGANIZE;')
        PRINT 'Finished reorganizing ' + @indexName + 'on table ' + @schemaName + '.' + @tableName
      END

    FETCH NEXT FROM FragmentedTableList
    INTO @tableName, @schemaName, @indexName, @indexType, @percentFragment
  END

CLOSE FragmentedTableList
