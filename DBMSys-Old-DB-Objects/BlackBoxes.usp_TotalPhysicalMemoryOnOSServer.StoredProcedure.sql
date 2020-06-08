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
/****** Object:  StoredProcedure [BlackBoxes].[usp_TotalPhysicalMemoryOnOSServer]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BlackBoxes].[usp_TotalPhysicalMemoryOnOSServer]
	@Parameters xml,
	@BlackBox xml output
as
set nocount on

select @BlackBox =
	(select 'The total amount of Physical memory on ' + S_MOB_Name + ' is ' + CAST(OSS_TotalPhysicalMemoryMB as nvarchar(100)) + 'MB' Header,
			S_DateTime SnapshotDate
	from (select S_MOB_ID, S_MOB_Name, max(S_DateTime) S_DateTime, S_EventInstanceName
			from #SelectedMonitoredObjects
			where S_PLT_ID = 2
			group by S_MOB_ID, S_MOB_Name, S_EventInstanceName) Info
		inner join Inventory.MonitoredObjects on MOB_ID = S_MOB_ID
		inner join Inventory.OSServers on MOB_PLT_ID = 2
										and MOB_ID = OSS_MOB_ID
	for xml auto, elements, root('Blackbox')
	)
GO
