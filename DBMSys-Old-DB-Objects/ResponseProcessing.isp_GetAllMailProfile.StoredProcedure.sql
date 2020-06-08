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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_GetAllMailProfile]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_GetAllMailProfile]
AS
	DECLARE @currentProfile nvarchar(128)
	SELECT @currentProfile = CAST(SET_Value AS SYSNAME) FROM Management.Settings WHERE SET_Key = 'Preferred Mail Profile'
	

	SELECT 
			profile_id
			,[name]
			, iif([name]=@currentProfile, 1,0) AS IsCurrent
	FROM msdb.dbo.sysmail_profile
GO
