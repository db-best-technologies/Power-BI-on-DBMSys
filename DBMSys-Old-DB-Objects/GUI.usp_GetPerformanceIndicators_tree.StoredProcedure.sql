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
/****** Object:  StoredProcedure [GUI].[usp_GetPerformanceIndicators_tree]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetPerformanceIndicators_tree]
AS
BEGIN
	--SELECT
	--	100000 + QRT_ID	as Id
	--	,QRT_Name		as Name
	--	,cast(null as int) as ParentId
	--FROM Collect.QueryTypes
	--UNION ALL
	SELECT DISTINCT
		200000 + TCA_ID AS Id
		,TC.TCA_Name AS Name
		,cast(null as int) AS ParentId
		--,100000 + T.TST_QRT_ID AS Parent_ID
	FROM 
		Collect.Tests AS T
		INNER JOIN Collect.TestCategories_Tests AS TCT
		ON T.TST_ID = TCT.TCS_TST_ID
		INNER JOIN [Collect].[TestCategories] AS TC
		ON TCT.TCS_TCA_ID = TC.TCA_ID
	UNION ALL
	SELECT
		T.TST_ID
		,TST_Name
		,200000 + TCT.TCS_TCA_ID
	FROM 
		Collect.Tests AS T
		INNER JOIN Collect.TestCategories_Tests AS TCT
		ON T.TST_ID = TCT.TCS_TST_ID
	ORDER BY Name
END
GO
