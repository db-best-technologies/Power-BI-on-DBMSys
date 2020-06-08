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
/****** Object:  View [Tests].[VW_TST_SQLAvailabilityGroupListeners]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLAvailabilityGroupListeners]
as
select top 0 CAST(null as uniqueidentifier) group_id,
			CAST(null as nvarchar(36)) listener_id,
			CAST(null as nvarchar(63)) dns_name,
			CAST(null as nvarchar(max)) IPAddresses,
			CAST(null as int) [Port],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupListeners]    Script Date: 6/8/2020 1:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupListeners] on [Tests].[VW_TST_SQLAvailabilityGroupListeners]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)
select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.AvailabilityGroupListeners d
	using inserted s
		on ALS_MOB_ID = @MOB_ID
			and ALS_GroupID = group_id
			and ALS_ListenerID = listener_id
	when matched then update set
							ALS_DNSName = dns_name,
							ALS_Port = [Port],
							ALS_LastSeenDate = @StartDate,
							ALS_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(ALS_ClientID, ALS_MOB_ID, ALS_GroupID, ALS_ListenerID, ALS_DNSName, ALS_InsertDate, ALS_LastSeenDate, ALS_Last_TRH_ID, ALS_Port)
							values(Metadata_ClientID, @MOB_ID, group_id, listener_id, dns_name, @StartDate, @StartDate, Metadata_TRH_ID, [Port]);

merge Inventory.IPAddressStates d
	using (select distinct b.value('@IPState', 'nvarchar(60)') IPState
			from inserted
				cross apply (select CAST(IPAddresses as xml) x) t
				cross apply x.nodes('IPAddresses/IPAddresses') a(b)
			where b.value('@IPState', 'nvarchar(60)') is not null) s
		on IPS_Name = IPState
	when not matched then insert(IPS_Name)
							values(IPState);

merge Inventory.IPAddresses d
	using (select ALS_ID, case when b.value('@IPAddress', 'varchar(50)') like '%.%.%.%' then 1 else 2 end IPT_ID, b.value('@IPAddress', 'varchar(50)') IPAddress,
				b.value('@SubnetMask', 'varchar(50)') Subnet, IPS_ID, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.AvailabilityGroupListeners on ALS_MOB_ID = @MOB_ID
																	and ALS_GroupID = group_id
																	and ALS_ListenerID = listener_id
				cross apply (select CAST(IPAddresses as xml) x) t
				cross apply x.nodes('IPAddresses/IPAddresses') a(b)
				inner join Inventory.IPAddressStates on b.value('@IPState', 'nvarchar(60)') = IPS_Name) s
		on IPA_MOB_ID = @MOB_ID
			and IPA_NIN_ID is null
			and IPA_ALS_ID = ALS_ID
			and IPA_Address = IPAddress
	when matched then update set
							IPA_Subnet = Subnet,
							IPA_IPS_ID = IPS_ID,
							IPA_LastSeenDate = @StartDate,
							IPA_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(IPA_ClientID, IPA_MOB_ID, IPA_IPT_ID, IPA_Address, IPA_Subnet, IPA_ALS_ID, IPA_IPS_ID, IPA_InsertDate, IPA_LastSeenDate, IPA_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IPT_ID, IPAddress, Subnet, ALS_ID, IPS_ID, @StartDate, @StartDate, Metadata_TRH_ID);
GO
