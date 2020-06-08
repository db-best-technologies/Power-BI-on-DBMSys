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
/****** Object:  StoredProcedure [GUI].[usp_GetHealthCheckFieldMappings]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetHealthCheckFieldMappings]
as
set nocount on
set transaction isolation level read uncommitted

select RUL_ID RuleID, RUL_Name RuleName, RUL_Primary_OBT_ID PrimaryObjectTypeID,
	isnull(RUL_Secondary_OBT_ID, RUL_Primary_OBT_ID) SecondaryObjectTypeID,
	stuff((select ',' + CAT_Name
		from BusinessLogic.Rules_Categories
			inner join BusinessLogic.Categories on RLC_CAT_ID = CAT_ID
		where RLC_RUL_ID = RUL_ID
		order by CAT_Name
		for xml path('')), 1, 1, '') Categories,
	RUL_ColumnMap ColumnMapping
from BusinessLogic.Rules
where RUL_IsActive = 1
order by RUL_ID
GO
