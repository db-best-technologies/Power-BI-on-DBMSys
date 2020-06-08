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
/****** Object:  StoredProcedure [GUI].[usp_AddNewMaintenanceWindows]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_AddNewMaintenanceWindows]
--DECLARE 
		@Sd				DATETIMEOFFSET				--	= '20161221 12:00:00'
		,@Ed			DATETIMEOFFSET				--	= '20161221 15:00:00'
		,@Descr			NVARCHAR(1000)				--	= 'Test'
		,@MOB_ID_List	Inventory.SystemHosts_List	readonly
		,@MWG_ID		INT OUT
AS

BEGIN TRY

		BEGIN TRAN 

			declare 
					@MOB_ID_ARR Inventory.SystemHosts_List

			declare	@out table (id int)
		


			if exists (select * from @MOB_ID_List)
				insert into @MOB_ID_ARR(SHS_MOB_ID)
				select SHS_MOB_ID from @MOB_ID_List
			else
				insert into @MOB_ID_ARR(SHS_MOB_ID)
				select MOB_ID from Inventory.MonitoredObjects where MOB_OOS_ID in (0,1,2)
			
			INSERT INTO Operational.MaintenanceWindowGroups
			output inserted.MWG_ID into @out(id)
			SELECT @Sd,@Ed,@Descr

			
			INSERT INTO Operational.MaintenanceWindows(MTW_MOB_ID,MTW_MWG_ID)
			SELECT 
					SHS_MOB_ID
					,id
			FROM	@MOB_ID_ARR,@out
			
			SELECT @MWG_ID = id from @out

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
GO
