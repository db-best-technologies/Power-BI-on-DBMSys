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
/****** Object:  UserDefinedFunction [Collect].[GetLastTestTRHID]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Collect].[GetLastTestTRHID]
(
--DECLARE	
		@TRHID	BIGINT	--= 5479784
		,@CNT	INT		--= 5
)
RETURNS TABLE
AS RETURN (
	WITH MTH AS 
	(
		SELECT 
				TRH_TST_ID	AS TSTID
				,TRH_MOB_ID AS MOBID
		FROM	Collect.TestRunHistory
		WHERE	TRH_ID = @TRHID
	)

	SELECT 
			TOP	(@CNT)
			ROW_NUMBER() OVER (ORDER BY TRH_ID DESC) AS RN
			,TRH_ID				AS TRHID
			,TRH_InsertDate		AS InsertDate
			,TRH_TST_ID			AS TSTID
			,TRH_MOB_ID			AS MOBID
	FROM	Collect.TestRunHistory
	WHERE	TRH_TRS_ID = 3
			AND EXISTS (SELECT TOP 1 1 FROM MTH WHERE TRH_TST_ID = TSTID AND TRH_MOB_ID = MOBID)
	ORDER BY TRH_ID DESC
)
GO
