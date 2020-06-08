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
/****** Object:  View [Tests].[VW_TST_InstanceCredential]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_InstanceCredential]
AS
	SELECT TOP 0
		CAST(null AS sysname) AS name,
		CAST(null AS nvarchar(4000)) AS credential_identity,
		CAST(null AS datetime) AS create_date,
		CAST(null AS datetime) AS modify_date,
		CAST(null AS nvarchar(100)) AS target_type,
		CAST(null AS int) AS target_id,
		CAST(null as int) AS Metadata_TRH_ID,
		CAST(null as int) AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceCredential]    Script Date: 6/8/2020 1:16:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_InstanceCredential] on [Tests].[VW_TST_InstanceCredential]
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


	MERGE Inventory.InstanceCredential AS D
	USING	(
				SELECT 
					I.name, I.credential_identity, I.create_date, I.modify_date,
					I.target_type, O.name AS target_name, @MOB_ID AS MOB_ID, I.Metadata_TRH_ID, I.Metadata_ClientID
				FROM 
					inserted AS I
					LEFT JOIN sys.Objects AS O
					ON I.Target_id = O.Object_ID
			) AS S
			ON CRD_MOB_ID = MOB_ID
				AND CRD_Name = name
	WHEN matched THEN 
		UPDATE 
		SET
			CRD_CredentialIdentity	= credential_identity,
			CRD_CreateDate			= create_date,
			CRD_ModifyDate			= modify_date,
			CRD_TargetType			= target_type,
			CRD_TargetName			= target_name,
			CRD_LastSeenDate		= @StartDate,
			CRD_Last_TRH_ID			= Metadata_TRH_ID
	WHEN not matched THEN 
		INSERT (
			CRD_MOB_ID, CRD_Name, CRD_CredentialIdentity, CRD_CreateDate, CRD_ModifyDate, 
			CRD_TargetType, CRD_TargetName, CRD_ClientID, CRD_InsertDate, CRD_LastSeenDate, CRD_Last_TRH_ID)
		VALUES (
			MOB_ID, name, credential_identity, create_date, modify_date, 
			target_type, target_name, Metadata_ClientID, @StartDate, @StartDate, Metadata_TRH_ID);

END
GO
