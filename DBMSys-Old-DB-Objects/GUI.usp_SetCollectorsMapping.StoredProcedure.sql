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
/****** Object:  StoredProcedure [GUI].[usp_SetCollectorsMapping]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_SetCollectorsMapping]
	@TTMOBCTR_List GUI.TT_MappingMobsToCollectors readonly
AS
IF EXISTS (SELECT * FROM Collect.Collectors JOIN @TTMOBCTR_List ON CTR_ID = TT_CTR_ID WHERE CTR_IsDeleted = 1)
BEGIN
	DECLARE @CTRNAME NVARCHAR(255)
	SELECT @CTRNAME = CTR_NAME FROM Collect.Collectors JOIN @TTMOBCTR_List ON CTR_ID = TT_CTR_ID WHERE CTR_IsDeleted = 1
	raiserror('The %s collector is deleted. Try again',16,1,@CTRName)
END
ELSE
	UPDATE	Inventory.MonitoredObjects
	SET		MOB_CTR_ID = TT_CTR_ID
	FROM	@TTMOBCTR_List
	WHERE	MOB_ID = TT_MOB_ID
GO
