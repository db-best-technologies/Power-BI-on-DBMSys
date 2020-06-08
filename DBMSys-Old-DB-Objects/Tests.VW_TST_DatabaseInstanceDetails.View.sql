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
/****** Object:  View [Tests].[VW_TST_DatabaseInstanceDetails]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_DatabaseInstanceDetails]
AS
	select top 0 CAST(null as nvarchar(128)) Collation,
				CAST(null as nvarchar(4000)) Edition,
				CAST(null as int) Architecture,
				CAST(null as nvarchar(128)) InstanceName,
				CAST(null as bit) IsClustered,
				CAST(null as bit) IsFullTextInstalled,
				CAST(null as bit) IsIntegratedSecurityOnly,
				CAST(null as nvarchar(128)) ProductLevel,
				CAST(null as bit) IsSingleUser,
				CAST(null as datetime) LastRestartDate,
				CAST(null as datetime) OldestBackupHistory,
				CAST(null as datetime) OldestJobHistory,
				CAST(null as datetime) CurrentErrorLogStartDate,
				CAST(null as int) IsServerNameNull,
				CAST(null as int) IsServerNameWrong,
				CAST(null as int) Port,
				CAST(null as int) DynamicPort,
				CAST(null as bit) IsTcpEnabled,
				CAST(null as bit) IsNamedPipesEnabled,
				CAST(null as bit) IsViaEnabled,
				CAST(null as int) FilestreamEffectiveLevel,
				CAST(null as int) AllowLockPagesInMemory,
				CAST(null as int) IsSystemHealthSessionRunning,
				CAST(null as bit) IsResourceGovernorEnabled,
				CAST(null as smallint) LogonTriggers,
				CAST(null as int) NumberOfAvailableSchedulers,
				CAST(null as int) Metadata_TRH_ID,
				CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabaseInstanceDetails]    Script Date: 6/8/2020 1:15:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_DatabaseInstanceDetails] on [Tests].[VW_TST_DatabaseInstanceDetails]
	instead of insert
AS
BEGIN
	set nocount on
	declare @PLT_ID tinyint,
			@MOB_ID int

	select @MOB_ID = TRH_MOB_ID,
		@PLT_ID = MOB_PLT_ID
	from inserted
		inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
		inner join Inventory.MonitoredObjects on MOB_ID = TRH_MOB_ID

	merge Inventory.Editions d
		using (select distinct @PLT_ID PLT_ID, Edition
				from inserted
				where Edition is not null) s
					on PLT_ID = EDT_PLT_ID
					and Edition = EDT_Name
		when not matched then insert (EDT_PLT_ID, EDT_Name)
								values(PLT_ID, Edition);

	merge Inventory.CollationTypes d
		using (select distinct Collation
				from inserted
				where Collation is not null) s
					on Collation = CLT_Name
		when not matched then insert (CLT_Name)
								values(Collation);

	merge Inventory.ProductLevels d
		using (select distinct ProductLevel
				from inserted
				where ProductLevel is not null) s
			on PRL_PLT_ID = 1
				and ProductLevel = PRL_Name
		when not matched then insert(PRL_PLT_ID, PRL_Name)
								values(1, ProductLevel);

	with NewRows as
		 (select MOB_Entity_ID Entity_ID, EDT_ID, InstanceName, IsClustered, Architecture, CLT_ID, IsFullTextInstalled, IsIntegratedSecurityOnly,
					PRL_ID, LastRestartDate, OldestBackupHistory, OldestJobHistory, CurrentErrorLogStartDate, IsServerNameNull,
					IsServerNameWrong, Port, DynamicPort, IsTcpEnabled, IsNamedPipesEnabled, IsViaEnabled, FilestreamEffectiveLevel,
					AllowLockPagesInMemory, IsSystemHealthSessionRunning, IsResourceGovernorEnabled, LogonTriggers, NumberOfAvailableSchedulers
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				inner join Inventory.MonitoredObjects on TRH_MOB_ID = MOB_ID
				left join Inventory.Editions on EDT_PLT_ID = @PLT_ID
											and EDT_Name = Edition
				left join Inventory.CollationTypes on Collation = CLT_Name
				left join Inventory.ProductLevels on PRL_PLT_ID = @PLT_ID
												and PRL_Name = ProductLevel
		)
	update Inventory.DatabaseInstanceDetails
	set DID_EDT_ID = EDT_ID,
		DID_InstanceName = InstanceName,
		DID_IsClustered = IsClustered,
		DID_Architecture = Architecture,
		DID_CLT_ID = CLT_ID,
		DID_IsFullTextInstalled = IsFullTextInstalled,
		DID_IsIntegratedSecurityOnly = IsIntegratedSecurityOnly,
		DID_PRL_ID = PRL_ID,
		DID_FilestreamEffectiveLevel = FilestreamEffectiveLevel,
		DID_LastRestartDate = LastRestartDate,
		DID_OldestBackupHistory = OldestBackupHistory,
		DID_OldestJobHistory = OldestJobHistory,
		DID_CurrentErrorLogStartDate = CurrentErrorLogStartDate,
		DID_IsServerNameNull = IsServerNameNull,
		DID_IsServerNameWrong = IsServerNameWrong,
		DID_Port = Port,
		DID_DynamicPort = DynamicPort,
		DID_IsTcpEnabled = IsTcpEnabled,
		DID_IsNamedPipesEnabled = IsNamedPipesEnabled,
		DID_IsViaEnabled = IsViaEnabled,
		DID_AllowLockPagesInMemory = AllowLockPagesInMemory,
		DID_IsSystemHealthSessionRunning = IsSystemHealthSessionRunning,
		DID_IsResourceGovernorEnabled = IsResourceGovernorEnabled,
		DID_LogonTriggerCount = LogonTriggers,
		DID_NumberOfAvailableSchedulers = NumberOfAvailableSchedulers
	from NewRows
	where Entity_ID = DID_DFO_ID
END
GO
