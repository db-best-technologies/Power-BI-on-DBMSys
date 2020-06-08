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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_SetMailProfile]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_SetMailProfile] --1
	@profileID INT
AS
	DECLARE @profile NVARCHAR(128)--sysname
	
	SELECT 	@profile = [name]
	FROM msdb.dbo.sysmail_profile
	WHERE profile_id = @profileID

	IF(@profile IS NOT NULL)
		UPDATE Management.Settings
		SET SET_Value = @profile
		WHERE SET_Key = 'Preferred Mail Profile'
GO
