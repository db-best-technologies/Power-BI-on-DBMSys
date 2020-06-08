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
/****** Object:  StoredProcedure [Activity].[AlwaysOnReplicasSyncLoginsCheck]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Activity].[AlwaysOnReplicasSyncLoginsCheck]
	@EventDescription nvarchar(1000)
AS

Declare @l_Body nvarchar(max)=''

;with AvailabilityGroup as (
select distinct AGH_GroupID ,AGH_MOB_ID,AGH_ReplicaRoleDesc  from Inventory.AvailabilityGroupHealth
WHERE  AGH_IsLocal = 1 and AGH_IsDeleted = 0
)

,Result as (
	select  mob_id,
	        mob_name             as InstanceName,
			INL_Name             as LoginName,
			ILT_Name             as LoginType,
			INL_SID              as SID,
			INL_IsDisabled       as IsDisabled,
			INL_PasswordHash     as PasswordHash,
			INL_HasControlServer as HasControlServer,
			INL_IsLocked         as IsLocked,
			INL_IsPolicyChecked  as IsPolicyChecked,
			AGH_GroupID          as GroupID, 
			AGH_ReplicaRoleDesc  as ReplicaRoleDesc
	from Inventory.MonitoredObjects
	join Inventory.InstanceLogins on MOB_ID = INL_MOB_ID 
	join Inventory.InstanceLoginTypes on INL_ILT_ID = ILT_ID 
	join AvailabilityGroup on AGH_MOB_ID = MOB_ID
	where MOB_OOS_ID = 1 and MOB_PLT_ID = 1 and 
	 not (
		
         INL_Name like '%\Administrator'
	  or INL_Name like 'NT SERVICE%'
	  or INL_Name like '##%##'
	  )
	  and mob_id not in (select AGH_MOB_ID from AvailabilityGroup where AGH_GroupID in (select AGH_GroupID from AvailabilityGroup group by AGH_GroupID having count(1)= 1)
						  and AGH_ReplicaRoleDesc ='PRIMARY')
)

, AG_Prim as (

select mob_id,InstanceName,LoginName,LoginType,SID,IsDisabled,PasswordHash,HasControlServer,IsLocked, IsPolicyChecked, GroupID, ReplicaRoleDesc
 from result t
where ReplicaRoleDesc = 'PRIMARY'

)
, AG_Second as (

select mob_id,InstanceName,LoginName,LoginType,SID,IsDisabled,PasswordHash,HasControlServer,IsLocked, IsPolicyChecked, GroupID, ReplicaRoleDesc
 from result t
where ReplicaRoleDesc ='SECONDARY'
)



	select @l_Body += '
	<style>
					
					th {padding:8px; background-color: LightGrey; font-weight: bold; text-align: center; white-space: nowrap; font: Verdana; }
					.nowrap { white-space: nowrap; }
					.trwrap { white-space: nowrap; }
					td { font:9pt Verdana; border-color:silver; white-space: nowrap; padding: 3px; }
					table.narrow td { font:8.5pt Verdana; }
					.W {background-color: White;}
					table.WW1 td { font-family: "Times New Roman"; font-size:small; padding:0; }

			</style>'
		+
		(select '<font size="6" face="Times new Roman"><center><u><b>' + 'Report synchronization of logins on the SQL servers with AlwaysOn ' + '</b></u></center></font><br><br><br>')
		+
		'<table border="1" cellpadding="2" style="border-collapse: collapse; background-color: White; width:100%;">'
			
				+ replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
					(select '' + Col
							from (values('No.'),
							            ('PRIMARY Instance Name'),
										('SECONDARY Instance Name'),
										('Login Name'),
										('Login Type'),
										('Description issue')
										) th(Col)

							for xml auto, elements, root('tr'))
						+
						
						(SELECT 
						    CONCAT(ROW_NUMBER() OVER(ORDER BY ISnull(p.InstanceName ,s.InstanceName),ISnull(p.LoginName ,s.LoginName)), '.') td,
							isnull(p.InstanceName,'') as td,
							isnull(s.InstanceName,'') as td,
							ISnull(p.LoginName ,s.LoginName) as td, 
							ISnull(p.LoginType ,s.LoginType) as td,

					case when p.SID is null then ' has not on Primary,' else '' end+
					case when s.SID is null then ' has not on Secondary,' else '' end+
					case when p.SID <> s.SID then ' SID incorrect,' else '' end+
					case when p.HasControlServer <> s.HasControlServer or p.IsLocked <> s.IsLocked or p.IsPolicyChecked <> s.IsPolicyChecked then ' policy incorrect, ' else '' end+
					case when not  (p.PasswordHash = s.PasswordHash  or (p.PasswordHash is null and  s.PasswordHash is null)) then ' password incorrect ' else '' end
					 as td
 
					 from AG_Prim p
						 full join AG_Second s on p.GroupID = s.GroupID and p.LoginName = s.LoginName
					where not( p.SID = s.SID 
						and (p.PasswordHash = s.PasswordHash  or (p.PasswordHash is null and  s.PasswordHash is null))
						and p.IsLocked = s.IsLocked
						and p.IsPolicyChecked = s.IsPolicyChecked
					)
					or p.SID is null or s.SID is null 
					order by ISnull(p.InstanceName ,s.InstanceName),ISnull(p.LoginName ,s.LoginName)
					for xml raw('tr'), elements xsinil
						)
						, ' xsi:nil="true"/', '>&nbsp;</td'), ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', '')
						, '"/>', ''), '_+_', '"'), '_x0020_', ' ')
						, '&#x0D;', char(13)), '&#x0A;', char(10)), char(13)+char(10), '<br>'), char(13), '<br>'), char(10), '<br>')
						, '&amp;', '&'), '&gt;', '>'), '&lt;', '<')
						, '&#60;b>', '<b>'), '&#60;/b>', '</b>')
				+ '</TABLE>' 




SET @l_Body = REPLACE(@l_Body, '<tr><td>', '<tr><td align="center">');
SET @l_Body = REPLACE(@l_Body, '<tr><td align="center">W ', '<tr class="W"><td align="center">');			

Declare @profile_name sysname
select @profile_name = cast(SET_Value as sysname) from Management.Settings where SET_Module ='Management' and 	SET_Key ='Preferred Mail Profile'

IF @l_Body IS NOT NULL
	SELECT 
			0 AS F_MOB_ID
			,'AlwaysOn replicas has not synchronized logins' AS F_InstanceName
			,@l_Body AS AlertMessage
			,(SELECT @EventDescription
			for xml path('Alert'), root('Alerts'), type
			) AlertEventData
GO
