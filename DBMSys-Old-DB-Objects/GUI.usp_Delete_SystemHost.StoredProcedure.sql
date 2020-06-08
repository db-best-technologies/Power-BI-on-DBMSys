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
/****** Object:  StoredProcedure [GUI].[usp_Delete_SystemHost]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Delete_SystemHost] 
	@MOB_ID_List	[GUI].[tblMob] READONLY
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY

		UPDATE MO
		SET MOB_OOS_ID = 3
		FROM
			Inventory.MonitoredObjects AS MO
			INNER JOIN @MOB_ID_List AS ML
			ON MO.MOB_ID = ML.MOB_ID

	END TRY
	BEGIN CATCH
		DECLARE 
			@MOBName nvarchar(max) = (
				SELECT MO.MOB_Name+', ' AS [data()] 
				FROM 
					Inventory.MonitoredObjects AS MO
					INNER JOIN @MOB_ID_List AS ML
					ON MO.MOB_ID = ML.MOB_ID
				FOR XML PATH(''));

		DECLARE 
			@msg nvarchar(max) = formatmessage(51006,  @MOBName);
	
		THROW 51006, @msg, 1;

	END CATCH
END
GO
