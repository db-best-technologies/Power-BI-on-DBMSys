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
/****** Object:  StoredProcedure [GUI].[usp_GetEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUI].[usp_GetEvents]
	@FromTimeStamp binary(8) = null
as
set nocount on
set transaction isolation level read uncommitted

select TRE_Timestamp RecordTimestamp, TRE_ID OpenEventID, MOV_ID EventTypeID, TRE_OpenDate EventOpenDate, TRE_MOB_ID MonitoredObjectID,
	TRE_AlertMessage AlertMessage, TRE_AlertEventData AlertEventData, TRE_IsClosed IsEventClosed
from EventProcessing.MonitoredEvents
	inner join EventProcessing.TrappedEvents on TRE_MOV_ID = MOV_ID
where MOV_IsInternal = 0
	and (TRE_Timestamp > @FromTimeStamp
			or (@FromTimeStamp is null
					and TRE_IsClosed = 0)
		)
GO
