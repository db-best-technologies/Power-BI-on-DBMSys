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
/****** Object:  View [Tests].[VW_TST_LogShippingErrors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_LogShippingErrors]
as
select top 0 CAST(null as datetime) log_time_utc,
			CAST(null as nvarchar(128)) database_name,
			CAST(null as tinyint) session_status,
			CAST(null as tinyint) agent_type,
			CAST(null as datetime) FirstOccurence,
			CAST(null as datetime) LastOccurence,
			CAST(null as int) NumberOfOccurences,
			CAST(null as nvarchar(max)) ErrorMessage,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LogShippingErrors]    Script Date: 6/8/2020 1:16:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LogShippingErrors] on [Tests].[VW_TST_LogShippingErrors]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@TST_ID int,
		@StartDate datetime2(3),
		@LastValue varchar(100)

select top 1 @MOB_ID = TRH_MOB_ID,
			@TST_ID = TRH_TST_ID,
			@StartDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, database_name, Metadata_TRH_ID
			from inserted
			where database_name is not null) s
		on IDB_MOB_ID = @MOB_ID
		and database_name = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, database_name, sysdatetime(), sysdatetime(), Metadata_TRH_ID);

merge Activity.LogShippingErrors d
	using (select IDB_ID, session_status, agent_type, FirstOccurence, LastOccurence, NumberOfOccurences, ErrorMessage, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				left join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and IDB_Name = database_name
			where ErrorMessage is not null) s
		on LSE_MOB_ID = @MOB_ID
			and LSE_LSA_ID = agent_type
			and LSE_ErrorMessageHashed = hashbytes('MD5', cast(ErrorMessage as varchar(8000)))
			and LSE_LastOccurenceDate <= LastOccurence
			and LSE_InsertDate > DATEADD(day, -1, sysdatetime())
			and ISNULL(LSE_IDB_ID,0) = ISNULL(IDB_ID, 0)
	when matched then update set
						LSE_LastOccurenceDate = LastOccurence,
						LSE_NumberOfOccurences += NumberOfOccurences,
						LSE_ErrorMessage = ErrorMessage,
						LSE_LastSeenDate = @StartDate,
						LSE_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(LSE_ClientID, LSE_MOB_ID, LSE_IDB_ID, LSE_LSS_ID, LSE_LSA_ID, LSE_FirstOccurenceDate, LSE_LastOccurenceDate, LSE_NumberOfOccurences,
									LSE_ErrorMessage, LSE_InsertDate, LSE_LastSeenDate, LSE_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, session_status, agent_type, FirstOccurence, LastOccurence, NumberOfOccurences, ErrorMessage,
									@StartDate, @StartDate, Metadata_TRH_ID);

select @LastValue = '''' + convert(char(23), MAX(log_time_utc), 121) + ''''
from inserted
where ErrorMessage is null

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
