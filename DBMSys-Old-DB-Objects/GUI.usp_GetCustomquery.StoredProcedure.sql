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
/****** Object:  StoredProcedure [GUI].[usp_GetCustomquery]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetCustomquery]
--DECLARE
	@DWT_ID	INT
AS

	;with tbl as 
	(
		select
				DCC_ID
				,DCC_Name
				,CAST('<A>'+ REPLACE(DCC_WidgetPermission,',','</A><A>')+ '</A>' AS XML) AS DCC_WidgetPermission
		from	GUI.DashboardWidgetCustomQuery
	)

	SELECT 
			DCC_ID
			,DCC_Name
	FROM	tbl
	cross apply DCC_WidgetPermission.nodes('/A') AS x(t)
	WHERE	t.value('.', 'int') = @DWT_ID
GO
