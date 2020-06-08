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
/****** Object:  View [Tests].[VW_TST_InstanceEndPoints]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_InstanceEndPoints]
as
select top 0 CAST(null as nvarchar(128)) name,
			CAST(null as nvarchar(128)) OwnerLogin,
			CAST(null as nvarchar(60)) protocol_desc,
			CAST(null as nvarchar(60)) type_desc,
			CAST(null as nvarchar(60)) state_desc,
			CAST(null as bit) is_admin_endpoint,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceEndPoints]    Script Date: 6/8/2020 1:16:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_InstanceEndPoints] on [Tests].[VW_TST_InstanceEndPoints]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)

select @MOB_ID = TRH_MOB_ID,
		@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.EndpointNames d
	using (select distinct name
			from inserted
			where name is not null) s
		on name = EPN_Name
when not matched then insert(EPN_Name)
						values(name);

merge Inventory.EndpointProtocolTypes d
	using (select distinct protocol_desc
			from inserted
			where protocol_desc is not null) s
		on protocol_desc = EPP_Name
when not matched then insert(EPP_Name)
						values(protocol_desc);

merge Inventory.EndpointStates d
	using (select distinct state_desc
			from inserted
			where state_desc is not null) s
		on state_desc = EPS_Name
when not matched then insert(EPS_Name)
						values(state_desc);

merge Inventory.EndpointTypes d
	using (select distinct type_desc
			from inserted
			where type_desc is not null) s
		on type_desc = EPT_Name
when not matched then insert(EPT_Name)
						values(type_desc);

merge Inventory.InstanceLogins d
	using (select distinct OwnerLogin, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			where OwnerLogin is not null) s
		on INL_MOB_ID = @MOB_ID
			and INL_Name = OwnerLogin
	when not matched then insert(INL_ClientID, INL_MOB_ID, INL_Name, INL_InsertDate, INL_LastSeenDate, INL_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, OwnerLogin, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.InstanceEndPoints d
	using (select Metadata_ClientID, EPN_ID, INL_ID, EPP_ID, EPT_ID, EPS_ID, is_admin_endpoint, Metadata_TRH_ID
			from inserted
				inner join Inventory.EndpointNames on EPN_Name = name
				inner join Inventory.EndpointProtocolTypes on EPP_Name = protocol_desc
				inner join Inventory.EndpointStates on EPS_Name = state_desc
				inner join Inventory.EndpointTypes on EPT_Name = type_desc
				inner join Inventory.InstanceLogins on INL_MOB_ID = @MOB_ID
															and INL_Name = OwnerLogin) s
		on IEP_MOB_ID = @MOB_ID
			and IEP_EPN_ID = EPN_ID
	when matched then update set
							IEP_Owner_INL_ID = INL_ID,
							IEP_EPP_ID = EPP_ID,
							IEP_EPT_ID = EPT_ID,
							IEP_EPS_ID = EPS_ID,
							IEP_IsAdminEndPoint = is_admin_endpoint,
							IEP_LastSeenDate = @StartDate,
							IEP_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(IEP_ClientID, IEP_MOB_ID, IEP_EPN_ID, IEP_Owner_INL_ID, IEP_EPP_ID, IEP_EPT_ID, IEP_EPS_ID,
									IEP_IsAdminEndPoint, IEP_InsertDate, IEP_LastSeenDate, IEP_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, EPN_ID, INL_ID, EPP_ID, EPT_ID, EPS_ID, is_admin_endpoint,
									@StartDate, @StartDate, Metadata_TRH_ID);
GO
