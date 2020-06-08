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
/****** Object:  View [Tests].[VW_TST_Standby_Database_Check]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_Standby_Database_Check]
AS
	SELECT TOP 0
		CAST(NULL AS nvarchar(255)) AS Warning_Message,
		CAST(NULL AS int) AS Metadata_TRH_ID,
		CAST(NULL AS int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_Standby_Database_Check]    Script Date: 6/8/2020 1:16:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_Standby_Database_Check] on [Tests].[VW_TST_Standby_Database_Check]
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE 
		@MOB_ID		int,
		@StartDate	datetime2(3)

	SELECT TOP 1
		@MOB_ID = H.TRH_MOB_ID,
		@StartDate = H.TRH_StartDate
	FROM 
		inserted AS I
		INNER JOIN Collect.TestRunHistory AS H 
			ON I.Metadata_TRH_ID = H.TRH_ID

	INSERT INTO [Inventory].[Standby_Database_Check] (
		STC_Client_ID, STC_MOB_ID, STC_Warning_Message, STC_InsertDate, STC_LastSeenDate, STC_Last_TRH_ID)
	SELECT
		Metadata_ClientID, @MOB_ID, Warning_Message, @StartDate, @StartDate, Metadata_TRH_ID
	FROM
		inserted
		
END
GO
