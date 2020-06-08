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
/****** Object:  View [Tests].[VW_TST_NetworkInterfaces]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_NetworkInterfaces]
as
select top 0 CAST(null as varchar(1000)) DefaultIPGateway,
			CAST(null as varchar(200)) [Description],
			CAST(null as bit) DHCPEnabled,
			CAST(null as varchar(1000)) DHCPServer,
			CAST(null as varchar(1000)) DNSDomain,
			CAST(null as varchar(1000)) DNSDomainSuffixSearchOrder,
			CAST(null as varchar(1000)) DNSServerSearchOrder,
			CAST(null as int) [Index],
			CAST(null as varchar(1000)) IPAddress,
			CAST(null as varchar(1000)) IPSubnet,
			CAST(null as varchar(20)) MACAddress,
			CAST(null as tinyint) TcpipNetbiosOptions,
			CAST(null as int) TcpWindowSize,
			CAST(null as bit) WINSEnableLMHostsLookup,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_NetworkInterfaces]    Script Date: 6/8/2020 1:16:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_NetworkInterfaces] on [Tests].[VW_TST_NetworkInterfaces]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)
select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.NetworkInterfaceTypes d
	using (select distinct [Description]
			from inserted
			where [Description] is not null) s
		on [Description] = NIT_Name
	when not matched then insert(NIT_Name)
							values([Description]);

merge Inventory.NetworkInterfaces d
	using (select NIT_ID, DHCPEnabled, DHCPServer, DNSDomain,
				case when DNSDomainSuffixSearchOrder like '%;'
						then left(DNSDomainSuffixSearchOrder, len(DNSDomainSuffixSearchOrder) - 1)
						else DNSDomainSuffixSearchOrder
					end DNSDomainSuffixSearchOrder,
				case when DNSServerSearchOrder like '%;'
						then left(DNSServerSearchOrder, len(DNSServerSearchOrder) - 1)
						else DNSServerSearchOrder
					end DNSServerSearchOrder, [Index], MACAddress, TcpipNetbiosOptions,
				TcpWindowSize, WINSEnableLMHostsLookup, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.NetworkInterfaceTypes on [Description] = NIT_Name
			) s
		on NIN_MOB_ID = @MOB_ID
			and NIN_Index = [Index]
	when matched then update set
							NIN_NIT_ID = NIT_ID,
							NIN_IsDHCPEnabled = DHCPEnabled,
							NIN_DHCPServer = DHCPServer,
							NIN_DNSDomain = DNSDomain,
							NIN_DNSDomainSuffixSearchOrder = DNSDomainSuffixSearchOrder,
							NIN_DNSServerSearchOrder = DNSServerSearchOrder,
							NIN_MACAddress = MACAddress,
							NIN_TNB_ID = TcpipNetbiosOptions,
							NIN_TCPWindowSize = TcpWindowSize,
							NIN_WINSEnableLMHostsLookup = WINSEnableLMHostsLookup,
							NIN_LastSeenDate = @StartDate,
							NIN_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(NIN_ClientID, NIN_MOB_ID, NIN_Index, NIN_NIT_ID, NIN_IsDHCPEnabled, NIN_DHCPServer, NIN_DNSDomain, NIN_DNSDomainSuffixSearchOrder,
									NIN_DNSServerSearchOrder, NIN_MACAddress, NIN_TNB_ID, NIN_TCPWindowSize, NIN_WINSEnableLMHostsLookup, NIN_InsertDate, NIN_LastSeenDate,
									NIN_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, [Index], NIT_ID, DHCPEnabled, DHCPServer, DNSDomain, DNSDomainSuffixSearchOrder, DNSServerSearchOrder, MACAddress,
									TcpipNetbiosOptions, TcpWindowSize, WINSEnableLMHostsLookup, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.IPAddresses d
	using (select NIN_ID, case when ip.Val like '%.%.%.%' then 1 else 2 end IPT_ID, ip.Val IPAddress, sn.Val Subnet, dg.Val DefaultGateway, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.NetworkInterfaces on NIN_MOB_ID = @MOB_ID
														and NIN_Index = [Index]
				cross apply Infra.fn_SplitString(IPAddress, ';') ip
				outer apply (select sn.Id, sn.Val
								from Infra.fn_SplitString(IPSubnet, ';') sn
								where sn.Id = ip.Id) sn
				outer apply (select dg.Id, dg.Val
								from Infra.fn_SplitString(DefaultIPGateway, ';') dg
								where dg.Id = ip.Id) dg) s
		on IPA_MOB_ID = @MOB_ID
			and IPA_NIN_ID = NIN_ID
			and IPA_ALS_ID is null
			and IPA_Address = IPAddress
	when matched then update set
							IPA_Subnet = Subnet,
							IPA_DefaultGateway = DefaultGateway,
							IPA_LastSeenDate = @StartDate,
							IPA_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(IPA_ClientID, IPA_MOB_ID, IPA_NIN_ID, IPA_IPT_ID, IPA_Address, IPA_Subnet, IPA_DefaultGateway, IPA_InsertDate, IPA_LastSeenDate, IPA_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, NIN_ID, IPT_ID, IPAddress, Subnet, DefaultGateway, @StartDate, @StartDate, Metadata_TRH_ID);
GO
