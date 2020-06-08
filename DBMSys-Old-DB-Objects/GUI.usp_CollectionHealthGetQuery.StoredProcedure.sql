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
/****** Object:  StoredProcedure [GUI].[usp_CollectionHealthGetQuery]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_CollectionHealthGetQuery]
--DECLARE 
		@MOBID	INT --= 832
		,@QRTID	INT = NULL
		,@TSTID	INT = NULL
AS
;WITH gto AS 
(
	select 
			*
	from	Collect.fn_GetObjectTests(null)
	WHERE	MOB_ID = @MOBID
			AND (TST_QRT_ID = @QRTID OR @QRTID IS NULL)
			AND (TST_ID = @TSTID OR @TSTID IS NULL)
)
SELECT 
		v.TSV_ID
		,v.TSV_Query
		,v.TSV_QueryFunction
FROM	gto
JOIN	Collect.TestVersions v on gto.TSV_ID = v.TSV_ID
GO
