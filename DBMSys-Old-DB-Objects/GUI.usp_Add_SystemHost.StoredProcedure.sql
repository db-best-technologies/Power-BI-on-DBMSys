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
/****** Object:  StoredProcedure [GUI].[usp_Add_SystemHost]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Add_SystemHost]
--declare
	@SHS_ID				int output 	--= NULL
	,@SHS_Name			nvarchar(100)	--= 'Srv_Test_For_Del'
	,@SHS_ShortName		nvarchar(100)	--= 'Srv_Test_For_Del'
    ,@SYS_ID			int				--= 41	
	,@PLT_ID			int				--= 2	
    ,@SLG_ID			int				--= null	
	,@CTR_ID			INT				= NULL
  
as
set nocount on;

IF EXISTS (SELECT * FROM Collect.Collectors WHERE CTR_ID = @CTR_ID AND CTR_IsDeleted = 1)
BEGIN
	DECLARE @CTRNAME NVARCHAR(255)
	SELECT @CTRNAME = CTR_NAME FROM Collect.Collectors WHERE CTR_ID = @CTR_ID
	raiserror('Collector with name as %s is deleted already', 16, 1, @CTRName)
END
ELSE
BEGIN	

	declare 
		@msg		NVARCHAR(2048)
		,@ClienID	int
		,@MOB_ID	int
 
	declare @t table
	(
		id	int
	)

	--IF	@CTR_ID IS NULL
	--	SELECT	
	--			@CTR_ID = CTR_ID 
	--	FROM	Collect.Collectors
	--	WHERE	CTR_IsDefault = 1

	select @ClienID  = cast(SET_Value as int) from Management.Settings where SET_Module ='Management'	and  SET_Key ='Client ID'

	declare @IsWindowsAuthentication bit = 1
	IF @SLG_ID IS NOT NULL
		select @IsWindowsAuthentication = 1 - SLG_LGY_ID from syl.SecureLogins where SLG_ID = @SLG_ID



	--IF NOT EXISTS(select 1 from Management.DefinedObjects JOIN Inventory.MonitoredObjects ON DFO_ID = MOB_Entity_ID where DFO_Name = @SHS_Name and DFO_PLT_ID = @PLT_ID AND ISNULL(MOB_CTR_ID,0) = ISNULL(@CTR_ID,0))
	IF NOT EXISTS(select 1 from Management.DefinedObjects where DFO_Name = @SHS_Name and DFO_PLT_ID = @PLT_ID)
	begin
  
	Begin try

		BEGIN TRAN 

	--	Inserted new Host into Management.DefinedObjects
			insert into Management.DefinedObjects(DFO_ClientID, DFO_PLT_ID, DFO_Name, DFO_IsWindowsAuthentication, DFO_SLG_ID)
			output inserted.DFO_ID into @t(id)
			select @ClienID, @PLT_ID, @SHS_Name, @IsWindowsAuthentication, @SLG_ID

	--	GET	identity from Management.MonitoredObjects
			IF @PLT_ID <> 2
				select @MOB_ID = @@IDENTITY
			ELSE
				select @MOB_ID = MOB_ID FROM Inventory.MonitoredObjects JOIN @t t on MOB_Entity_ID = t.id AND MOB_PLT_ID = @PLT_ID

			update	Inventory.MonitoredObjects 
			set		MOB_OOS_ID = 1
					,MOB_CTR_ID = @CTR_ID
			where	MOB_ID = @MOB_ID

	--	Insert relation between Systems and MonitoredObjects
			INSERT INTO Inventory.SystemHosts
				   (SHS_SYS_ID
				   ,SHS_ShortName
				   ,SHS_MOB_ID)
			 VALUES
				   (@SYS_ID
				   ,@SHS_ShortName
				   ,@MOB_ID)

			 set @SHS_ID = @MOB_ID-- SCOPE_IDENTITY()

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
	
	end

	ELSE
	BEGIN
	  SET @SHS_ID = NULL
	  SELECT @SHS_ID = MOB_ID FROM Inventory.MonitoredObjects WHERE MOB_Name = @SHS_Name and MOB_PLT_ID = @PLT_ID AND MOB_OOS_ID = 3
	  IF @SHS_ID IS NOT NULL
	  BEGIn
		UPDATE Inventory.MonitoredObjects SET MOB_OOS_ID = 1, MOB_CTR_ID = @CTR_ID WHERE MOB_ID = @SHS_ID
		UPDATE Inventory.SystemHosts SET SHS_SYS_ID = @SYS_ID WHERE SHS_MOB_ID = @SHS_ID
	  END
	  ELSE
	  BEGIN
		  SET @msg = 'The Monitored Object ' + @SHS_Name + ' already exists in the Defined Objects'
		  --THROW 51009, @msg, 1; 
		  raiserror(@msg,16,1)
	  
	  END
  
	  select @SHS_ID = DFO_ID from Management.DefinedObjects JOIN Inventory.MonitoredObjects on DFO_ID = MOB_Entity_ID where MOB_ID = @MOB_ID
	END
END
GO
