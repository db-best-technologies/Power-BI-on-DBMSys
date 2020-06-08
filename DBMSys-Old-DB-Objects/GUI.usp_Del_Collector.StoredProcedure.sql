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
/****** Object:  StoredProcedure [GUI].[usp_Del_Collector]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Del_Collector]
--DECLARE
	@CTR_ID				INT
AS
	IF EXISTS (SELECT * FROM Collect.Collectors WHERE CTR_ID = @CTR_ID)
	BEGIN
		UPDATE	Inventory.MonitoredObjects 
		SET		MOB_CTR_ID = NULL
		WHERE	MOB_CTR_ID = @CTR_ID

		UPDATE	Collect.Collectors
		SET		CTR_IsDeleted = 1
		WHERE	CTR_ID = @CTR_ID
	END
	ELSE
		raiserror('Collector with Id as %s does not exists', 16, 1, @CTR_ID)
GO
