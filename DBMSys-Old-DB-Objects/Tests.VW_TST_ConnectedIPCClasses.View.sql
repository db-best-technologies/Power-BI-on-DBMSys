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
/****** Object:  View [Tests].[VW_TST_ConnectedIPCClasses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_ConnectedIPCClasses]
as
select top 0 CAST(null as varchar(11)) CClass,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_ConnectedIPCClasses]    Script Date: 6/8/2020 1:15:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_ConnectedIPCClasses] on [Tests].[VW_TST_ConnectedIPCClasses]
	instead of insert
as
set nocount on

merge Inventory.ConnectedIPCClasses d
	using (select Metadata_ClientID, TRH_MOB_ID, CClass, TRH_StartDate, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
			) s
		on CIC_MOB_ID = TRH_MOB_ID
			and CIC_CClass = CClass
	when matched then update set
							CIC_LastSeenDate = TRH_StartDate,
							CIC_Last_TRH_ID = TRH_ID
	when not matched then insert (CIC_ClientID, CIC_MOB_ID, CIC_CClass, CIC_InsertDate, CIC_LastSeenDate, CIC_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, CClass, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
