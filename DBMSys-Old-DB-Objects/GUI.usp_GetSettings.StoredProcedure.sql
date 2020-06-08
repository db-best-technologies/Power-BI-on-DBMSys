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
/****** Object:  StoredProcedure [GUI].[usp_GetSettings]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetSettings]
--DECLARE
	@MODULE		NVARCHAR(4000) = NULL
AS
SELECT 
		SET_Module SettingModule
		, SET_Key SettingKey
		, SET_Description SettingDescription
		, SET_Value SettingValue
		, SQL_VARIANT_PROPERTY(SET_Value, 'BaseType') SettingValueDateType
FROM	Management.Settings
WHERE	EXISTS (SELECT TOP 1 1 FROM Infra.fn_SplitString(@MODULE,';')f where f.Val = SET_Module) OR @MODULE IS NULL
GO
