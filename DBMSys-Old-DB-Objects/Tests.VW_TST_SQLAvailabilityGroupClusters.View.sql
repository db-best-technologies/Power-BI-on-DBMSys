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
/****** Object:  View [Tests].[VW_TST_SQLAvailabilityGroupClusters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLAvailabilityGroupClusters]
as
select top 0 cast(null as nvarchar(256)) cluster_name,
			cast(null as tinyint) quorum_type,
			cast(null as nvarchar(60)) quorum_type_desc,
			cast(null as tinyint) quorum_state,
			cast(null as nvarchar(60)) quorum_state_desc,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupClusters]    Script Date: 6/8/2020 1:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupClusters] on [Tests].[VW_TST_SQLAvailabilityGroupClusters]
	instead of insert
as
set nocount on

merge Inventory.ClusterQuorumTypes d
	using (select distinct quorum_type, quorum_type_desc
			from inserted) s
		on quorum_type = CQT_ID
	when not matched then insert(CQT_ID, CQT_Name)
							values(quorum_type, quorum_type_desc);

merge Inventory.ClusterQuorumStates d
	using (select distinct quorum_state, quorum_state_desc
			from inserted) s
		on quorum_state = CQS_ID
	when not matched then insert(CQS_ID, CQS_Name)
							values(quorum_state, quorum_state_desc);

merge Inventory.AvailabilityGroupsClusters d
	using (select cluster_name, quorum_type, quorum_state, TRH_ID, Metadata_ClientID, TRH_StartDate
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID) s
		on cluster_name = AGC_Name
	when matched then update set
							AGC_CQT_ID = quorum_type,
							AGC_CQS_ID = quorum_state,
							AGC_LastSeenDate = TRH_StartDate,
							AGC_Last_TRH_ID = TRH_ID
	when not matched then insert(AGC_ClientID, AGC_Name, AGC_CQT_ID, AGC_CQS_ID, AGC_InsertDate, AGC_LastSeenDate, AGC_Last_TRH_ID)
							values(Metadata_ClientID, cluster_name, quorum_type, quorum_state, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
