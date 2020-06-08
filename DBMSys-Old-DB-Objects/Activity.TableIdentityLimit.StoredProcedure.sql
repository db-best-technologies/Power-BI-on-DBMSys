/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.1601)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/
USE [DBMSYS_CityofTucson_City_of_Tucson]
GO
/****** Object:  StoredProcedure [Activity].[TableIdentityLimit]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Activity].[TableIdentityLimit]
--DECLARE
	@EventDescription nvarchar(1000) = ''
AS
SELECT 
		TIL_MOB_ID AS F_MOB_ID
		,TIL_DatabaseName + '.' + TIL_TableName AS F_InstanceName
		,'Column ' + TIL_ColumnName + ' for table ' + TIL_TableName + ' reached the limit' + CHAR(10)
		+ 'Column Type: ' + TIL_ColumnType + CHAR(10)
		+ 'Max value: ' + CAST(TIL_MaxValue AS NVARCHAR(50)) + CHAR(10)
		+ 'Current value: ' + CAST(TIL_CurrValue AS NVARCHAR(50)) + CHAR(10)
		+ 'Current identity value: ' + CAST(TIL_IdentCurr AS NVARCHAR(50)) + CHAR(10)
		+ 'Incrementor: ' + CAST(TIL_IdentityIncr AS NVARCHAR(50)) + CHAR(10)
		+ 'Last seen date: ' + CONVERT(NVARCHAR(10),TIL_LastSeenDate,121) AS AlertMessage
		, (
			select	@EventDescription					[@EventDescription]
					,MOB_ID								[@MOB_ID]
					,MOB_Name							[@MOB_Name]
					,TIL_DatabaseName					[DatabaseName]
					,TIL_TableName						[TableName]
					,TIL_ColumnName						[ColumnName]
					,TIL_TableName						[TableName]
					,TIL_ColumnType 					[ColumnType]
					,TIL_MaxValue						[MaxValue]
					,TIL_CurrValue						[CurrValue]
					,TIL_IdentCurr						[IdentCurr]
					,TIL_IdentityIncr					[IdentityIncr]
					,TIL_LastSeenDate					[LastSeenDate]
					for xml path('Alert'), root('Alerts'), type
		) AS AlertEventData
	--	,* 
FROM	Activity.TableIdentityLimited
JOIN	Inventory.MonitoredObjects ON TIL_MOB_ID = MOB_ID
WHERE	TIL_IsDeleted = 0
GO
