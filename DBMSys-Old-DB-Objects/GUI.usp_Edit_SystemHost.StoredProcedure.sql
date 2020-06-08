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
/****** Object:  StoredProcedure [GUI].[usp_Edit_SystemHost]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Edit_SystemHost]
--declare
	 @MOB_ID			int				  --
	,@SHS_Name			nvarchar(100)	  --
	,@SHS_ShortName		nvarchar(100)	  --
    ,@PLT_ID			int				  --
    ,@SYS_ID			int				  --
    ,@SLG_ID			int				  --
	,@CTR_ID			INT					= NULL
    
as
set nocount on;
--SET XACT_ABORT ON;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;


IF EXISTS (SELECT * FROM Collect.Collectors WHERE CTR_ID = @CTR_ID AND CTR_IsDeleted = 1)
BEGIN
	DECLARE @CTRNAME NVARCHAR(255)
	SELECT @CTRNAME = CTR_NAME FROM Collect.Collectors WHERE CTR_ID = @CTR_ID
	raiserror('Collector with name as %s is deleted already', 16, 1, @CTRName)
END
ELSE
BEGIN	

	declare 
		@msg NVARCHAR(2048)
		,@SSHS_Name			NVARCHAR(100)	
		,@SSHS_ShortName	NVARCHAR(100)	
		,@SPLT_ID			INT				
		,@SSYS_ID			INT				
		,@SSLG_ID			INT		
		,@SPLC_ID			INT


	SELECT 
			@SSHS_Name			= MOB_Name
			,@SSHS_ShortName	= SHS_ShortName
			,@SPLT_ID			= MOB_PLT_ID
			,@SSYS_ID			= SHS_SYS_ID
			,@SSLG_ID			= MOB_SLG_ID
			,@SPLC_ID			= PLT_PLC_ID
			--,@CTR_ID			= MOB_CTR_ID
	FROM	Inventory.MonitoredObjects
	join	Inventory.SystemHosts on MOB_ID = SHS_MOB_ID
	join	Management.PlatformTypes on MOB_PLT_ID = PLT_ID
	WHERE	MOB_ID = @MOB_ID	



	/*IF @SPLC_ID = 1 AND @SHS_Name <> @SSHS_Name
	BEGIN
		Raiserror('Can only rename OS servers',16,1)
	END	
	ELSE*/
		IF @PLT_ID <> @SPLT_ID ---PLC_ID
			Raiserror('Can''t change Platform for Monitored Object',16,1)
		ELSE
			IF EXISTS(select 1 from Inventory.MonitoredObjects where MOB_ID = @MOB_ID)
			begin
				BEGIN TRY

				BEGIN TRAN 

					DECLARE 
						@DFOID		INT
						,@OSSID		INT = NULL
						,@MOBIDNew	INT = NULL

					if exists (select * from Inventory.MonitoredObjects where MOB_ID = @MOB_ID and MOB_PLT_ID = 2)
						select 
								@DFOId = DFO_ID
								,@OSSID = ISNULL(OSS_ID,MOB_Entity_ID)
						from	Inventory.MonitoredObjects mob
						join	Management.DefinedObjects dfo on MOB_Name = DFO_Name and DFO_PLT_ID = 2
						LEFT JOIN Inventory.OSServers ON MOB_ID = OSS_MOB_ID
						where	MOB_ID = @MOB_ID

					else
						select 
								@DFOId = MOB_Entity_ID
						from	Inventory.MonitoredObjects mob
						where	MOB_ID = @MOB_ID

					select @DFOID as DFO_ID, @OSSID as OSS_ID


			/***********************************************************************************/
					IF @SHS_Name = @SSHS_Name AND @PLT_ID = @SPLT_ID
					BEGIN
						 update Inventory.SystemHosts
						 set 
           
							   SHS_ShortName	= @SHS_ShortName
							   ,SHS_SYS_ID		= @SYS_ID
						 where	Inventory.SystemHosts.SHS_MOB_ID = @MOB_ID
								and 
								(	SHS_ShortName <> @SHS_ShortName
									OR SHS_SYS_ID <> @SYS_ID
								)
					
						update Management.DefinedObjects set DFO_SLG_ID = @SLG_ID where DFO_ID = @DFOID

					END

					IF /*@SPLC_ID = 2 AND*/ @SHS_Name <> @SSHS_Name 
					BEGIN
									
						update Inventory.MonitoredObjects
						set MOB_Name = @SHS_Name
						where MOB_ID = @MOB_ID

						update Inventory.MonitoredObjects
						set MOB_Name = stuff(MOB_Name, 1, len(@SSHS_Name), @SHS_Name)
						where exists (select *
							from Inventory.ParentChildRelationships
							where PCR_Parent_MOB_ID = @MOB_ID
							 and PCR_Child_MOB_ID = MOB_ID
							 and PCR_IsCurrentParent = 1)
						 and MOB_Name + '\' like @SSHS_Name + '\%'
					END

					update Inventory.MonitoredObjects set MOB_SLG_ID = @SLG_ID,MOB_CTR_ID = @CTR_ID WHERE MOB_ID = @MOB_ID

					--update Inventory.MonitoredObjects set MOB_CTR_ID = @CTR_ID WHERE MOB_ID = @MOB_ID

					COMMIT TRAN

				END TRY
				BEGIN CATCH
					IF @@TRANCOUNT > 0
						ROLLBACK;
					THROW;
				END CATCH
			END
END
GO
