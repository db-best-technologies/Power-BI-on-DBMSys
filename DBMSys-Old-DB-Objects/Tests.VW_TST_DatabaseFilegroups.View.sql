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
/****** Object:  View [Tests].[VW_TST_DatabaseFilegroups]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_DatabaseFilegroups]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) name,
			CAST(null as char(2)) [type],
			CAST(null as bit) is_default,
			CAST(null as bit) is_read_only,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabaseFilegroups]    Script Date: 6/8/2020 1:15:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_DatabaseFilegroups] on [Tests].[VW_TST_DatabaseFilegroups]
	instead of insert
as
set nocount on
declare @MOB_ID int

select top 1 @MOB_ID = TRH_MOB_ID
from inserted
	inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, DatabaseName, Metadata_TRH_ID
			from inserted) s
		on IDB_MOB_ID = @MOB_ID
		and DatabaseName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, sysdatetime(), sysdatetime(), Metadata_TRH_ID);

merge Inventory.DatabaseFileGroups d
	using (select Metadata_ClientID, IDB_ID, name, FGT_ID, is_default, is_read_only, TRH_StartDate, TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and DatabaseName = IDB_Name
				inner join Inventory.FileGroupTypes on [Type] = FGT_Code
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
			) s
				on DFG_MOB_ID = @MOB_ID
					and DFG_IDB_ID = IDB_ID
					and DFG_Name = name
	when matched then update set
								DFG_FGT_ID = FGT_ID,
								DFG_IsDefault = is_default,
								DFG_IsReadOnly = is_read_only,
								DFG_LastSeenDate = TRH_StartDate,
								DFG_Last_TRH_ID = TRH_ID
	when not matched then insert(DFG_ClientID, DFG_MOB_ID, DFG_IDB_ID, DFG_Name, DFG_FGT_ID, DFG_IsDefault, DFG_IsReadOnly, DFG_InsertDate, DFG_LastSeenDate,
								DFG_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, name, FGT_ID, is_default, is_read_only, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
