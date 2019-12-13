DECLARE @tablename NVARCHAR(128)
DECLARE @tableschema NVARCHAR(128)
DECLARE @Statement NVARCHAR(300)

DECLARE updatestats CURSOR FOR
SELECT table_schema, table_name FROM information_schema.tables
	where TABLE_TYPE = 'BASE TABLE'
OPEN updatestats

FETCH NEXT FROM updatestats INTO @tableschema, @tablename
WHILE (@@FETCH_STATUS = 0)
BEGIN
   PRINT N'UPDATING STATISTICS ' + @tableschema + '.' + @tablename
   SET @Statement = 'UPDATE STATISTICS '  + @tableschema + '.' + @tablename + '  WITH FULLSCAN'
   EXEC sp_executesql @Statement
   FETCH NEXT FROM updatestats INTO @tableschema, @tablename
END
CLOSE updatestats
DEALLOCATE updatestats
