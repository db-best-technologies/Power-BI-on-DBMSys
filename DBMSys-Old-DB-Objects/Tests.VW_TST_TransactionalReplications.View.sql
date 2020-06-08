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
/****** Object:  View [Tests].[VW_TST_TransactionalReplications]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_TransactionalReplications]
as
select top 0 CAST(null as nvarchar(128)) Publisher,
			CAST(null as nvarchar(128)) Publication,
			CAST(null as nvarchar(128)) PublisherDB,
			CAST(null as nvarchar(128)) Subscriber,
			CAST(null as nvarchar(128)) SubscriberDB,
			CAST(null as nvarchar(128)) DistributionDatabase,
			CAST(null as varchar(4)) SubscriptionType,
			CAST(null as int) DistributionAgentID,
			CAST(null as datetime) LastLogReaderErrorDate,
			CAST(null as nvarchar(4000)) LogReaderError,
			CAST(null as datetime) LastDistributionErrorDate,
			CAST(null as nvarchar(max)) DistributionError,
			CAST(null as datetime) LastSnapshotErrorDate,
			CAST(null as nvarchar(1000)) SnapshotError,
			CAST(null as varchar(13)) LogReaderStatus,
			CAST(null as varchar(13)) DistributionAgentStatus,
			CAST(null as varchar(13)) SnapshotAgentStatus,
			CAST(null as bigint) PendingCommandsCount,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_TransactionalReplications]    Script Date: 6/8/2020 1:16:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_TransactionalReplications] on [Tests].[VW_TST_TransactionalReplications]
	instead of insert
as
set nocount on
declare @Distributor_MOB_ID int,
		@StartDate datetime2(3)
select top 1 @Distributor_MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
	inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
	
merge Inventory.TransactionalReplicationAgentStatuses d
	using (select LogReaderStatus AgentStatus
			from inserted
			where LogReaderStatus is not null
			union select DistributionAgentStatus AgentStatus
			from inserted
			where DistributionAgentStatus is not null
			union select SnapshotAgentStatus AgentStatus
			from inserted
			where SnapshotAgentStatus is not null) s
		on AgentStatus = TRA_Name
	when not matched then insert(TRA_Name)
							values(AgentStatus);

merge Inventory.InstanceDatabases d
	using (select MOB_ID, PublisherDB DatabaseName, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
			union
			select @Distributor_MOB_ID MOB_ID, DistributionDatabase DatabaseName, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			union
			select MOB_ID, SubscriberDB DatabaseName, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Subscriber
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID) s
		on IDB_MOB_ID = MOB_ID
			and IDB_Name = DatabaseName
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, MOB_ID, DatabaseName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.TransactionalReplicationPublications d
	using (select distinct PublisherDB, MOB_ID Publisher_MOB_ID, Publication, pdb.IDB_ID Publication_IDB_ID, ddb.IDB_ID Distribution_IDB_ID,
					 ls.TRA_ID LogReader_TRA_ID, ss.TRA_ID SnapshotAgent_TRA_ID, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
				inner join Inventory.InstanceDatabases pdb on pdb.IDB_MOB_ID = MOB_ID
															and pdb.IDB_Name = PublisherDB
				inner join Inventory.InstanceDatabases ddb on ddb.IDB_MOB_ID = @Distributor_MOB_ID
															and ddb.IDB_Name = DistributionDatabase
				left join Inventory.TransactionalReplicationAgentStatuses ls on ls.TRA_Name = LogReaderStatus
				left join Inventory.TransactionalReplicationAgentStatuses ss on ss.TRA_Name = SnapshotAgentStatus
															) s
		on TRP_MOB_ID = Publisher_MOB_ID
			and TRP_Name = Publication
	when matched then update set
							TRP_IDB_ID = Publication_IDB_ID,
							TRP_Distributor_MOB_ID = @Distributor_MOB_ID,
							TRP_Distributor_IDB_ID = Distribution_IDB_ID,
							TRP_LogReader_TRA_ID = LogReader_TRA_ID,
							TRP_SnapshotAgent_TRA_ID = SnapshotAgent_TRA_ID,
							TRP_LastSeenDate = @StartDate,
							TRP_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(TRP_ClientID, TRP_MOB_ID, TRP_Name, TRP_IDB_ID, TRP_Distributor_MOB_ID, TRP_Distributor_IDB_ID, TRP_LogReader_TRA_ID,
								TRP_SnapshotAgent_TRA_ID, TRP_InsertDate, TRP_LastSeenDate, TRP_Last_TRH_ID)
							values(Metadata_ClientID, Publisher_MOB_ID, Publication, Publication_IDB_ID, @Distributor_MOB_ID, Distribution_IDB_ID, LogReader_TRA_ID,
								SnapshotAgent_TRA_ID, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.TransactionalReplicationSubscriptions d
	using (select distinct pmob.MOB_ID Publisher_MOB_ID, TRP_ID, DistributionAgentID, TPT_ID, Subscriber, smob.MOB_ID Subscriber_MOB_ID,
				SubscriberDB, IDB_ID, TRA_ID, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.DatabaseInstanceDetails pdid on pdid.DID_Name = Publisher
				inner join Inventory.MonitoredObjects pmob on pmob.MOB_PLT_ID = 1
															and pmob.MOB_Entity_ID = pdid.DID_DFO_ID
				inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = pmob.MOB_ID
																		and TRP_Name = Publication
				inner join Inventory.DatabaseInstanceDetails sdid on sdid.DID_Name = Subscriber
				inner join Inventory.MonitoredObjects smob on smob.MOB_PLT_ID = 1
															and smob.MOB_Entity_ID = sdid.DID_DFO_ID
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = smob.MOB_ID
															and IDB_Name = SubscriberDB
				inner join Inventory.TransactionalReplicationSubscriptionTypes on TPT_Name = SubscriptionType
				left join Inventory.TransactionalReplicationAgentStatuses on TRA_Name = DistributionAgentStatus
															) s
		on TRB_MOB_ID = Publisher_MOB_ID
			and TRB_TRP_ID = TRP_ID
			and TRB_DistributionAgentID = DistributionAgentID
	when matched then update set
							TRB_TPT_ID = TPT_ID,
							TRB_SubscriberServerName = Subscriber,
							TRB_Subscriber_MOB_ID = Subscriber_MOB_ID,
							TRB_SubscriberDatabaseName = SubscriberDB,
							TRB_Subscriber_IDB_ID = IDB_ID,
							TRB_DistributionAgent_TRA_ID = TRA_ID,
							TRB_LastSeenDate = @StartDate,
							TRB_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(TRB_ClientID, TRB_MOB_ID, TRB_TRP_ID, TRB_DistributionAgentID, TRB_TPT_ID, TRB_SubscriberServerName, TRB_Subscriber_MOB_ID, TRB_SubscriberDatabaseName,
									TRB_Subscriber_IDB_ID, TRB_DistributionAgent_TRA_ID, TRB_InsertDate, TRB_LastSeenDate, TRB_Last_TRH_ID)
							values(Metadata_ClientID, Publisher_MOB_ID, TRP_ID, DistributionAgentID, TPT_ID, Subscriber, Subscriber_MOB_ID, SubscriberDB, IDB_ID, TRA_ID, @StartDate,
									@StartDate, Metadata_TRH_ID);

;with ErrorMessages as
		(select Metadata_TRH_ID, Metadata_ClientID, MOB_ID, TRP_ID, cast(null as int) TRB_ID, 1 RAT_ID, max(LastSnapshotErrorDate) ErrorDate, max(SnapshotError) ErrorMessage
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
				inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = MOB_ID
																		and TRP_Name = Publication
			where SnapshotError is not null
			group by Metadata_TRH_ID, Metadata_ClientID, MOB_ID, TRP_ID
			union all
			select Metadata_TRH_ID, Metadata_ClientID, MOB_ID, TRP_ID, cast(null as int) TRB_ID, 2 RAT_ID, max(LastLogReaderErrorDate) ErrorDate, max(LogReaderError) ErrorMessage
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
				inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = MOB_ID
																		and TRP_Name = Publication
			where LogReaderError is not null
			group by Metadata_TRH_ID, Metadata_ClientID, MOB_ID, TRP_ID
			union all
			select Metadata_TRH_ID, Metadata_ClientID, MOB_ID, TRP_ID, TRB_ID, 3 RAT_ID, max(LastDistributionErrorDate) ErrorDate, max(DistributionError) ErrorMessage
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
				inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = MOB_ID
																		and TRP_Name = Publication
				inner join Inventory.TransactionalReplicationSubscriptions on TRB_MOB_ID = MOB_ID
																		and TRB_TRP_ID = TRP_ID
																		and TRB_DistributionAgentID = DistributionAgentID
			where DistributionError is not null
			group by Metadata_TRH_ID, Metadata_ClientID, MOB_ID, TRP_ID, TRB_ID
		)
merge Activity.ReplicationErrors d
	using ErrorMessages s
		on RPE_MOB_ID = MOB_ID
			and RPE_TRP_ID = TRP_ID
			and (RPE_TRB_ID = TRB_ID
				or (RPE_TRB_ID is null
					and TRB_ID is null)
				)
			and RPE_RAT_ID = RAT_ID
			and RPE_HashedErrorMessage = hashbytes('MD5',left(CONVERT(varchar(max),RPE_ErrorMessage,0),(8000)))
			and RPE_ErrorMessage = ErrorMessage
			and RPE_IsClosed = 0
	when matched then update set
							RPE_LastFailureDate = case when RPE_LastFailureDate < ErrorDate
														then ErrorDate
														else RPE_LastFailureDate
													end,
							RPE_FailureCount = case when RPE_LastFailureDate < ErrorDate
														then RPE_FailureCount + 1
														else RPE_FailureCount
													end,
							RPE_LastSeenDate = @StartDate,
							RPE_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(RPE_ClientID, RPE_MOB_ID, RPE_TRP_ID, RPE_TRB_ID, RPE_RAT_ID, RPE_FirstFailureDate, RPE_LastFailureDate, RPE_FailureCount, RPE_ErrorMessage,
									RPE_IsClosed, RPE_ObjectDeleted, RPE_InsertDate, RPE_LastSeenDate, RPE_Last_TRH_ID)
							values(Metadata_ClientID, MOB_ID, TRP_ID, TRB_ID, RAT_ID, ErrorDate, ErrorDate, 1, ErrorMessage, 0, 0, @StartDate, @StartDate, Metadata_TRH_ID);

;with NoErrorMessages as
		(select Metadata_ClientID, MOB_ID, TRP_ID, cast(null as int) TRB_ID, 1 RAT_ID
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
				inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = MOB_ID
																		and TRP_Name = Publication
			where SnapshotError is null
			union all
			select Metadata_ClientID, MOB_ID, TRP_ID, cast(null as int) TRB_ID, 2 RAT_ID
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
				inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = MOB_ID
																		and TRP_Name = Publication
			where LogReaderError is null
			union all
			select Metadata_ClientID, MOB_ID, TRP_ID, TRB_ID, 3 RAT_ID
			from inserted
				inner join Inventory.DatabaseInstanceDetails on DID_Name = Publisher
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
															and MOB_Entity_ID = DID_DFO_ID
				inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = MOB_ID
																		and TRP_Name = Publication
				inner join Inventory.TransactionalReplicationSubscriptions on TRB_MOB_ID = MOB_ID
																		and TRB_TRP_ID = TRP_ID
																		and TRB_DistributionAgentID = DistributionAgentID
			where DistributionError is null
		)
update Activity.ReplicationErrors
set RPE_IsClosed = 1,
	RPE_CloseDate = @StartDate
from NoErrorMessages
where RPE_IsClosed = 0
	and RPE_MOB_ID = MOB_ID
	and RPE_TRP_ID = TRP_ID
	and (RPE_TRB_ID = TRB_ID
		or (RPE_TRB_ID is null
			and TRB_ID is null)
		)
	and RPE_RAT_ID = RAT_ID

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'Replication', 'Pending Commands',
		left('Publication: ' + Publication + ', From DB: ' + PublisherDB + ', To DB: ' + SubscriberDB + '(' + Subscriber + ')', 850) Instance,
		PendingCommandsCount, Metadata_TRH_ID, Metadata_ClientID
from inserted
where PendingCommandsCount is not null
GO
