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
/****** Object:  View [Tests].[VW_TST_AvailabilityGroupHealth]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_AvailabilityGroupHealth]
AS
	SELECT 
			CAST(NULL AS DATETIME)				AS LastHardenedLSN 
			,CAST(NULL AS UNIQUEIDENTIFIER)		AS GROUPID
			,CAST(NULL AS UNIQUEIDENTIFIER)		AS ReplicaID
			,CAST(NULL AS UNIQUEIDENTIFIER)		AS GroupDBID
			,CAST(NULL AS NVARCHAR(255))		AS ReplicaName			
			,CAST(NULL AS NVARCHAR(255))		AS DatabaseName			
			,CAST(NULL AS TINYINT)				AS ReplicaRole	
			,CAST(NULL AS NVARCHAR(255))		AS ReplicaRoleDesc		
			,CAST(NULL AS NVARCHAR(4000))		AS SyncStateDesc
			,CAST(NULL AS BIT)					AS IsLocal
			,CAST(NULL AS BIT)					AS IsPrimaryReplica 
			,CAST(NULL AS TINYINT)				AS SyncState
			,CAST(NULL AS NVARCHAR(4000))		AS SyncHealthDesc
			,CAST(NULL AS DATETIME)				AS LastHardenedTime
			,CAST(NULL AS DATETIME)				AS LastRedoneTime
			,CAST(NULL AS BIGINT)				AS LogSendQueueSize
			,CAST(NULL AS BIGINT)				AS LogSendRate
			,CAST(NULL AS BIGINT)				AS RedoQueueSize
			,CAST(NULL AS BIGINT)				AS RedoRate
			,CAST(NULL AS BIGINT)				AS FilestreamSendRate
			,CAST(NULL AS NUMERIC(25,0))		AS LastLSN
			,CAST(null as int)					AS Metadata_TRH_ID
			,CAST(null as int)					AS Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AvailabilityGroupHealth]    Script Date: 6/8/2020 1:15:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_AvailabilityGroupHealth] on [Tests].[VW_TST_AvailabilityGroupHealth]
	INSTEAD OF INSERT
AS
	DECLARE 
			@MOBID			INT
			,@LastSeenDate	DATETIME

	SELECT
			@MOBID			= TRH_MOB_ID
			,@LastSeenDate	= TRH_StartDate
	FROM	inserted i
	JOIN	Collect.TestRunHistory ON Metadata_TRH_ID = TRH_ID

	;WITH AGH AS 
	(
		SELECT 
				*
		FROM	Inventory.AvailabilityGroupHealth
		WHERE	AGH_MOB_ID = @MOBID
					
	)
	MERGE	AGH--Inventory.AvailabilityGroupHealth
	USING	(
				SELECT
						IIF(LastHardenedLSN<'19000101','19000101',LastHardenedLSN) AS LastHardenedLSN
						,GROUPID
						,ReplicaID
						,GroupDBID
						,ReplicaName	
						,DatabaseName	
						,ReplicaRole	
						,ReplicaRoleDesc
						,SyncStateDesc
						,IsLocal
						,IsPrimaryReplica 
						,SyncState
						,SyncHealthDesc
						,LastHardenedTime
						,LastRedoneTime
						,LogSendQueueSize
						,LogSendRate
						,RedoQueueSize
						,RedoRate
						,FilestreamSendRate
						,LastLSN
						,Metadata_TRH_ID
						,Metadata_ClientID
				FROM	inserted
				
			)ins ON AGH_MOB_ID = @MOBID
					AND ins.GroupID		= AGH_GroupID
					AND ins.ReplicaID	= AGH_ReplicaID
					AND ins.GroupDBID	= AGH_GroupDBID
	WHEN MATCHED THEN
		UPDATE	
		SET		
				AGH_LastHardenedLSN			= LastHardenedLSN		
				,AGH_GroupDBID				= GroupDBID
				,AGH_ReplicaName			= ReplicaName	
				,AGH_DatabaseName			= DatabaseName	
				,AGH_ReplicaRole			= ReplicaRole	
				,AGH_ReplicaRoleDesc		= ReplicaRoleDesc
				,AGH_SyncStateDesc			= SyncStateDesc			
				,AGH_IsLocal				= IsLocal				
				,AGH_SyncState				= SyncState				
				,AGH_SyncHealthDesc			= SyncHealthDesc			
				,AGH_LastHardenedTime		= LastHardenedTime		
				,AGH_LastRedoneTime			= LastRedoneTime			
				,AGH_LogSendQueueSize		= LogSendQueueSize		
				,AGH_LogSendRate			= LogSendRate			
				,AGH_RedoQueueSize			= RedoQueueSize			
				,AGH_RedoRate				= RedoRate				
				,AGH_FilestreamSendRate		= FilestreamSendRate		
				,AGH_LastSeenDate			= @LastSeenDate	
				,AGH_LastLSN				= LastLSN		
				,AGH_Last_TRH_ID			= Metadata_TRH_ID
				,AGH_IsDeleted				= 0
	WHEN NOT MATCHED THEN
		INSERT 	(AGH_ClientID,AGH_MOB_ID,AGH_LastHardenedLSN,AGH_GroupID,AGH_ReplicaID,AGH_GroupDBID,AGH_ReplicaName,AGH_DatabaseName,AGH_ReplicaRole,AGH_ReplicaRoleDesc,AGH_SyncStateDesc,AGH_IsLocal,AGH_SyncState
				,AGH_SyncHealthDesc,AGH_LastHardenedTime,AGH_LastRedoneTime,AGH_LogSendQueueSize,AGH_LogSendRate,AGH_RedoQueueSize,AGH_RedoRate,AGH_FilestreamSendRate,AGH_LastSeenDate,AGH_Last_TRH_ID,AGH_LastLSN)		
		VALUES (Metadata_ClientID,@MOBID,LastHardenedLSN,GroupID,ReplicaID,GroupDBID,ReplicaName,DatabaseName,ReplicaRole,ReplicaRoleDesc,SyncStateDesc,IsLocal,SyncState
				,SyncHealthDesc,LastHardenedTime,LastRedoneTime,LogSendQueueSize,LogSendRate,RedoQueueSize,RedoRate,FilestreamSendRate,@LastSeenDate,Metadata_TRH_ID,LastLSN)
	WHEN NOT MATCHED BY SOURCE THEN
		UPDATE	
		SET		AGH_IsDeleted = 1;
GO
