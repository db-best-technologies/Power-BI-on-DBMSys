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
/****** Object:  View [Tests].[VW_TST_SQLErrorLog]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLErrorLog]
as
select top 0 cast(null as datetime) FirstErrorDate,
			cast(null as datetime) LastErrorDate,
			cast(null as int) ErrorCount,
			cast(null as varchar(1000)) ProcessInfo,
			cast(null as nvarchar(max)) ErrorMessage,
			cast(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLErrorLog]    Script Date: 6/8/2020 1:16:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLErrorLog] on [Tests].[VW_TST_SQLErrorLog]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@TST_ID int,
		@LastValue varchar(100)

declare @FailedLogins table(FirstDate datetime,
							LastDate datetime,
							FailureCount int,
							LoginName nvarchar(128),
							LocationName nvarchar(128),
							IsUnknownLogin bit,
							Metadata_TRH_ID int,
							Metadata_ClientID int)

select top 1 @TST_ID = TRH_TST_ID,
			@MOB_ID = TRH_MOB_ID
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

insert into Activity.SQLErrorLog(SEL_ClientID, SEL_MOB_ID, SEL_FirstErrorDate, SEL_LastErrorDate, SEL_ErrorCount, SEL_ProcessInfo, SEL_ErrorMessage)
select Metadata_ClientID, @MOB_ID, FirstErrorDate, LastErrorDate, ErrorCount, ProcessInfo, ErrorMessage
from inserted
where ErrorMessage is not null

;with FailedLogins as
	(select FirstErrorDate, LastErrorDate, ErrorCount, ErrorMessage, Metadata_TRH_ID, Metadata_ClientID,
			CHARINDEX('for user ''', ErrorMessage, 1) + 10 LoginNameStart,
			CHARINDEX('[CLIENT: ', ErrorMessage, 1) + 9 LocationNameStart
		from inserted
		where ErrorMessage like '%Login failed for user%'
			and (ErrorMessage like '%Could not find a login matching the name provided%'
					or ErrorMessage like '%Password did not match that for the login provided%')
	)
insert into @FailedLogins(FirstDate, LastDate, FailureCount, LoginName, LocationName, IsUnknownLogin, Metadata_TRH_ID, Metadata_ClientID)
select FirstErrorDate, LastErrorDate, ErrorCount,
	substring(ErrorMessage, LoginNameStart, CHARINDEX('''.', ErrorMessage, LoginNameStart) - LoginNameStart) LoginName,
	substring(ErrorMessage, LocationNameStart, CHARINDEX(']', ErrorMessage, LocationNameStart) - LocationNameStart) LocationName,
	case when ErrorMessage like '%Password did not match that for the login provided%'
			then 0
			else 1
		end IsUnknownLogin, Metadata_TRH_ID, Metadata_ClientID
from FailedLogins

if @@ROWCOUNT > 0
begin
	insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, [DateTime], Metadata_TRH_ID, Metadata_ClientID)
	select 'Security', 'Failed Login',
			case when IsUnknownLogin = 1
				then LoginName
				else 'Non-existing'
			end Instance,
			FailureCount Value, LastDate [DateTime], Metadata_TRH_ID, Metadata_ClientID
	from @FailedLogins

	merge Activity.LoginNames d
		using (select distinct LoginName
				from @FailedLogins) s
			on LoginName = LGN_Name
		when not matched then insert(LGN_Name)
							values(LoginName);

	merge Activity.HostNames d
		using (select distinct LocationName
				from @FailedLogins) s
			on LocationName = HSN_Name
		when not matched then insert(HSN_Name)
							values(LocationName);

	insert into Activity.FailedLogins(FLG_ClientID, FLG_MOB_ID, FLG_FirstDate, FLG_LastDate, FLG_Count, FLG_LGN_ID, FLG_HSN_ID, FLG_IsUnknownLogin)
	select Metadata_ClientID, @MOB_ID, FirstDate, LastDate, FailureCount, LGN_ID, HSN_ID, IsUnknownLogin
	from @FailedLogins
		inner join Activity.LoginNames on LGN_Name = LoginName
		inner join Activity.HostNames on HSN_Name = LocationName
end

select @LastValue = '''' + replace(convert(char(19), dateadd(second, 1, LastErrorDate), 121), '-', '') + ''''
from inserted
where ErrorMessage is null

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
