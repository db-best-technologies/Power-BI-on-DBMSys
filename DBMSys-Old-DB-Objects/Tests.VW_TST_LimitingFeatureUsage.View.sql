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
/****** Object:  View [Tests].[VW_TST_LimitingFeatureUsage]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LimitingFeatureUsage]
as
select top 0 cast(null as nvarchar(128)) DatabaseName,
			cast(null as varchar(150)) FeatureName,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LimitingFeatureUsage]    Script Date: 6/8/2020 1:16:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LimitingFeatureUsage] on [Tests].[VW_TST_LimitingFeatureUsage]
	instead of insert
as
declare @MOB_ID int

select top 1 @MOB_ID = TRH_MOB_ID
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, DatabaseName, Metadata_TRH_ID
			from inserted
			where DatabaseName is not null) s
		on IDB_MOB_ID = @MOB_ID
		and DatabaseName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, sysdatetime(), sysdatetime(), Metadata_TRH_ID);

merge Inventory.LimitingFeatureTypes d
	using (select distinct FeatureName
			from inserted) s
		on FeatureName = LFT_Name
	when not matched then insert(LFT_Name)
							values(FeatureName);

merge Inventory.LimitingFeatureUsage d
	using (select IDB_ID, LFT_ID, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				left join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.LimitingFeatureTypes on LFT_Name = FeatureName
			) s
		on LFU_MOB_ID = @MOB_ID
			and (LFU_IDB_ID = IDB_ID
				or (LFU_IDB_ID is null
					and IDB_ID is null)
				)
			and LFU_LFT_ID = LFT_ID
	when matched then update
					set LFU_LastSeenDate = sysdatetime(),
						LFU_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(LFU_ClientID, LFU_MOB_ID, LFU_IDB_ID, LFU_LFT_ID, LFU_InsertDate, LFU_LastSeenDate, LFU_Last_TRH_ID)
						values(Metadata_ClientID, @MOB_ID, IDB_ID, LFT_ID, sysdatetime(), sysdatetime(), Metadata_TRH_ID);
GO
