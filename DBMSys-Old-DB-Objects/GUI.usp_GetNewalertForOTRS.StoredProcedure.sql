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
/****** Object:  StoredProcedure [GUI].[usp_GetNewalertForOTRS]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetNewalertForOTRS]

as

declare @TRE table
(
	TREID		int
	,MOBID		int
	,TREDATE	datetime2
	,ALERTMess	nvarchar(max)
	,ALERTData	xml
	,TRESTATE	nvarchar(255)
)

insert into @TRE(TREID,MOBID,TREDATE,ALERTMess,ALERTData,TRESTATE)
select 
		TRE_ID
		,TRE_MOB_ID
		,TRE_OpenDate
		,TRE_AlertMessage
		,TRE_AlertEventData
		,N'NEW'
from	EventProcessing.TrappedEvents
where	TRE_ID not in 
		((select TEO_TRE_ID from EventProcessing.TrappedEventToOTRSTicketMapping where TEO_TRE_ID is not null))
		--and TRE_OpenDate>='20160501'
		and TRE_IsClosed = 0


MERGE EventProcessing.TrappedEventToOTRSTicketMapping as e
USING (select * from @TRE) as o
ON e.TEO_TRE_ID = o.TREID
WHEN NOT MATCHED THEN
	INSERT(TEO_TRE_ID,TEO_OTS_ID,TEO_IsTicketHandled,TEO_WasConfirmationSent)
	VALUES (o.TREID,1,0,0);

insert into @TRE(TREID,MOBID,TREDATE,ALERTMess,ALERTData,TRESTATE)
select 
		 tm.TEO_TRE_ID
		,te.TRE_MOB_ID
		,te.TRE_OpenDate
		,te.TRE_AlertMessage
		,te.TRE_AlertEventData
		,'Failed' AS OTS_Name
from	EventProcessing.TrappedEventToOTRSTicketMapping tm
join	EventProcessing.OTRSTicketStates es on tm.TEO_OTS_ID = es.OTS_ID
join	EventProcessing.TrappedEvents te on tm.TEO_TRE_ID = te.TRE_ID
where	es.OTS_Name = 'Failed'
		OR (tm.TEO_CreatedDate < DATEADD(hh,-2,GETDATE()) AND TEO_OTRSTicketID IS NULL)

UPDATE	EventProcessing.TrappedEventToOTRSTicketMapping SET TEO_CreatedDate = GETDATE() WHERE TEO_CreatedDate < DATEADD(hh,-2,GETDATE()) AND TEO_OTRSTicketID IS NULL

select * from @TRE
GO
