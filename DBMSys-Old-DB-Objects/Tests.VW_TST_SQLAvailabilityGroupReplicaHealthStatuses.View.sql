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
/****** Object:  View [Tests].[VW_TST_SQLAvailabilityGroupReplicaHealthStatuses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLAvailabilityGroupReplicaHealthStatuses]
as
select top 0 cast(null as uniqueidentifier) group_id,
			cast(null as nvarchar(128)) name,
			cast(null as uniqueidentifier) replica_id,
			cast(null as tinyint) [role],
			cast(null as tinyint) operational_state,
			cast(null as nvarchar(60)) operational_state_desc,
			cast(null as tinyint) connected_state,
			cast(null as nvarchar(60)) connected_state_desc,
			cast(null as tinyint) recovery_health,
			cast(null as nvarchar(60)) recovery_health_desc,
			cast(null as int) last_connect_error_number,
			cast(null as nvarchar(1024)) last_connect_error_description,
			cast(null as datetime) last_connect_error_timestamp,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupReplicaHealthStatuses]    Script Date: 6/8/2020 1:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupReplicaHealthStatuses] on [Tests].[VW_TST_SQLAvailabilityGroupReplicaHealthStatuses]
	instead of insert
as
set nocount on
declare @MOB_ID int

select @MOB_ID = TRH_MOB_ID
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

update Inventory.AvailabilityGroupReplicas
set AGR_AGO_ID = [role]
from inserted
where group_id = AGR_GroupID
		and replica_id = AGR_ReplicaID
		and ([role] <> AGR_AGO_ID
				or AGR_AGO_ID is null)

if @@ROWCOUNT > 0
	update Inventory.AvailabilityGroupReplicas
	set AGR_AGO_ID = 2
	from inserted
	where group_id = AGR_GroupID
		and replica_id <> AGR_ReplicaID
		and [role] = 1

;with LastError as
	(select top 1 *
		from Activity.AvailabilityGroupErrors
		where exists (select *
						from inserted
						where AGE_MOB_ID = @MOB_ID
							and group_id = AGE_GroupID
							and replica_id = AGE_ReplicaID
							and AGE_LastOccurence >= DATEADD(hour, -1, sysdatetime())
							and AGE_AGT_ID = 1)
		order by AGE_ID desc)
merge LastError d
	using (select group_id, replica_id, last_connect_error_number, last_connect_error_description, last_connect_error_timestamp, Metadata_ClientID
			from inserted
			where last_connect_error_number is not null) s
		on last_connect_error_number = AGE_ErrorNumber
	when matched then update set
							AGE_LastOccurence = last_connect_error_timestamp,
							AGE_NumberOfOccurences += 1
	when not matched then insert(AGE_ClientID, AGE_MOB_ID, AGE_GroupID, AGE_ReplicaID, AGE_AGT_ID, AGE_ErrorNumber, AGE_ErrorDescription, AGE_FirstOccurence,
									AGE_LastOccurence, AGE_NumberOfOccurences)
						values(Metadata_ClientID, @MOB_ID, group_id, replica_id, 0, last_connect_error_number, last_connect_error_description,
								last_connect_error_timestamp, last_connect_error_timestamp, 1);

;with ReplicaStatuses as
		(select 'Operational State' CounterName, name InstanceName, operational_state StatuseValue, operational_state_desc StatusDesc, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			union all
			select 'Connected State' CounterName, name InstanceName, connected_state StatuseValue, connected_state_desc StatusDesc, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			union all
			select 'Recovery Health' CounterName, name InstanceName, recovery_health StatuseValue, recovery_health_desc StatusDesc, Metadata_TRH_ID, Metadata_ClientID
			from inserted
		)
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select 'Availability Group Replica Health', CounterName, InstanceName, StatuseValue, StatusDesc, Metadata_TRH_ID, Metadata_ClientID
from ReplicaStatuses
GO
