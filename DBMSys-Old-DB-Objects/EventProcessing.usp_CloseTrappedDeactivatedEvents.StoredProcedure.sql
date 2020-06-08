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
/****** Object:  StoredProcedure [EventProcessing].[usp_CloseTrappedDeactivatedEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [EventProcessing].[usp_CloseTrappedDeactivatedEvents]
as
set nocount on
delete EventProcessing.EventDefinitionStatuses
where not exists (select *
					from EventProcessing.EventDefinitions
						inner join EventProcessing.MonitoredEvents on EDF_MOV_ID = MOV_ID
					where EDF_ID = EDS_EDF_ID
						and MOV_IsActive = 1)

update EventProcessing.TrappedEvents
set TRE_IsClosed = 1,
	TRE_CloseDate = SYSDATETIME(),
	TRE_TEC_ID = 6
where TRE_IsClosed = 0
	and not exists (select *
					from EventProcessing.MonitoredEvents
					where MOV_ID = TRE_MOV_ID
						and MOV_IsActive = 1)
GO
