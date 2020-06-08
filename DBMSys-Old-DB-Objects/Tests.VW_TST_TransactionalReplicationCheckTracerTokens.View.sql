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
/****** Object:  View [Tests].[VW_TST_TransactionalReplicationCheckTracerTokens]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_TransactionalReplicationCheckTracerTokens]
as
select top 0 CAST(null as int) TokenUID,
			CAST(null as int) distributor_latency,
			CAST(null as nvarchar(128)) subscriber,
			CAST(null as nvarchar(128)) subscriber_db,
			CAST(null as int) subscriber_latency,
			CAST(null as int) overall_latency,
			CAST(null as bit) is_deleted,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_TransactionalReplicationCheckTracerTokens]    Script Date: 6/8/2020 1:16:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_TransactionalReplicationCheckTracerTokens] on [Tests].[VW_TST_TransactionalReplicationCheckTracerTokens]
	instead of insert
as
set nocount on
declare @StartDate datetime2(3),
		@ValueInCaseOfTimeout int
		
select top 1 @StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
	
select @ValueInCaseOfTimeout = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Tests'
	and SET_Key = 'Transactional Replication Tracer Tokens Value On TimeOut'

update Activity.TracerTokens
set	TCT_IsClosed = 1,
	TCT_DateClosed = @StartDate,
	TCT_IsDeleted = case when subscriber is null
						then 1
						else 0
					end
from inserted
where TokenUID = TCT_ID
	and is_deleted is null

update Activity.TracerTokens
set	TCT_IsDeleted = 1
from inserted
where TokenUID = TCT_ID
	and is_deleted = 1

;with NewRecords as
		(select distributor_latency, subscriber, subscriber_db, subscriber_latency, overall_latency, Metadata_TRH_ID, Metadata_ClientID, TRP_Name PublicationName,
				IDB_Name PublicationDatabaseName
			from inserted
				inner join Activity.TracerTokens on TCT_ID = TokenUID
				inner join Inventory.TransactionalReplicationPublications on TRP_ID = TCT_TRP_ID
				inner join Inventory.InstanceDatabases on IDB_ID = TRP_IDB_ID
			where is_deleted is null
		)
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select distinct 'Replication', 'Distributor Latency',
		left('Publication: ' + PublicationName + ', From DB: ' + PublicationDatabaseName, 850) Instance,
		isnull(distributor_latency, @ValueInCaseOfTimeout), Metadata_TRH_ID, Metadata_ClientID
from NewRecords
where subscriber is not null
union all
select 'Replication', 'Subscriber Latency',
		left('Publication: ' + PublicationName + ', From DB: ' + PublicationDatabaseName + ', To DB: ' + subscriber_db + '(' + Subscriber + ')', 850) Instance,
		isnull(subscriber_latency, @ValueInCaseOfTimeout), Metadata_TRH_ID, Metadata_ClientID
from NewRecords
where subscriber is not null
union all
select 'Replication', 'Overall Latency',
		left('Publication: ' + PublicationName + ', From DB: ' + PublicationDatabaseName + ', To DB: ' + subscriber_db + '(' + Subscriber + ')', 850) Instance,
		isnull(overall_latency, @ValueInCaseOfTimeout), Metadata_TRH_ID, Metadata_ClientID
from NewRecords
where subscriber is not null
GO
