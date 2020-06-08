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
/****** Object:  StoredProcedure [GUI].[usp_Get_Predefined_Credentials]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Get_Predefined_Credentials]
--declare
		@PLT_ID INT --= 1
AS
BEGIN
	SELECT 
		SLG_ID as Credential_Id
		,SLG_Login as Credential_Login
		,SLG_Description
	FROM
		SYL.SecureLogins AS SLG
		INNER JOIN Management.LoginTypes_PlatformTypes AS LPC 
		ON SLG.SLG_LGY_ID = LPC.LPC_LGY_ID
	WHERE	/*SLG_Ispredefined = 1
			and */LPC.LPC_PLT_ID = @PLT_ID
	ORDER BY 1
END
GO
