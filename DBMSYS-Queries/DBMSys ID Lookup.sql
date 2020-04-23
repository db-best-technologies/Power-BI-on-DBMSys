USE [DBMSYS_ScottishParliament_Scottish_Parliament]
GO

declare  @code AS VARCHAR(50) = 'IDB_Name%';

SELECT s.name AS [Schema Name], c.name AS [Column Name], t.name AS [Table Name]
FROM  sys.all_columns AS c INNER JOIN
         sys.tables AS t ON c.object_id = t.object_id INNER JOIN
         sys.schemas AS s ON t.schema_id = s.schema_id
WHERE (c.name LIKE @code)
ORDER BY [Schema Name], [Column Name]