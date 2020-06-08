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
/****** Object:  StoredProcedure [GUI].[usp_Get_DashboardSystemAlerts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [GUI].[usp_Get_DashboardSystemAlerts]
--declare 
	@System_Id int = null
	,@ESV_String	NVARCHAR(50)
as
set transaction isolation level read uncommitted
set nocount on

if @System_Id is null 
	
	select
		grp.Sys_ID,
		grp.Sys_Name,
		TRE_OpenDate [Time],
		MOV_ID EventId,
		MOV_Description EventName,
		PLT_ID as PlatformID,
		PLT_Name PlatformName,
		SHS_MOB_ID SourceID,
		/*MOB_Name*/SHS_ShortName SourceName,
		TRE_EventInstanceName Injured,
		ESV_Name [Level],
		TRE_AlertMessage [Message],
		cast(0 as bit) IsClosed
		,OTS_NAME
		,TEO_OTRSTicketID
		,OOS_ID
		,OOS_Name
	from EventProcessing.TrappedEvents (nolock)
	cross apply
	(
		select
				hst.SHS_MOB_ID
				,hst.SHS_ID
				,s.Sys_ID
				,s.Sys_Name
				,SHS_ShortName
		from	Inventory.Systems s
		join	Inventory.SystemHosts hst on s.Sys_ID = hst.SHS_Sys_Id
		where	hst.SHS_MOB_ID = TRE_MOB_ID
	) grp
	join Inventory.MonitoredObjects (nolock) on MOB_ID = SHS_MOB_ID
	join Management.PlatformTypes (nolock) on PLT_ID = MOB_PLT_ID
	join EventProcessing.MonitoredEvents (nolock) on MOV_ID = TRE_MOV_ID
	join EventProcessing.EventSeverities (nolock) on ESV_ID = MOV_ESV_ID
	left join EventProcessing.TrappedEventToOTRSTicketMapping otrs on TRE_ID = otrs.TEO_TRE_ID
	left join EventProcessing.OTRSTicketStates ots on otrs.TEO_OTS_ID = ots.OTS_ID
	join Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID
	JOIN (select * from Infra.fn_SplitString(@ESV_String,','))s on s.Val = ESV_ID
	where	TRE_IsClosed = 0
			and OOS_IsOperational = 1 --MOB_OOS_ID in (0,1,2,)
	order by TRE_OpenDate desc;

else

	select
		TRE_OpenDate [Time],
		MOV_ID EventId,
		MOV_Description EventName,
		PLT_ID as PlatformID,
		PLT_Name PlatformName,
		SHS_MOB_ID SourceID,
		/*MOB_Name*/SHS_ShortName SourceName,
		TRE_EventInstanceName Injured,
		ESV_Name [Level],
		TRE_AlertMessage [Message],
		cast(0 as bit) IsClosed
		,OTS_NAME
		,TEO_OTRSTicketID
		,OOS_ID
		,OOS_Name
	from EventProcessing.TrappedEvents (nolock)
	cross apply
	(
		select
				hst.SHS_MOB_ID
				,hst.SHS_ID
				,SHS_ShortName
		from	Inventory.Systems s
		join	Inventory.SystemHosts hst on s.Sys_ID = hst.SHS_Sys_Id
		where	s.Sys_ID = @System_Id
				and hst.SHS_MOB_ID = TRE_MOB_ID
	) grp
	join Inventory.MonitoredObjects (nolock) on MOB_ID = SHS_MOB_ID
	join Management.PlatformTypes (nolock) on PLT_ID = MOB_PLT_ID
	join EventProcessing.MonitoredEvents (nolock) on MOV_ID = TRE_MOV_ID
	join EventProcessing.EventSeverities (nolock) on ESV_ID = MOV_ESV_ID
	left join EventProcessing.TrappedEventToOTRSTicketMapping otrs on TRE_ID = otrs.TEO_TRE_ID
	left join EventProcessing.OTRSTicketStates ots on otrs.TEO_OTS_ID = ots.OTS_ID
	join Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID
	JOIN (select * from Infra.fn_SplitString(@ESV_String,','))s on s.Val = ESV_ID
	where	TRE_IsClosed = 0
			and OOS_IsOperational = 1 --MOB_OOS_ID in (0,1,2,)
	order by TRE_OpenDate desc;
GO
