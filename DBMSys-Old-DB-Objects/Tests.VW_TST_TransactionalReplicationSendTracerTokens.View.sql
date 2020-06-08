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
/****** Object:  View [Tests].[VW_TST_TransactionalReplicationSendTracerTokens]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_TransactionalReplicationSendTracerTokens]
as
select top 0 CAST(null as int) PubID,
			CAST(null as int) TokenID,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_TransactionalReplicationSendTracerTokens]    Script Date: 6/8/2020 1:16:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_TransactionalReplicationSendTracerTokens] on [Tests].[VW_TST_TransactionalReplicationSendTracerTokens]
	instead of insert
as
set nocount on

insert into Activity.TracerTokens(TCT_ClientID, TCT_MOB_ID, TCT_TRP_ID,  TCT_TokenID, TCT_DateSent, TCT_IsClosed)
select Metadata_ClientID, TRP_Distributor_MOB_ID, TRP_ID, TokenID, GETDATE(), 0
from inserted
	inner join Inventory.TransactionalReplicationPublications on PubID = TRP_ID
GO
