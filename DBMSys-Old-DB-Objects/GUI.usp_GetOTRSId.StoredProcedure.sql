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
/****** Object:  StoredProcedure [GUI].[usp_GetOTRSId]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetOTRSId]
--declare 
 @t GUI.TT_TrappedEventToOTRSTicketMapping readonly
 ,@Closed bit = 0
as


if @Closed = 0
begin
 if exists ( select 
      1 
    from @t t
    left join EventProcessing.OTRSTicketStates es on t.OTS_NAME = es.OTS_NAME
    where es.OTS_ID is null)
 begin
  insert into EventProcessing.OTRSTicketStates(OTS_Name)
  select 
    distinct t.OTS_NAME
  from @t t
  left join EventProcessing.OTRSTicketStates es on t.OTS_NAME = es.OTS_NAME
  where es.OTS_ID is null
 end

  update EventProcessing.TrappedEventToOTRSTicketMapping
  set  TEO_OTRSTicketID = t.TEO_OTRSTicketID
    ,TEO_OTS_ID = es.OTS_ID
  from @t t join EventProcessing.OTRSTicketStates es on t.OTS_NAME = es.OTS_NAME 
  where EventProcessing.TrappedEventToOTRSTicketMapping.TEO_TRE_ID = t.TEO_TRE_ID

end
else
 update EventProcessing.TrappedEventToOTRSTicketMapping
  set  TEO_OTS_ID = es.OTS_ID
    ,TEO_WasConfirmationSent = 1
    ,TEO_IsTicketHandled = 1
  from @t t join EventProcessing.OTRSTicketStates es on t.OTS_NAME = es.OTS_NAME 
  where EventProcessing.TrappedEventToOTRSTicketMapping.TEO_OTRSTicketID = t.TEO_OTRSTicketID
GO
