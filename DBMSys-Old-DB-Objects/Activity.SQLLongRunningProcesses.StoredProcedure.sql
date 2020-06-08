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
/****** Object:  StoredProcedure [Activity].[SQLLongRunningProcesses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Activity].[SQLLongRunningProcesses] 
--DECLARE
	@EventDescription nvarchar(1000)
as
set nocount on

select 
		CRP_MOB_ID F_MOB_ID
		,MOB_Name + '\' + IDB_Name F_InstanceName
		,'Process with session ID = ' + CAST(CRP_SessionID AS NVARCHAR(50)) + ' has been working long enough. '
		+ ISNULL(CHAR(10) + 'HostName: ' +		HSN_Name,'')	
		+ ISNULL(CHAR(10) + 'ProgramName: ' +	PGN_Name,'')	
		+ ISNULL(CHAR(10) + 'DatabaseName: ' +	IDB_Name,'')	
		+ ISNULL(CHAR(10) + 'LoginName	: ' +	LGN_Name,'')	
		+ ISNULL(CHAR(10) + 'ObjectName: ' +	OBN_Name,'')
		+ CHAR(10) + 'Duration :' + case when DATEDIFF (day, CRP_StartDate, CRP_Last_SeenDate)>1 then cast(DATEDIFF (day, CRP_StartDate, CRP_Last_SeenDate) as nvarchar(30))+' (days) ' else '' end 
						+ CONVERT(NVARCHAR(20),CRP_Last_SeenDate-CRP_StartDate,108)  
		+ CHAR(10) + 'Running SQL statement: "' + SQS_Statement + '"' AlertMessage
		,(
			select 
					@EventDescription [@EventDescription]
					,HSN_Name [@HostName]
					,PGN_Name[@ProgramName]
					,IDB_Name[@DatabaseName] 
					,LGN_Name[@LoginName]
					,OBN_Name[@ObjectName]
					,case when DATEDIFF (day, CRP_StartDate, CRP_Last_SeenDate)>1 then cast(DATEDIFF (day, CRP_StartDate, CRP_Last_SeenDate) as nvarchar(30))+' (days) ' else '' end 
						+ CONVERT(NVARCHAR(20),CRP_Last_SeenDate-CRP_StartDate,108) [@Duration] 
					, CAST(CRP_ID AS NVARCHAR(10)) [@CRP_ID]
			for xml path('Alert'), root('Alerts'), type
		) AlertEventData
from	Activity.CurrentLongRunningProcesses
		inner join Inventory.MonitoredObjects on CRP_MOB_ID = MOB_ID
		LEFT join Inventory.InstanceDatabases ON CRP_IDB_ID = IDB_ID
		LEFT JOIN Activity.SQLStatements ON CRP_SQS_ID = SQS_ID
		LEFT join Activity.LoginNames on CRP_LGN_ID = LGN_ID
		LEFT join Activity.ProgramNames on CRP_PGN_ID = PGN_ID
		LEFT join Activity.ObjectNames on CRP_OBN_ID = OBN_ID
		LEFT join Activity.HostNames on CRP_HSN_ID = HSN_ID
where MOB_OOS_ID = 1 AND CRP_IsFinished = 0
GO
