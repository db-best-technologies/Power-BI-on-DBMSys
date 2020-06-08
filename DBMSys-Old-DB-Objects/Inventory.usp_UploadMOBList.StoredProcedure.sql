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
/****** Object:  StoredProcedure [Inventory].[usp_UploadMOBList]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Inventory].[usp_UploadMOBList]
--DECLARE 
	@TT Inventory.TT_ImportMOB_List readonly
AS

	IF OBJECT_ID('tempdb..#List') IS NOT NULL
		DROP TABLE #List
	
	SELECT	DISTINCT
			MOL_ObjGUID					AS ObjGUID
			,MOM_MOB_ID					AS MOBID  
			,MOL_Name					AS MOBName
			,ISNULL(MOB_PLT_ID,PLT_ID)  AS PLTID
			,MOL_CTR					AS CTRID
			,MOL_ShortName				AS MOBShortName
			,MOL_IsDeleted				AS IsDeleted
	INTO	#List
	FROM	@TT
	LEFT JOIN (
				Inventory.MonitoringObectMapping 
				JOIN Inventory.MonitoredObjects ON MOM_MOB_ID = MOB_ID
			)ON MOM_ObjGUID = MOL_ObjGUID
	LEFT JOIN Management.PlatformTypes ON MOL_PLT_Name = PLT_Name
	WHERE	(MOB_ID IS NULL 
			OR
			ISNULL(MOB_Name,'') <> MOL_Name 
			OR MOL_PLT_Name <> ISNULL(PLT_Name,''))
			AND NOT EXISTS (
							SELECT 
									* 
							FROM	Inventory.MonitoredObjects mb 
							join	Management.PlatformTypes pt on mb.MOB_PLT_ID = pt.PLT_ID 
							WHERE	mb.MOB_Name = MOL_Name 
									AND pt.PLT_Name = MOL_PLT_Name
							)

		
	UPDATE	Inventory.MonitoredObjects
	SET		MOB_OOS_ID = 1
	FROM	@TT
	JOIN	Inventory.MonitoringObectMapping ON MOM_ObjGUID = MOL_ObjGUID
	WHERE	MOB_ID = MOM_MOB_ID
			AND MOB_OOS_ID = 3
			AND MOL_IsDeleted = 0

	DECLARE @sys_id INT
	DECLARE @t TABLE (id int)

	SELECT	TOP 1
			@sys_id = SYS_ID 
	FROM	Inventory.Systems
	
	IF @sys_id IS NULL
	BEGIN
		INSERT INTO Inventory.Systems(Sys_Name)
		OUTPUT	Inserted.SYS_ID INTO @t(id)
		VALUES('Default System')

		SELECT @sys_id = id from @t
	END
	
	declare
			@SHS_ID				int	
			,@SHS_Name			nvarchar(255)	
			,@SHS_ShortName		nvarchar(255)	
			,@PLT_ID			int				
			,@SLG_ID			int				= NULL	
			,@CTR_ID			INT				
			,@ObjGUID			NVARCHAR(255)	

	declare cObjects cursor static forward_only for
		SELECT 
				MOBID
				,MOBName
				,PLTID
				,ObjGUID
				,CTRID
				,ISNULL(MOBShortName,MOBName)
		FROM	#List
		WHERE	PLTID IS NOT NULL
		--WHERE	IsDeleted = 0

	open cObjects
	fetch next from cObjects into @SHS_ID,@SHS_Name,@PLT_ID,@ObjGUID,@CTR_ID,@SHS_ShortName
	while @@fetch_status = 0
	begin

		IF @SHS_ID IS NULL
		BEGIN
			EXEC GUI.usp_Add_SystemHost
				@SHS_ID	OUT
				,@SHS_Name			
				,@SHS_ShortName
				,@SYS_ID			
				,@PLT_ID			
				,@SLG_ID			
				,@CTR_ID	
			
			IF @SHS_ID IS NOT NULL
				INSERT INTO Inventory.MonitoringObectMapping(MOM_MOB_ID,MOM_ObjGUID)
				VALUES (@SHS_ID,@ObjGUID)
		END	
		ELSE
			EXEC GUI.usp_Edit_SystemHost
				 @SHS_ID			
				,@SHS_Name			
				,@SHS_ShortName			
				,@PLT_ID			
				,@SYS_ID			
				,@SLG_ID			
				,@CTR_ID			


		fetch next from cObjects into @SHS_ID,@SHS_Name,@PLT_ID,@ObjGUID,@CTR_ID,@SHS_ShortName
	end
	close cObjects
	deallocate cObjects


	;with oldMOB as 
	(
		SELECT
				MOB_ID			AS MOBID
				,MOL_ObjGUID	AS MOLObjGuid
		FROM	@TT tt
		JOIN	Management.PlatformTypes ON MOL_PLT_Name = PLT_Name
		JOIN	Inventory.MonitoredObjects ON PLT_ID = MOB_PLT_ID AND MOL_Name = MOB_Name
		WHERE	NOT EXISTS (SELECT * FROM Inventory.MonitoringObectMapping WHERE MOM_ObjGUID = MOL_ObjGUID)
				AND CAST(MOB_ID AS nvarchar(255)) <>  MOL_ObjGUID
				AND MOL_IsDeleted = 0
	)

	INSERT INTO Inventory.MonitoringObectMapping(MOM_MOB_ID,MOM_ObjGUID)
	SELECT 
			MOBID
			,MOLObjGuid 
	FROM	oldMOB

	;with MOB_Del as 
	(
		SELECT
				MOB_ID AS MOBID
		FROM	@TT
		JOIN	Inventory.MonitoringObectMapping ON MOM_ObjGUID = MOL_ObjGUID
		JOIN	Inventory.MonitoredObjects ON MOM_MOB_ID = MOB_ID
		JOIN	Management.PlatformTypes ON MOL_PLT_Name = PLT_Name
		WHERE	MOL_IsDeleted = 1
	)
	UPDATE Inventory.MonitoredObjects SET MOB_OOS_ID = 3 WHERE EXISTS (SELECT * FROM MOB_Del WHERE MOBID = MOB_ID)
GO
