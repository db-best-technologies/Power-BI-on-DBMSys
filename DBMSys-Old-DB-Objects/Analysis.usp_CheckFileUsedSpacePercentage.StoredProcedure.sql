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
/****** Object:  StoredProcedure [Analysis].[usp_CheckFileUsedSpacePercentage]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Analysis].[usp_CheckFileUsedSpacePercentage]
	@EventDescription nvarchar(1000)
as
set nocount on
declare @AlertAtPercentage tinyint = 85

select IDB_MOB_ID MOB_ID, IDB_Name + ' (' + DBF_FileName + ')' InstanceName,
	'File ' + DBF_FileName + ' of database ' + IDB_Name + ' has only ' + cast(cast(100 - CRS_Value*100/DBF_MaxSizeMB as int) as varchar(100)) + '% ('
		+ cast(ceiling(DBF_MaxSizeMB - CRS_Value) as varchar(100)) + 'MB) free remaining' AlertMessage,
	(select @EventDescription [@EventDescription], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name], IDB_Name [@DatabaseName], DBF_FileName [@FileName],
			cast(100 - CRS_Value*100/DBF_MaxSizeMB as int) [@PercentFree], ceiling(DBF_MaxSizeMB - CRS_Value) [@MBFree]
		for xml path('Alert'), root('Alerts'), type) AlertEventData
from Inventory.DatabaseFiles
	inner join Inventory.InstanceDatabases on IDB_ID = DBF_IDB_ID
	inner join Inventory.MonitoredObjects on MOB_ID = IDB_MOB_ID
	cross apply (select top 1 *
					from PerformanceData.CounterResults
						inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
					where CRS_MOB_ID = 1
						and CRS_SystemID = 3
						and CRS_CounterID = 42
						and CIN_Name = DBF_FileName
					order by CRS_DateTime desc) c
where DBF_DFT_ID = 0
	and DBF_MaxSizeMB > 0
	and DBF_IsReadOnly = 0
	and cast(CRS_Value*100/DBF_MaxSizeMB as int) > @AlertAtPercentage
	and MOB_OOS_ID IN (0,1)
GO
