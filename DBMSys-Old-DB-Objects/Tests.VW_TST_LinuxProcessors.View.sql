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
/****** Object:  View [Tests].[VW_TST_LinuxProcessors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_LinuxProcessors]
as
select top 0 CAST(null as int) [processor],
			CAST(null as varchar(100)) vendor_id,
			CAST(null as int) [cpu family],
			CAST(null as int) [model],
			CAST(null as int) [stepping],
			CAST(null as varchar(400)) [model name],
			CAST(null as varchar(4000)) flags,
			CAST(null as decimal(15, 7)) [cpu MHz],
			CAST(null as varchar(50)) [cache size],
			CAST(null as int) [physical id],
			CAST(null as int) [siblings],
			CAST(null as int) [cpu cores],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxProcessors]    Script Date: 6/8/2020 1:16:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LinuxProcessors] on [Tests].[VW_TST_LinuxProcessors]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted
declare @MOB_ID int,
		@StartDate datetime2(3)

select @MOB_ID = TRH_MOB_ID,
	@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.ProcessorCaptions d
	using (select distinct PAC_Name + ' Family ' + CAST([cpu family] as varchar(10))
									+ ' Model ' + CAST([model] as varchar(10))
									+ ' Stepping ' + CAST([stepping] as varchar(10)) Caption
			from inserted
				inner join Inventory.ProcessorArchitecture on PAC_Name = case when ' ' + flags + ' ' like '% lm %'
																				then 'x64'
																				else 'x86'
																			end) s
	on Caption = PCA_Caption
	when not matched then insert(PCA_Caption)
							values(Caption);

merge Inventory.ProcessorManufacturers d
	using (select distinct vendor_id
			from inserted
			where vendor_id is not null) s
	on vendor_id = PMN_Name
	when not matched then insert(PMN_Name)
							values(vendor_id);

merge Inventory.ProcessorNames d
	using (select distinct [model name]
			from inserted
			where [model name] is not null) s
	on [model name] = PSN_Name
	when not matched then insert(PSN_Name)
							values([model name]);

merge Inventory.Processors d
	using (select distinct Metadata_ClientID, PMN_ID, PSN_ID, PCA_ID, PAC_ID, ceiling([cpu MHz]) MaxClockSpeed,
					cast(SUBSTRING(PAC_Name, 2, 2) as int) DataWidth, 'CPU' + CAST(coalesce(nullif([physical id], 0), [processor], [physical id]) as varchar(10)) DeviceID,
					cast(left([cache size] + ' ', charindex(' ', [cache size], 1) - 1) as int) L2CacheSize, [cpu cores] NumberOfCores,
					[siblings] NumberOfLogicalProcessors, Metadata_TRH_ID
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				left join Inventory.ProcessorManufacturers on PMN_Name = vendor_id
				left join Inventory.ProcessorNames on PSN_Name = [model name]
				left join Inventory.ProcessorArchitecture on PAC_Name = case when ' ' + flags + ' ' like '% lm %'
																				then 'x64'
																				else 'x86'
																			end
				left join Inventory.ProcessorCaptions on PCA_Caption = PAC_Name + ' Family ' + CAST([cpu family] as varchar(10))
																		+ ' Model ' + CAST([model] as varchar(10))
																		+ ' Stepping ' + CAST([stepping] as varchar(10))) s
		on PRS_MOB_ID = @MOB_ID
			and PRS_DeviceID = DeviceID
	when matched then update set
							PRS_PAC_ID = PAC_ID,
							PRS_PCA_ID = PCA_ID,
							PRS_DataWidth = DataWidth,
							PRS_L2CacheSize = L2CacheSize,
							PRS_PMN_ID = PMN_ID,
							PRS_MaxClockSpeed = MaxClockSpeed,
							PRS_PSN_ID = PSN_ID,
							PRS_NumberOfCores = NumberOfCores,
							PRS_NumberOfLogicalProcessors = NumberOfLogicalProcessors,
							PRS_LastSeenDate = @StartDate,
							PRS_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(PRS_ClientID, PRS_MOB_ID, PRS_PAC_ID, PRS_PCA_ID, PRS_DataWidth, PRS_DeviceID, PRS_L2CacheSize,
									PRS_PMN_ID, PRS_MaxClockSpeed, PRS_NumberOfCores,
									PRS_NumberOfLogicalProcessors, PRS_POS_ID, PRS_InsertDate, PRS_LastSeenDate, PRS_Last_TRH_ID)
						values(Metadata_ClientID, @MOB_ID, PAC_ID, PCA_ID, DataWidth, DeviceID, L2CacheSize, PMN_ID, MaxClockSpeed, PSN_ID,
									NumberOfCores, NumberOfLogicalProcessors, @StartDate, @StartDate, Metadata_TRH_ID);

update Inventory.OSServers
set OSS_NumberOfProcessors = NumberOfProcessors,
	OSS_NumberOfLogicalProcessors = NumberOfLogicalProcessors
from (select count(*) NumberOfProcessors,
			sum(PRS_NumberOfLogicalProcessors) NumberOfLogicalProcessors
		from Inventory.Processors
		where PRS_MOB_ID = @MOB_ID) p
where OSS_MOB_Id = @MOB_ID
GO
