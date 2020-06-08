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
/****** Object:  StoredProcedure [GUI].[usp_Get_DashboardAlertsCount]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [GUI].[usp_Get_DashboardAlertsCount]
--declare 
	@LatestAlertDate datetime = null
with recompile
as
BEGIN
	set transaction isolation level read uncommitted;
	set nocount on;

	 declare @tableOut table
	 (
		ID varchar(100),
		[Type] char(1),
		Name nVarchar(100),
		Parent_ID varchar(100), 
		LowAlertsCount int default(0), 
		MediumAlertsCount int default(0),
		CriticalAlertsCount int default(0), 
		LatestAlertDate datetime default(getdate()), 
		MOB_ID int, 
		System_ID int, 
		[Host_ID] int 
		,PLT_NAME	nvarchar(100)
		,PLT_ID		int
		,OOS_ID		INT
		,OOS_NAME	NVARCHAR(100)
	 );

	insert into @tableOut(ID, type, Name, System_ID)
	select 'S' + cast(SYS_ID as varchar(50)) ID, 'S' [Type], SYS_Name Name, SYS_ID Group_ID
	from	Inventory.SYSTEMS (nolock)
	WHERE	EXISTS (
						SELECT 
								* 
						FROM	Inventory.SystemHosts 
						JOIN	Inventory.MonitoredObjects ON MOB_ID = SHS_MOB_ID 
						JOIN	Management.ObjectOperationalStatuses ON MOB_OOS_ID = OOS_ID 
						WHERE	SYS_ID = SHS_SYS_ID 
								AND OOS_IsOperational = 1
					) ;


	--select * from Inventory.Systems


	insert into @tableOut(ID, type, Name, Parent_ID, MOB_ID, [Host_ID],PLT_NAME,PLT_ID,OOS_ID,OOS_NAME)
	select 'H' + cast(SHS_MOB_ID as varchar(50)) ID, 'H' [Type], /*MOB_Name*/SHS_ShortName Name, 'S' + cast(SHS_Sys_Id as varchar(50)) Parent_ID, MOB_ID, h.SHS_MOB_ID [Host_ID],PLT_NAME,PLT_ID,OOS_ID,OOS_Name
	from Inventory.SystemHosts h-- on s.Sys_ID = h.SHS_Sys_Id 
	join Inventory.MonitoredObjects (nolock) on MOB_ID = SHS_MOB_ID
	join [Management].[PlatformTypes] plt on MOB_PLT_ID = PLT.PLT_ID
	join Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID
	where OOS_IsOperational = 1 --OR OOS_ID = 6
	;
 

	 --select * from @tableOut
 
	update @tableOut set 
		LowAlertsCount = t1.LowAlertsCount, 
		MediumAlertsCount = t1.MediumAlertsCount, 
		CriticalAlertsCount = t1.CriticalAlertsCount
	from @tableOut
	join 
	(
		select TRE_MOB_ID,
			isnull(sum(iif(ESV_Name = 'Low', 1, 0)), 0) LowAlertsCount, 
			isnull(sum(iif(ESV_Name = 'Medium', 1, 0)), 0) MediumAlertsCount, 
			isnull(sum(iif(ESV_Name = 'High', 1, 0)), 0) CriticalAlertsCount
		from EventProcessing.TrappedEvents (nolock) 
		join EventProcessing.MonitoredEvents (nolock) on MOV_ID = TRE_MOV_ID
		join EventProcessing.EventSeverities (nolock) on ESV_ID = MOV_ESV_ID
		where TRE_IsClosed = 0
		group by TRE_MOB_ID
	) t1 on TRE_MOB_ID = MOB_ID;

	update t0 set 
		LowAlertsCount = t0.LowAlertsCount + isnull(t1.LowAlertsCount, 0), 
		MediumAlertsCount = t0.MediumAlertsCount + isnull(t1.MediumAlertsCount, 0), 
		CriticalAlertsCount = t0.CriticalAlertsCount + isnull(t1.CriticalAlertsCount, 0)
	from @tableOut t0
	join 
	(
		select Parent_ID, 
			sum(LowAlertsCount) LowAlertsCount, 
			sum(MediumAlertsCount) MediumAlertsCount, 
			sum(CriticalAlertsCount) CriticalAlertsCount
		from @tableOut
		where type = 'I' 
		group by Parent_ID
	) t1 on t1.Parent_ID = t0.ID;

	update t0 set 
		LowAlertsCount = t0.LowAlertsCount + isnull(t1.LowAlertsCount, 0), 
		MediumAlertsCount = t0.MediumAlertsCount + isnull(t1.MediumAlertsCount, 0), 
		CriticalAlertsCount = t0.CriticalAlertsCount + isnull(t1.CriticalAlertsCount, 0)
	from @tableOut t0
	join 
	(
		select Parent_ID, 
			sum( LowAlertsCount) LowAlertsCount, 
			sum(MediumAlertsCount) MediumAlertsCount, 
			sum(CriticalAlertsCount) CriticalAlertsCount
		from @tableOut
		where type = 'H'
		group by Parent_ID
	) t1 on t1.Parent_ID = t0.ID;

	update t 
			set OOS_ID = 2 
	from	@tableOut t 
	WHERE	[Type] = 'S' 
			AND EXISTS (select * from @tableOut tt1 where tt1.Parent_ID = t.ID and tt1.OOS_ID = 2)
			AND NOT EXISTS (select * from @tableOut tt2 where tt2.Parent_ID = t.ID and tt2.OOS_ID <> 2)


	select ID, [Type], Name, Parent_ID, LowAlertsCount, MediumAlertsCount, CriticalAlertsCount, LatestAlertDate, System_ID, /*MOB_ID*/ [Host_ID],PLT_NAME,PLT_ID,OOS_ID,OOS_Name
	from @tableOut;


	declare 
			@IsConfigure	BIT = 0
			,@IsNotRunTests	BIT = 1

	
	SELECT 
			@IsConfigure = 1 
	FROM	@tableOut a
	join	Management.ObjectOperationalStatuses s on a.OOS_ID = s.OOS_ID
	WHERE	OOS_IsOperational = 1		----------------------------------------

	if @IsConfigure = 1
	BEGIN
		select 
				@IsNotRunTests = 0
		from	(select distinct MOB_ID from @tableOut where MOB_ID is not null)t
		JOIN	EventProcessing.TrappedEvents ON MOB_ID = TRE_MOB_ID

		IF @IsNotRunTests = 1
		SELECT 	
				@IsNotRunTests = 0
		FROM	(select distinct MOB_ID from @tableOut where MOB_ID is not null)t
		JOIN	Collect.TestRunHistory ON MOB_ID = TRH_MOB_ID
	--WHERE	--NOT EXISTS (SELECT * FROM  with(nolock) WHERE MOB_ID = TRH_MOB_ID and TRH_MOB_ID IS NOT NULL)
	
	END		


	SELECT 
			@IsConfigure	as IsConfigure
			,@IsNotRunTests	as IsNotRunTests

END
GO
