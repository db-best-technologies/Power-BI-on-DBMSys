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
/****** Object:  StoredProcedure [GUI].[usp_GetLoginTypes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetLoginTypes]
--DECLARE 
	@PLT_ID INT 
AS

SELECT 
		LPC_LGY_ID
		,LGY.LGY_Name
FROM	Management.LoginTypes_PlatformTypes c
join	SYL.LoginTypes LGY on c.LPC_LGY_ID = LGY.LGY_ID
WHERE	LPC_PLT_ID = @PLT_ID
GO
