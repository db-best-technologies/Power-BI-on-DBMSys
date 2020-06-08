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
/****** Object:  StoredProcedure [GUI].[usp_Get_Collectors]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Get_Collectors]
--DECLARE
	@CTR_ID				INT = NULL
AS
	--IF EXISTS (SELECT * FROM Collect.Collectors WHERE CTR_ID = @CTR_ID OR @CTR_ID IS NULL)
		SELECT
				CTR_ID
				,CTR_Name
				,CTR_Description
				,CTR_CreateDate
				,CTR_LastConfigGetDate
				,CTR_LastResponceDate
				,CTR_IsDefault
		FROM	Collect.Collectors
		WHERE	CTR_IsDeleted = 0
				AND (CTR_ID = @CTR_ID OR @CTR_ID IS NULL)
	/*ELSE
		raiserror('Collector with Id as %s does not exists', 16, 1, @CTR_ID)*/
GO
