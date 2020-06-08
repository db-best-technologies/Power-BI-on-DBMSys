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
/****** Object:  View [Tests].[VW_TST_InstanceSuspectPages]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_InstanceSuspectPages]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as int) FileID,
			CAST(null as bigint) page_id,
			CAST(null as int) event_type,
			CAST(null as int) error_count,
			CAST(null as datetime) last_update_date,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceSuspectPages]    Script Date: 6/8/2020 1:16:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_InstanceSuspectPages] on [Tests].[VW_TST_InstanceSuspectPages]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)

select @MOB_ID = TRH_MOB_ID,
		@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.InstanceDatabases s
	using (select DISTINCT DatabaseName, Metadata_TRH_ID, Metadata_ClientID
			from inserted) d
		on IDB_MOB_ID = @MOB_ID
			and IDB_Name = DatabaseName
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, @StartDate, @StartDate, Metadata_TRH_ID);
;WITH ins AS 
(
	select	DISTINCT 
			IDB_ID
			, FileID
			, page_id
			, event_type
			, Metadata_ClientID
			, Metadata_TRH_ID
			, DatabaseName
	from	inserted i1
	inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID	and IDB_Name = i1.DatabaseName
)
merge Inventory.SuspectPages d
	using (
			select	DISTINCT 
					IDB_ID
					, FileID
					, page_id
					, event_type
					, error_count
					, last_update_date
					, Metadata_ClientID
					, Metadata_TRH_ID
			from	ins i1
			CROSS APPLY (
							SELECT 
									MAX(last_update_date)	AS last_update_date
									,SUM(error_count)		AS error_count
							FROM	inserted i2
							WHERE	i1.DatabaseName		= i2.DatabaseName
									AND i1.FileID		= i2.FileID	
									AND i1.page_id		= i2.page_id	
									AND i1.event_type	= i2.event_type
						)i2
				) s
		on SSP_MOB_ID = @MOB_ID
			and SSP_IDB_ID = IDB_ID
			and SSP_FileID = FileID
			and SSP_PageID = page_id
			and SSP_EventType = event_type
	when matched then update set
							SSP_ErrorCount = error_count,
							SSP_LastUpdateDate = last_update_date,
							SSP_LastSeenDate = @StartDate,
							SSP_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(SSP_ClientID, SSP_MOB_ID, SSP_IDB_ID, SSP_FileID, SSP_PageID, SSP_EventType, SSP_ErrorCount,
									SSP_LastUpdateDate, SSP_InsertDate, SSP_LastSeenDate, SSP_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, FileID, page_id, event_type, error_count,
									last_update_date, @StartDate, @StartDate, Metadata_TRH_ID);
GO
