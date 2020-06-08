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
/****** Object:  View [Tests].[VW_TST_SolarisUpTime]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisUpTime]
as
select top 0 CAST(null as varchar(1000)) [Output],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisUpTime]    Script Date: 6/8/2020 1:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisUpTime] on [Tests].[VW_TST_SolarisUpTime]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

declare @MOB_ID int,
		@TST_ID int,
		@LastRestartDate datetime2(3),
		@ClientID int

select @MOB_ID = TRH_MOB_ID,
		@TST_ID = TRH_TST_ID,
		@ClientID = Metadata_ClientID
from inserted
	inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID

;with s1 as
		(select ltrim(substring(Output, charindex(' up ', Output, 1) + 3, 1000)) s
			from inserted)
	, s2 as
		(select left(s, charindex('users', s, 1) - 1) s
			from s1)
	, s3 as
		(select rtrim(ltrim(left(s, len(s) - charindex(',', reverse(s), 1) + 1))) s
			from s2)
	, s4 as
		(select sum(case when Val like '%day(s)'
							then cast(rtrim(replace(Val, 'day(s)', '')) as int)*1440
						when Val like '%:%'
							then cast(left(Val, charindex(':', Val, 1) - 1) as int)*60
									+ cast(substring(Val, charindex(':', Val, 1) + 1, 2) as int)
						else cast(Val as int)
					end) Mnts
			from s3
				cross apply Infra.fn_SplitString(s, ',') f)
select @LastRestartDate = dateadd(Minute, -mnts, getdate())
from s4

merge Inventory.OSServers d
	using (select @ClientID ClientID, MOB_ID, MOB_PLT_ID, @LastRestartDate LastRestartDate
			from Inventory.MonitoredObjects
			where MOB_ID = @MOB_ID) s
		on OSS_MOB_ID = MOB_ID
	when matched and OSS_LastBootUpTime < dateadd(minute, -1, LastRestartDate)
				then update set
							OSS_LastBootUpTime = LastRestartDate
	when not matched then insert(OSS_ClientID, OSS_PLT_ID, OSS_IsVirtualServer, OSS_MOB_ID)
						values(ClientID, MOB_PLT_ID, 0, MOB_ID);

delete Collect.ObjectCounterBases
where OCB_MOB_ID = @MOB_ID
	and OCB_TST_ID = @TST_ID
	and OCB_LastRestartDate < dateadd(minute, -1, @LastRestartDate)
GO
