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
/****** Object:  StoredProcedure [GUI].[usp_GetClosedEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetClosedEvents]

as

declare @t table
(
	id		bigint
	,nm		nvarchar(255)
)

insert into @t(id,nm)
select 
		eo.TEO_OTRSTicketID as EOT_OTR_ID
		,st.OTS_Name as EST_NAME
from	[EventProcessing].[TrappedEventToOTRSTicketMapping] eo
join	EventProcessing.TrappedEvents tr on eo.TEO_TRE_ID = tr.TRE_ID
join	EventProcessing.OTRSTicketStates st on eo.TEO_OTS_ID = st.OTS_ID
where	tr.TRE_IsClosed = 1
		and eo.TEO_WasConfirmationSent = 0
		and eo.TEO_OTRSTicketID is not null
		

select * from @t
GO
