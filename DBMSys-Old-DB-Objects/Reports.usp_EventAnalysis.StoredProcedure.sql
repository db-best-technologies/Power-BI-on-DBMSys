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
/****** Object:  StoredProcedure [Reports].[usp_EventAnalysis]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_EventAnalysis]
	@StartDate datetime2(3) = null,
	@EndDate datetime2(3) = null
as
if @StartDate is null
	set @StartDate = DATEADD(month, -1, sysdatetime())
if @EndDate is null
	set @EndDate = SYSDATETIME()

select MOV_ID [Event Type ID], MOV_Description [Event Type], isnull(MOV_Weight, 0.5) [Weight], COUNT(*) [Total Events],
	COUNT(distinct TRE_MOB_ID) [Unique Monitored Objects],
	COUNT(distinct CAST(TRE_MOB_ID as varchar(100)) + TRE_EventInstanceName) [Unique Instances],
	CAST(COUNT(*)*1./(DATEDIFF(DAY, FirstDate, @EndDate) + 1) as decimal(10, 2)) [Events Per Day]
from EventProcessing.MonitoredEvents
	inner join EventProcessing.TrappedEvents on TRE_MOV_ID = MOV_ID
	cross apply (select min(TRE_OpenDate) FirstDate
					from EventProcessing.TrappedEvents
					where TRE_OpenDate between @StartDate and @EndDate) f
where MOV_IsActive = 1
	and MOV_IsInternal = 0
	and TRE_OpenDate between @StartDate and @EndDate
group by MOV_ID, MOV_Description, MOV_Weight, FirstDate
GO
