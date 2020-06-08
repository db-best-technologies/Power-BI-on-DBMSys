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
/****** Object:  View [Tests].[VW_TST_Oracle_Objects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_Oracle_Objects]
AS
	SELECT TOP 0
		CAST(NULL AS nvarchar(255)) AS [Schema],
		CAST(NULL AS nvarchar(255)) AS [Object_Name],
		CAST(NULL AS datetime2(3)) AS CreateDate,
		CAST(NULL AS datetime2(3)) AS Last_Upd_Date,
		CAST(NULL AS nvarchar(63)) AS [Status],
		CAST(NULL AS nvarchar(63)) AS Object_Type,
		CAST(NULL AS nchar(1)) AS Temporary,
		CAST(NULL AS nchar(1)) AS [Generated],
		CAST(NULL AS nchar(1)) AS [Secondary],
		CAST(NULL AS int) AS Lines_Chars_Count,
		CAST(NULL AS nchar(1)) AS IsWrapped,
		CAST(NULL AS nchar(1)) AS IsCharCount,
		CAST(NULL AS int) AS Metadata_TRH_ID,
		CAST(NULL AS int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_Oracle_Objects]    Script Date: 6/8/2020 1:16:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_Oracle_Objects] on [Tests].[VW_TST_Oracle_Objects]
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

	-- Deleting the old data
	DELETE D 
	FROM 
		[Inventory].[Oracle_Objects] AS D 
		INNER JOIN inserted AS i
		ON D.OPC_Client_ID = i.Metadata_ClientID
		AND D.OPC_MOB_ID = @MOB_ID

	-- Update references
	merge [Inventory].[Oracle_Object_Types]
	using 
		(
			select distinct Object_Type
			from inserted
		) AS S 
		ON OOT_Name = S.Object_Type
	when not matched then insert(OOT_Name)
							values(Object_Type);

	merge [Inventory].[Oracle_Type_Statuses]
	using 
		(
			select distinct [Status]
			from inserted
		) AS S 
		ON TPS_Name = S.[Status]
	when not matched then insert(TPS_Name)
							values([Status]);

	INSERT INTO [Inventory].[Oracle_Objects] (
		OPC_Client_ID, OPC_MOB_ID, 
		OPC_Schema, OPC_Object_Name, OPC_OOT_ID, OPC_CreateDate, OPC_Last_Upd_Date, OPC_TPS_ID,
		OPC_Temporary, OPC_Generated, OPC_Secondary, OPC_Lines_Chars_Count, OPC_IsWrapped, OPC_IsCharCount,
		OPC_InsertDate, OPC_LastSeenDate, OPC_Last_TRH_ID)
	SELECT
		Metadata_ClientID, @MOB_ID,
		i.[Schema], i.[Object_Name], OT.OOT_ID, i.CreateDate, i.Last_Upd_Date, TS.TPS_ID,
		CASE WHEN i.Temporary = 'N' THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END AS Temporary,
		CASE WHEN i.[Generated] = 'N' THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END AS [Generated],
		CASE WHEN i.[Secondary] = 'N' THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END AS [Secondary],
		i.Lines_Chars_Count, 
		CASE WHEN i.IsWrapped = 'N' THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END AS IsWrapped,
		CASE WHEN i.IsCharCount = 'N' THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END AS [IsCharCount],
		@StartDate, @StartDate, Metadata_TRH_ID
	FROM
		inserted AS i
		INNER JOIN [Inventory].[Oracle_Object_Types] AS OT
		ON i.Object_Type = OT.OOT_Name
		INNER JOIN [Inventory].[Oracle_Type_Statuses] AS TS
		ON i.[Status] = TS.TPS_Name
		
END
GO
