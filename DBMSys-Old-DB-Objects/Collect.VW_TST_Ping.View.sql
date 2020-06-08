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
/****** Object:  View [Collect].[VW_TST_Ping]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Collect].[VW_TST_Ping]
as
select CAST(null as nvarchar(128)) Category,
	CAST(null as nvarchar(128)) [Counter],
	CAST(null as decimal(18, 5)) Value,
	CAST(null as varchar(100)) [Status],
	CAST(null as int) Metadata_TRH_ID,
	CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Collect].[trg_VW_TST_Ping]    Script Date: 6/8/2020 1:15:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Collect].[trg_VW_TST_Ping] on [Collect].[VW_TST_Ping]
	instead of insert
as
set nocount on
declare @Status varchar(100)
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select Category, [Counter], Value, [Status], Metadata_TRH_ID, Metadata_ClientID
from inserted

select top 1 @Status = [Status]
from inserted

if @Status <> 'Success'
	raiserror('Ping failed with a "%s" error.', 16, 1, @Status)
GO
