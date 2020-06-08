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
/****** Object:  View [Tests].[VW_TST_SessionCounts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_SessionCounts]
AS
	SELECT TOP 0
		CAST(null as int) AS Inst_ID,
		CAST(null as int) AS Active,
		CAST(null as int) AS Killed,
		CAST(null as int) AS Total,
		CAST(null as int) AS db_max_sessions,
		CAST(null as numeric(9,2)) AS pct_used,
		CAST(null as int) AS Metadata_TRH_ID,
		CAST(null as int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SessionCounts]    Script Date: 6/8/2020 1:16:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_SessionCounts] on [Tests].[VW_TST_SessionCounts]
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

	INSERT INTO [Inventory].[SessionCounts] (
		SSC_Client_ID, SSC_MOB_ID, SSC_Inst_ID, SSC_Active, SSC_Killed, SSC_Total, SSC_db_max_sessions,
		SSC_pct_used, SSC_InsertDate, SSC_LastSeenDate, SSC_Last_TRH_ID)
	SELECT
		Metadata_ClientID, @MOB_ID, Inst_ID, Active, Killed, Total, db_max_sessions,
		pct_used, @StartDate, @StartDate, Metadata_TRH_ID
	FROM
		inserted
		
END
GO
