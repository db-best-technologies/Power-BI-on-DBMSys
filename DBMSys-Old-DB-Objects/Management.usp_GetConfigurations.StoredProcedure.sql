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
/****** Object:  StoredProcedure [Management].[usp_GetConfigurations]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Management].[usp_GetConfigurations]
	@Module varchar(100) = null,
	@Key varchar(100) = null
as
set nocount on
declare @SQL nvarchar(max)

set @SQL =
'select SET_Module Module, SET_Category [Category], SET_Key [Key], SET_Description [Description], SET_Value Value
from Management.Settings
where 1 = 1'
	+ iif(@Module is null, '', char(13)+char(10) + char(9) + 'and SET_Module = @Module')
	+ iif(@Key is null, '', char(13)+char(10) + char(9) + 'and SET_Key = @Key')
	+ char(13)+char(10) + 'order by Module, [Category], [Key]'

exec sp_executesql @SQL,
					N'@Module varchar(100),
						@Key varchar(100)',
					@Module = @Module,
					@Key = @Key
GO
