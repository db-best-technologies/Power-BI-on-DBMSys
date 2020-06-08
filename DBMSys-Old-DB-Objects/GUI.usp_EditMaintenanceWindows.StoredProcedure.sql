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
/****** Object:  StoredProcedure [GUI].[usp_EditMaintenanceWindows]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_EditMaintenanceWindows]
--DECLARE 
		@MWG_ID			INT							--= 2
		,@SD			DATETIMEOFFSET				--= '2016-11-11 16:04:32'
		,@ED			DATETIMEOFFSET				--= '2016-12-12 16:20:32'
		,@Descr			NVARCHAR(1000)				--= 'test descr'
		,@MOB_ID_List	Inventory.SystemHosts_List	readonly
AS
BEGIN TRY

		BEGIN TRAN 

			UPDATE	Operational.MaintenanceWindowGroups
			SET		MWG_StartTime		= @SD
					,MWG_EndTime		= @ED
					,MWG_Description	= @Descr
			WHERE	MWG_ID = @MWG_ID

			; WITH  mtw AS 
			(
				SELECT 
						* 
				FROM	Operational.MaintenanceWindows 
				WHERE	MTW_MWG_ID = @MWG_ID
			)

			UPDATE	Operational.MaintenanceWindows
			SET		MTW_IsDeleted = 1
			WHERE	MTW_ID IN (
								SELECT 
										MTW_ID
								FROM	mtw w
								Left JOIN	@MOB_ID_List l on w.MTW_MOB_ID = l.SHS_MOB_ID --and w.MTW_MWG_ID = @MWG_ID
								WHERE	SHS_MOB_ID IS NULL
							  )

			UPDATE	Operational.MaintenanceWindows
			SET		MTW_IsDeleted = 0
			WHERE	MTW_ID IN (
								SELECT 
										MTW_ID
								FROM	(SELECT * FROM	Operational.MaintenanceWindows WHERE	MTW_MWG_ID = @MWG_ID) w
								JOIN	@MOB_ID_List l on w.MTW_MOB_ID = l.SHS_MOB_ID --and w.MTW_MWG_ID = @MWG_ID
								WHERE	w.MTW_IsDeleted = 1
											
							  )

			INSERT INTO Operational.MaintenanceWindows
			SELECT 
					SHS_MOB_ID
					,0
					,@MWG_ID
			FROM	@MOB_ID_List 
			WHERE	NOT EXISTS (
									SELECT * FROM Operational.MaintenanceWindows WHERE MTW_MOB_ID = SHS_MOB_ID and MTW_MWG_ID = @MWG_ID
								)
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
GO
