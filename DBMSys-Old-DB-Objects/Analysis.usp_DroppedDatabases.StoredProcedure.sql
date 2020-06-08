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
/****** Object:  StoredProcedure [Analysis].[usp_DroppedDatabases]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Analysis].[usp_DroppedDatabases]
	@EventDescription nvarchar(1000)
as
set nocount on
declare @DroppedHoursAgo int = 2,
		@HoursBackToCheck int = 1

;with DroppedDatabases as
		(select MOB_ID, MOB_Name, DDE_DatabaseName DatabaseName, max(DDE_DropDate) DropDate, HSN_Name, PGN_Name, INL_Name
			from Activity.DatabaseDropEvents
				inner join Activity.HostNames on HSN_ID = DDE_HSN_ID
				left join Activity.ProgramNames on PGN_ID = DDE_PGN_ID
				inner join Inventory.InstanceLogins on INL_ID = DDE_INL_ID
				inner join Inventory.MonitoredObjects on MOB_ID = DDE_MOB_ID
			where DDE_DropDate between dateadd(hour, -@DroppedHoursAgo - @HoursBackToCheck, sysdatetime())
					and dateadd(hour, -@DroppedHoursAgo, sysdatetime())
				and not exists (select *
									from Inventory.InstanceDatabases
									where IDB_MOB_ID = DDE_MOB_ID
										and IDB_Name = DDE_DatabaseName)
				AND MOB_OOS_ID in (0,1)
			group by MOB_ID, MOB_Name, DDE_DatabaseName, HSN_Name, PGN_Name, INL_Name
		)
select MOB_ID, DatabaseName InstanceName,
	'Database ' + quotename(DatabaseName) + ' was dropped at ' + convert(char(16), DropDate, 121) + ' by login ' + quotename(INL_Name) + ' from machine ' + quotename(HSN_Name) AlertMessage,
	(select @EventDescription [@EventDescription], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name], DatabaseName [@DatabaseName],
			DropDate [@DropDate], HSN_Name [@HostName], INL_Name [@LoginName], PGN_Name [@ProgramName]
		for xml path('Alert'), root('Alerts'), type) AlertEventData
from DroppedDatabases
GO
