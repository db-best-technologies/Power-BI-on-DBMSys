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
/****** Object:  StoredProcedure [GUI].[usp_Upd_Collector]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Upd_Collector]
--DECLARE
	@CTR_ID				INT
	,@CTR_Name			NVARCHAR(255)
	,@CTR_Description	NVARCHAR(4000)
	,@CTR_IsDefault		BIT = 0
AS
	UPDATE	Collect.Collectors
	SET		CTR_IsDefault = 0
	WHERE	CTR_IsDefault = 1 
			AND CTR_ID <> @CTR_ID

	IF EXISTS (SELECT * FROM Collect.Collectors WHERE CTR_ID = @CTR_ID)
		UPDATE	Collect.Collectors
		SET		CTR_Name			= @CTR_Name
				,CTR_Description	= @CTR_Description
				,CTR_IsDefault		= @CTR_IsDefault
		WHERE	CTR_ID = @CTR_ID
	ELSE
		raiserror('Collector with name as %s does not exists', 16, 1, @CTR_Name)
GO
