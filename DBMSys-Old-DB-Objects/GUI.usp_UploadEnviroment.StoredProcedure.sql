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
/****** Object:  StoredProcedure [GUI].[usp_UploadEnviroment]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_UploadEnviroment]
--DECLARE 
		@TT			GUI.TT_ImportMonitoredObjects	READONLY
		,@SYSCNT	INT								OUTPUT
		,@MOBCNT	INT								OUTPUT
		,@LGCNT		INT								OUTPUT
		,@CTRCNT	INT								OUTPUT
		,@ISCSV		BIT = 1

/*select * from @TT
--***************************************************************************************************************************************
INSERT INTO @TT
select				'Test1',NULL,	'Test 1.1',	'Test 1.1',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1
union all select	'Test1',NULL,	'Test 1.2',	'Test 1.2',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1
union all select	'Test1',NULL,	'Test 1.3',	'Test 1.3',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1
union all select	'Test1',NULL,	'Test 1.4',	'Test 1.4',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1
union all select	'Test2',NULL,	'Test 1.5',	'Test 1.5',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1
union all select	'Test2',NULL,	'Test 1.6',	'Test 1.6',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1
union all select	'Test2',NULL,	'Test 1.7',	'Test 1.7',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1
union all select	'Test2',NULL,	'Test 1.8',	'Test 1.8',	'Microsoft SQL Server',	'sklyarov.e@dbbest.com',NULL,NULL,NULL,1

--select * from @TT
*/
--***************************************************************************************************************************************
AS

SET @CTRCNT = 0
SET @SYSCNT = 0
SET @MOBCNT = 0
SET @LGCNT  = 0


if OBJECT_ID('tempdb..#TT') is not null
	drop table #TT


CREATE TABLE #TT
(
		SYSTEM_ID			INT
		,System_Name		NVARCHAR(255)
		,System_Descr		NVARCHAR(255)
		,SHS_MOB_ID			INT
		,HostName			NVARCHAR(255)
		,Short_HostName		NVARCHAR(255)
		,PLTID				INT
		,Host_Type			NVARCHAR(255)
		,LOGIN_ID			INT
		,SYL_Login			NVARCHAR(255)
		,SYL_Description	nvarchar(255) NULL
		,SYL_Password		nvarchar(255) NULL
		,SYL_IsDefault		bit NULL
		,SYL_LGY_ID			tinyint NULL
		,CTRNAME			NVARCHAR(255)
		,CTRDescr			NVARCHAR(max)
		,CTRID				INT
)

BEGIN TRY
	BEGIN TRAN

		INSERT INTO #TT
		SELECT NULL,System_Name,System_Descr,NULL,HostName,Short_HostName,NULL,Host_Type,NULL,SYL_Login,SYL_Description,SYL_Password,SYL_IsDefault,SYL_LGY_ID,CLTR_Name,CLTR_Descr,NULL FROM @TT

		IF @ISCSV = 0
		BEGIN
			UPDATE t SET LOGIN_ID = sl.SLG_ID FROM #TT t join syl.SecureLogins sl ON t.SYL_Login = sl.SLG_Login and SLG_LGY_ID = SYL_LGY_ID

			DECLARE
					@SLG_ID				INT 					= null
					,@SLG_DESCRIPTION	NVARCHAR(255)			
					,@SLG_LOGIN			NVARCHAR(50)			
					,@SLG_PASSWORD		NVARCHAR(50)			
					,@SLG_ISDEFAULT		BIT						= 0
					,@SLG_LGY_ID		INT						
			
			declare cLogin cursor static forward_only for
				SELECT	DISTINCT
						LOGIN_ID		
						,SYL_Login		
						,SYL_Description
						,SYL_Password	
						,SYL_IsDefault	
						,SYL_LGY_ID		
				FROM	#TT
				WHERE	LOGIN_ID IS NULL
						and SYL_Password IS NOT NULL

			open cLogin

			fetch next from cLogin into @SLG_ID,@SLG_LOGIN,@SLG_DESCRIPTION,@SLG_PASSWORD,@SLG_ISDEFAULT,@SLG_LGY_ID --@Description,@Login,@Password,@IsDefault	

			while @@FETCH_STATUS = 0
			begin

				EXEC GUI.usp_Add_Predefined_Credential @SLG_ID OUT,@SLG_DESCRIPTION,@SLG_LOGIN,@SLG_PASSWORD,@SLG_ISDEFAULT,@SLG_LGY_ID

				UPDATE #TT set LOGIN_ID = @SLG_ID WHERE SYL_Login = @SLG_LOGIN AND ISNULL(@SLG_LGY_ID,0) = ISNULL(SYL_LGY_ID,0)

				SET @LGCNT += 1
		
				fetch next from cLogin into @SLG_ID,@SLG_LOGIN,@SLG_DESCRIPTION,@SLG_PASSWORD,@SLG_ISDEFAULT,@SLG_LGY_ID
			end

			close cLogin
			deallocate cLogin

		END

		--***************************************************************************************************************************************
		--	Updated ID for existing items
		--***************************************************************************************************************************************
		update t set CTRID = CTR_ID, CTRDescr = CTR_Description from #TT t join Collect.Collectors cl on t.CTRNAME = cl.CTR_Name and CTR_IsDeleted = 0

		update t set SYSTEM_ID = SYS_ID, System_Descr = SYS_Description from #TT t join Inventory.Systems s on t.System_Name = s.SYS_Name

		update t set PLTID = PLT_ID from #TT t join Management.PlatformTypes pt on t.Host_Type = pt.PLT_Name

		update t set SHS_MOB_ID = MOB_ID from #TT t join Inventory.MonitoredObjects o on t.HostName = o.MOB_Name and t.PLTID = o.MOB_PLT_ID

		IF @ISCSV = 1
			UPDATE t SET LOGIN_ID = sl.SLG_ID FROM #TT t join syl.SecureLogins sl ON t.SYL_Login = sl.SLG_Login --and SLG_LGY_ID = SYL_LGY_ID

		

		--select * from #TT
		--***************************************************************************************************************************************
		--	Add not existing COLLECTORS
		--***************************************************************************************************************************************
		DECLARE 
				@CTR_ID		INT
				,@CTR_NAME	NVARCHAR(255)
				,@CTR_Descr	NVARCHAR(255)

		declare cCollector cursor static forward_only for
			SELECT	DISTINCT
					NULL
					,CTRNAME
					,CTRDescr
			FROM	#TT
			WHERE	CTRID IS NULL AND CTRNAME IS NOT NULL

		open cCollector

		fetch next from cCollector into @CTR_ID,@CTR_NAME,@CTR_Descr

		while @@FETCH_STATUS = 0
		begin

			EXEC GUI.usp_Add_Collector @CTR_ID out,@CTR_NAME,@CTR_Descr

			UPDATE #TT set CTRID = @CTR_ID WHERE CTRNAME = @CTR_NAME and isnull(CTRDescr,'') = isnull(@CTR_Descr,'')
			
			SET @CTRCNT += 1
		
			fetch next from cCollector into @CTR_ID,@CTR_NAME,@CTR_Descr
		end

		close cCollector
		deallocate cCollector


		--***************************************************************************************************************************************
		--	Add not existing SYSTEMS
		--***************************************************************************************************************************************
		DECLARE 
				@SYS_ID		INT
				,@SYS_NAME	NVARCHAR(255)
				,@SYS_Descr	NVARCHAR(255)

		declare cSystem cursor static forward_only for
			SELECT	DISTINCT
					NULL
					,System_Name
					,System_Descr
			FROM	#TT
			WHERE	SYSTEM_ID IS NULL

		open cSystem

		fetch next from cSystem into @SYS_ID,@SYS_NAME,@SYS_Descr

		while @@FETCH_STATUS = 0
		begin

			EXEC GUI.usp_Add_System @SYS_ID out,@SYS_NAME,@SYS_Descr

			UPDATE #TT set SYSTEM_ID = @SYS_ID WHERE System_Name = @SYS_NAME and isnull(System_Descr,'') = isnull(@SYS_Descr,'')

			SET @SYSCNT += 1
		
			fetch next from cSystem into @SYS_ID,@SYS_NAME,@SYS_Descr
		end

		close cSystem
		deallocate cSystem


		--select * from #TT
		--***************************************************************************************************************************************
		--	Add not existing MONITORED OBJECTS
		--***************************************************************************************************************************************

		UPDATE Inventory.MonitoredObjects set MOB_OOS_ID = 1 where exists (select * from #TT WHERE SHS_MOB_ID  = MOB_ID)

		UPDATE s SET s.SHS_SYS_ID = t.SYSTEM_ID FROM Inventory.SystemHosts s join #TT t on s.SHS_MOB_ID = t.SHS_MOB_ID WHERE t.SHS_MOB_ID IS NOT NULL

		INSERT INTO Inventory.SystemHosts(SHS_SYS_ID,SHS_MOB_ID,SHS_ShortName)
		SELECT SYSTEM_ID,SHS_MOB_ID,Short_HostName FROM #TT t
		WHERE NOT EXISTS (SELECT * FROM Inventory.SystemHosts h WHERE t.SYSTEM_ID = h.SHS_SYS_ID and t.SHS_MOB_ID = h.SHS_MOB_ID)

		DECLARE 
				@SHS_ID				int  
				,@SHS_Name			nvarchar(100)	
				,@SHS_ShortName		nvarchar(100)	
				,@PLT_ID			int					
				--,@SLG_ID			int	

		declare cMOB cursor static forward_only for
			SELECT	DISTINCT
					SHS_MOB_ID
					,HostName
					,Short_HostName
					,SYSTEM_ID
					,PLTID
					,LOGIN_ID
					,CTRID
			FROM	#TT
			WHERE	SHS_MOB_ID IS NULL

		open cMOB

		fetch next from cMOB into @SHS_ID,@SHS_Name,@SHS_ShortName,@SYS_ID,@PLT_ID,@SLG_ID,@CTR_ID		

		while @@FETCH_STATUS = 0
		begin

			EXEC GUI.usp_Add_SystemHost	@SHS_ID OUT,@SHS_Name,@SHS_ShortName,@SYS_ID,@PLT_ID,@SLG_ID,@CTR_ID			

			UPDATE #TT set SHS_MOB_ID = @SHS_ID WHERE HostName = @SHS_Name and PLTID = @PLT_ID

			SET @MOBCNT += 1
		
			fetch next from cMOB into @SHS_ID,@SHS_Name,@SHS_ShortName,@SYS_ID,@PLT_ID,@SLG_ID,@CTR_ID		
		end

		close cMOB
		deallocate cMOB

	COMMIT TRAN

END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
END CATCH
GO
