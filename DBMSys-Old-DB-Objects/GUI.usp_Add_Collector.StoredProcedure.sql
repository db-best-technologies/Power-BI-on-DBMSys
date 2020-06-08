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
/****** Object:  StoredProcedure [GUI].[usp_Add_Collector]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Add_Collector]
--DECLARE
	@CTR_ID				INT OUTPUT
	,@CTR_Name			NVARCHAR(255)
	,@CTR_Description	NVARCHAR(4000)
	,@CTR_IsDefault		BIT = 0
AS
	IF NOT EXISTS (SELECT * FROM Collect.Collectors WHERE CTR_Name = @CTR_Name AND CTR_IsDeleted = 0)
	BEGIN
		IF	@CTR_IsDefault = 1
			UPDATE	Collect.Collectors
			SET		CTR_IsDefault = 0
			WHERE	CTR_IsDefault = 1
		
		DECLARE @t table (id int)

		INSERT INTO Collect.Collectors(CTR_Name,CTR_Description,CTR_CreateDate,CTR_IsDeleted,CTR_IsDefault)
		OUTPUT inserted.CTR_ID into @t(id)
		SELECT
				@CTR_Name
				,@CTR_Description
				,GETUTCDATE()
				,CAST(0 AS BIT)
				,@CTR_IsDefault

		SELECT @CTR_ID = id from @t

	END
	ELSE
		raiserror('Collector with name as %s already exists', 16, 1, @CTR_Name)
GO
