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
/****** Object:  StoredProcedure [GUI].[usp_SetCollectionRunStatus]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUI].[usp_SetCollectionRunStatus]
	@Command int = 0 -- 0 = Return stats only, 1 = Enable, 2 = Disable
as
set nocount on
set transaction isolation level read uncommitted

if @Command in (1, 2)
	update Management.Settings
	set SET_Value = case @Command
						when 1 then 1
						when 2 then 0
					end
	where SET_Module = 'Collect'
		and SET_Key = 'Perform Collection'

select CAST(SET_Value as bit) CollectionRunStatus
from Management.Settings
where SET_Module = 'Collect'
	and SET_Key = 'Perform Collection'
GO
