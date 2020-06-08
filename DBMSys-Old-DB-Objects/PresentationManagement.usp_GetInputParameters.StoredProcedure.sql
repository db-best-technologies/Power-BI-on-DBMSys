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
/****** Object:  StoredProcedure [PresentationManagement].[usp_GetInputParameters]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [PresentationManagement].[usp_GetInputParameters]
--declare
	@PRN_ID		int = NULL
	,@IsCost	BIt = 1
as
set nocount on

select 
		IPR_CategoryName [Category Name]
		, IPR_Name [Name]
		, IPR_Description [Description]
		, IPR_IPD_ID [Value Type]
		, IPR_Value [Value]
		, IPR_BinaryValue [BinaryValue]
		, IPR_TableDescription [Table Description]
from	PresentationManagement.InputParameters
where	IPR_PRN_ID = @PRN_ID 
		AND @PRN_ID IS NOT NULL
		AND IPR_CategoryName NOT IN ('Client Infrastructural Info','Pricing Data')
UNION ALL
SELECT 
		SET_Module			[Category Name]
		,SET_Key			[Name]
		, SET_Description	[Description]
		, 2					[Value Type]
		, SET_Value			[Value]
		,NULL				[BinaryValue]
		,NULL				[IPR_TableDescription]
FROM	Management.Settings
WHERE	SET_Module IN ('Client Infrastructural Info','Pricing Data')
		AND @IsCost  = 1
order by [Category Name], [Name]
GO
