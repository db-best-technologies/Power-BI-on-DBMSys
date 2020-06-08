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
/****** Object:  StoredProcedure [GUI].[usp_GetEventTypes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUI].[usp_GetEventTypes]
as
set nocount on
set transaction isolation level read uncommitted

select MOV_ID EventTypeID, MOV_Description EventType,
	stuff((select ',' + CAT_Name
		from EventProcessing.MonitoredEvents_Categories
			inner join BusinessLogic.Categories on MCT_CAT_ID = CAT_ID
		where MCT_MOV_ID = MOV_ID
		order by CAT_Name
		for xml path('')), 1, 1, '') Categories,
		MOV_Weight EventTypeWeight, isnull(MOV_THL_ID, 10) EventLevel
from EventProcessing.MonitoredEvents
where MOV_IsActive = 1
	and MOV_IsInternal = 0
GO
