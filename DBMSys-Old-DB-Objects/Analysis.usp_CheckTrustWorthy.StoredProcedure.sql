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
/****** Object:  StoredProcedure [Analysis].[usp_CheckTrustWorthy]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Analysis].[usp_CheckTrustWorthy]
	@EventDescription nvarchar(1000)
as
select MOB_ID, DFO_Name + '\' + IDB_Name InstanceName,
	'The ' + IDB_Name + 'database on the ' + DFO_Name + ' SQL instance has the Trustworthy option set to ON.' AlertMessage,
	(select @EventDescription [@EventDescription], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name], IDB_Name [@DatabaseName]
		for xml path('Alert'), root('Alerts'), type) AlertEventData
from Inventory.MonitoredObjects
	inner join Inventory.InstanceDatabases on MOB_ID = IDB_MOB_ID
	inner join Management.DefinedObjects on DFO_PLT_ID = MOB_PLT_ID
											and MOB_Entity_ID = DFO_ID
	inner join Inventory.DatabaseInstanceDetails on DFO_ID = DID_DFO_ID
where IDB_IsTrustworthyOn = 1
	and IDB_Name <> 'msdb'
	and MOB_PLT_ID = 1
	and not (IDB_Name = db_name()
				and DID_Name = @@SERVERNAME)
	and MOB_OOS_ID = 1
GO
