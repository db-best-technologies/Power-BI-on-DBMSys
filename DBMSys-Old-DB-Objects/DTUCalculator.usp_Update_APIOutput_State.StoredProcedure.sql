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
/****** Object:  StoredProcedure [DTUCalculator].[usp_Update_APIOutput_State]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DTUCalculator].[usp_Update_APIOutput_State]
	@AOS_MOB_ID		DTUCalculator.TT_APIOutput_State readonly --INT
	,@AOS_STATE		NVARCHAR(100)
AS
UPDATE	DTUCalculator.APIOutput_State
SET		AOS_STATE = @AOS_STATE
--WHERE	AOS_MOB_ID = @AOS_MOB_ID
WHERE	AOS_MOB_ID in (Select AOS_MOB_ID from @AOS_MOB_ID)
GO
