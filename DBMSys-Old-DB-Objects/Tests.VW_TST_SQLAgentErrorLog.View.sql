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
/****** Object:  View [Tests].[VW_TST_SQLAgentErrorLog]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLAgentErrorLog]
as
select top 0 cast(null as datetime) FirstErrorDate,
			cast(null as datetime) LastErrorDate,
			cast(null as int) ErrorCount,
			cast(null as int) ErrorLevel,
			cast(null as nvarchar(max)) ErrorMessage,
			cast(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAgentErrorLog]    Script Date: 6/8/2020 1:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLAgentErrorLog] on [Tests].[VW_TST_SQLAgentErrorLog]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@TST_ID int,
		@LastValue varchar(100)

select top 1 @TST_ID = TRH_TST_ID,
			@MOB_ID = TRH_MOB_ID
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

insert into Activity.SQLAgentErrorLog(SAL_ClientID, SAL_MOB_ID, SAL_FirstErrorDate, SAL_LastErrorDate, SAL_ErrorCount, SAL_ErrorLevel, SAL_ErrorMessage)
select Metadata_ClientID, @MOB_ID, FirstErrorDate, LastErrorDate, ErrorCount, ErrorLevel, ErrorMessage
from inserted
where ErrorMessage is not null

select @LastValue = '''' + replace(convert(char(19), dateadd(second, 1, LastErrorDate), 121), '-', '') + ''''
from inserted
where ErrorMessage is null

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
