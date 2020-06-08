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
/****** Object:  StoredProcedure [GUI].[usp_Get_DashboardHostAlerts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [GUI].[usp_Get_DashboardHostAlerts]
--declare
		@host_Id	int 
		,@ESV_String	NVARCHAR(50)
as
set transaction isolation level read uncommitted
set nocount on

;with Sever AS 
(
	select * from Infra.fn_SplitString(@ESV_String,',')
)
select
	TRE_OpenDate [Time],
	MOV_ID EventId,
	MOV_Description EventName,
	PLT_Name PlatformName,
	SHS_MOB_ID SourceID,
	/*MOB_name*/SHS_ShortName SourceName,
	TRE_EventInstanceName Injured,
	ESV_Name [Level],
	TRE_AlertMessage [Message],
	cast(0 as bit) IsClosed
	,OTS_NAME
	,TEO_OTRSTicketID
from Inventory.MonitoredObjects (nolock)
join Management.PlatformTypes (nolock) on MOB_PLT_ID = PLT_ID
join Inventory.SystemHosts (nolock) on MOB_ID = SHS_MOB_ID
join EventProcessing.TrappedEvents (nolock) on TRE_MOB_ID = MOB_ID
join EventProcessing.MonitoredEvents (nolock) on MOV_ID = TRE_MOV_ID
join EventProcessing.EventSeverities (nolock) on MOV_ESV_ID = ESV_ID
left join EventProcessing.TrappedEventToOTRSTicketMapping otrs on TRE_ID = otrs.TEO_TRE_ID
left join EventProcessing.OTRSTicketStates ots on otrs.TEO_OTS_ID = ots.OTS_ID
join	Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID
JOIN	Sever on Val = ESV_ID
where SHS_MOB_ID = @host_Id
	  and TRE_IsClosed = 0 
	  and (OOS_IsOperational = 1 or MOB_OOS_ID = 6)
order by TRE_OpenDate desc
GO
