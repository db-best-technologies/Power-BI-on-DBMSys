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
/****** Object:  StoredProcedure [Management].[usp_ModifyConfiguration]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Management].[usp_ModifyConfiguration]
--declare
	@Module		varchar(100),	--= N'Consolidation',
	@Key		varchar(100),		--= N'CPU Buffer Percentage',--N'Disk IO Buffer Percentage',
	@Value		sql_variant		--= '10.0'
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@cValue			nvarchar(4000),
		@ConvertedValue	sql_variant

	SET @cValue = CAST(@Value AS nvarchar(4000))
		
	BEGIN TRY

		EXEC Management.usp_CheckSettingType
			@Module	= @Module,
			@Key	= @Key,
			@Value	= @cValue,
			@ConvertedValue = @ConvertedValue OUTPUT

		UPDATE Management.Settings
		SET SET_Value = @ConvertedValue
		WHERE SET_Module = @Module
			and SET_Key = @Key
	END TRY
	BEGIN CATCH
		DECLARE
			@MSG	nvarchar(2048)

		SET @MSG = ERROR_MESSAGE()

		RAISERROR(@MSG, 16, 1)
	END CATCH
END
GO
