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
/****** Object:  StoredProcedure [Management].[usp_SetEnvironmentName]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Management].[usp_SetEnvironmentName]
	@EnvironmentName varchar(1000),
	@LicensingKey varchar(100)
as
set nocount on

update Management.Settings
set SET_Value = @EnvironmentName
where SET_Module = 'Management'
	and SET_Key = 'Environment Name'

update Management.Settings
set SET_Value = CHECKSUM(@EnvironmentName)
where SET_Module = 'Management'
	and SET_Key = 'Client ID'

update Management.Settings
set SET_Value = @LicensingKey
where SET_Module = 'Management'
	and SET_Key = 'Licensing Key'

declare @SQL nvarchar(max) =
	(select Script + ''
	from
		(select 'declare @ClientID int select @ClientID = CAST(SET_Value as int) from Management.Settings where SET_Module = ''Management'' and SET_Key = ''Client ID'';' Script
		union all
		select 'update ' + s.name + '.' + t.name + ' set ' + c.name + ' = @ClientID where ' + c.name + ' != @ClientID;' Script
		from sys.tables t
			inner join sys.schemas s on s.schema_id = t.schema_id
			inner join sys.columns c on c.object_id = t.object_id
		where c.name like '%[_]ClientID'
		) t
	for xml path(''))
exec('disable trigger all on ResponseProcessing.EventSubscriptions')
exec(@SQL)
exec('enable trigger all on ResponseProcessing.EventSubscriptions')
GO
