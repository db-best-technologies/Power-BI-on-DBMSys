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
/****** Object:  View [Tests].[VW_TST_OperatingSystemEventLog]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_OperatingSystemEventLog]
as
select top 0 CAST(null as varchar(900)) CategoryString,
			CAST(null as int) EventCode,
			CAST(null as bigint) EventIdentifier,
			CAST(null as varchar(900)) LogFile,
			CAST(null as nvarchar(max)) [Message],
			CAST(null as varchar(900)) SourceName,
			CAST(null as datetime) TimeGenerated,
			CAST(null as datetime) TimeWritten,
			CAST(null as varchar(900)) [Type],
			CAST(null as varchar(900)) [User],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_OperatingSystemEventLog]    Script Date: 6/8/2020 1:16:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_OperatingSystemEventLog] on [Tests].[VW_TST_OperatingSystemEventLog]
	instead of insert
as
set nocount on
declare @LastValue nvarchar(100),
		@MOB_ID int,
		@TST_ID int

select top 1 @MOB_ID = TRH_MOB_ID,
			@TST_ID = TRH_TST_ID,
			@LastValue = replace(convert(char(23), TRH_StartDate, 121), '-', '')
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Activity.EventLogCategories d
	using (select distinct CategoryString
			from inserted
			where CategoryString is not null) s
		on CategoryString = ELC_Name
	when not matched then insert(ELC_Name)
						values(CategoryString);

merge Activity.EventLogEventTypes d
	using (select distinct [Type]
			from inserted
			where [Type] is not null) s
		on [Type] = EET_Name
	when not matched then insert(EET_Name)
						values([Type]);

merge Activity.EventLogLogFileTypes d
	using (select distinct LogFile
			from inserted
			where LogFile is not null) s
		on LogFile = ELF_Name
	when not matched then insert(ELF_Name)
						values(LogFile);

merge Activity.EventLogSourceNames d
	using (select distinct SourceName
			from inserted
			where SourceName is not null) s
		on SourceName = ESN_Name
	when not matched then insert(ESN_Name)
						values(SourceName);

merge Activity.EventLogUserNames d
	using (select distinct [User]
			from inserted
			where [User] is not null) s
		on [User] = EUN_Name
	when not matched then insert(EUN_Name)
						values([User]);

merge Activity.OperatingSystemEventLogEvents d
	using (select distinct Metadata_ClientID, ELC_ID, ELF_ID, EventCode, EventIdentifier, [Message], ESN_ID, TimeGenerated, TimeWritten,
				EET_ID, EUN_ID
			from inserted
				left join Activity.EventLogCategories on ELC_Name = CategoryString
				inner join Activity.EventLogEventTypes on EET_Name = [Type]
				inner join Activity.EventLogLogFileTypes on ELF_Name = LogFile
				inner join Activity.EventLogSourceNames on ESN_Name = SourceName
				left join Activity.EventLogUserNames on EUN_Name = [User]) s
		on EVL_MOB_ID = @MOB_ID
			and EVL_ELF_ID = ELF_ID
			and EVL_EventCode = EventCode
			and EVL_EventIdentifier = EventIdentifier
			and EVL_TimeWritten = TimeWritten
	when not matched then insert (EVL_ClientID, EVL_MOB_ID, EVL_ELC_ID, EVL_ELF_ID, EVL_EventCode, EVL_EventIdentifier,
									EVL_Message, EVL_ESN_ID, EVL_TimeGenerated, EVL_TimeWritten, EVL_EET_ID, EVL_EUN_ID)
							values(Metadata_ClientID, @MOB_ID, ELC_ID, ELF_ID, EventCode, EventIdentifier, [Message], ESN_ID, TimeGenerated,
									TimeWritten, EET_ID, EUN_ID);

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
