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
/****** Object:  StoredProcedure [Management].[usp_CheckSettingType]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Management].[usp_CheckSettingType]
	@Module			varchar(100),
	@Key			varchar(100),
	@Value			nvarchar(4000),
	@ConvertedValue	sql_variant OUTPUT
AS
BEGIN
	DECLARE
		@Value_Type		varchar(32),
		@Is_Nullable	bit,
		@Msg			nvarchar(2048),
		@Max_Value		int,
		@Min_Value		int,
		@Int_Value		int,
		@Boolean_Value	bit,
		@Float_Value	numeric(18, 4)

	SELECT 
		@Value_Type = STT_Value_Type,
		@Is_Nullable = STT_Is_Nullable,
		@Max_Value = STT_Max_Value,
		@Min_Value = STT_Min_Value
	FROM Management.Settings_Types
	WHERE 
		STT_SET_Module = @Module
		AND STT_SET_Key = @Key

	BEGIN TRY

		IF @Value IS NULL
		BEGIN
			IF @Is_Nullable = 0
				RAISERROR('The value shouldn''t be empty', 16, 1)
		END ELSE
		BEGIN			
			IF	(@Value_Type = 'boolean' AND @Value NOT IN ('0', '1', 'False', 'True'))
				OR 	(@Value_Type IN ('int', 'float') AND ISNUMERIC(@Value) = 0)
			BEGIN
				SET @Msg = 'The type of value is incorrect. It should be '+@Value_Type
				RAISERROR(@Msg, 16, 1)
			END

			IF @Value_Type = 'int' AND CHARINDEX('.', @Value, 0) > 0
			BEGIN
				RAISERROR('Invalid setting type. You entered the float value but integer value is expected', 16, 1)
			END

			DECLARE @cValue	varchar(100)
			SET @cValue = CAST(@Value AS varchar(100))


			-- Range checking for boolean and numeric values
			IF	@Value_Type IN ('int', 'float', 'boolean') 
			BEGIN
				IF 
					(CAST(@cValue AS numeric(18,2)) < @Min_Value AND @Min_Value IS NOT NULL)
					OR (CAST(@cValue AS numeric(18,2)) > @Max_Value AND @Max_Value IS NOT NULL)
				BEGIN
					SET @Msg = 'The range of value is exceeded. The value has to be between '+ISNULL(CAST(@Min_Value AS varchar(16)), 'minus infinity')+' and '+ISNULL(CAST(@Max_Value AS varchar(16)), 'infinity')
					RAISERROR(@Msg, 16, 1)
				END
			END

			-- Integer can't be as float
			IF @Value_Type IN ('int', 'boolean') AND CHARINDEX('.', @Value, 0) > 0
			BEGIN
				SET @Msg = 'The type of value is not float. Integer value is expected.'
				RAISERROR(@Msg, 16, 1)
			END

			IF @Value_Type = 'boolean' AND @Value NOT IN ('0', '1')
			BEGIN
				SET @Msg = 'Boolean value is incorrect.'
				RAISERROR(@Msg, 16, 1)
			END

		END

		IF @Value_Type = 'int'
			SET @ConvertedValue = CAST(@Value AS int)

		IF @Value_Type = 'boolean'
			SET @ConvertedValue = CAST(@Value AS bit)

		IF @Value_Type = 'float'
			SET @ConvertedValue = CAST(@Value AS numeric(18,9))

		IF @Value_Type = 'string' OR @Value_Type IS NULL
			SET @ConvertedValue = CAST(@Value AS nvarchar(2000))

	END TRY
	BEGIN CATCH
		DECLARE @Msg2	nvarchar(2000)

		SET @Msg2 = Error_Message()

		RAISERROR(@Msg2, 16, 1)
	END CATCH
END
GO
