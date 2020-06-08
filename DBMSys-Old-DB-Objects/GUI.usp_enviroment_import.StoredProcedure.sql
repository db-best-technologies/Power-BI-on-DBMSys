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
/****** Object:  StoredProcedure [GUI].[usp_enviroment_import]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_enviroment_import]

--declare 
		@t GUI.SystemHostTableType READONLY

as
SET XACT_ABORT ON;

declare @outt table
(
	id		int
	,logi	nvarchar(255)
)

declare @HCredentials table
(
		SLG_ID				int	
		,SLG_Description	nvarchar(255)
		,SLG_Login			nvarchar(255)
		,SLG_Password		nvarchar(255)
		,SLG_IsDefault		bit
		,SLG_LGY_ID			tinyint
)

insert into @HCredentials(SLG_ID,SLG_Description,SLG_Login,SLG_Password,SLG_IsDefault,SLG_LGY_ID)
SELECT	distinct
		SLG_ID
		,SLG_Description
		,SLG_Login
		,SLG_Password
		,SLG_IsDefault
		,SLG_LGY_ID
FROM	@t
WHERE	SLG_LOGIN IS NOT NULL	


BEGIN TRAN xxx

	
--**************************************************************************
--							CREDENTIALS
--**************************************************************************
	update syl.SecureLogins set SLG_Password = c.SLG_Password from @HCredentials c where c.SLG_Login = syl.SecureLogins.SLG_Login
	--select @@ROWCOUNT

	insert into syl.SecureLogins(SLG_Description,SLG_Login,SLG_Password,SLG_IsDefault,SLG_LGY_ID)
	output inserted.SLG_ID,inserted.SLG_Login into @outt(id,logi)
	select 
			c.SLG_Description	
			,c.SLG_Login	
			,c.SLG_Password	
			,c.SLG_IsDefault	
			,c.SLG_LGY_ID	
	from	@HCredentials c 
	left join syl.SecureLogins l on l.SLG_Login = c.SLG_Login 
	where	l.SLG_ID is null and c.SLG_Login is not null

	--update @t set SLG_ID = id from @outt where SLG_LOGIN = logi

	--select 'output value',* from @outt
	
--**************************************************************************
--							SYSTEM & HOST
--**************************************************************************
	
	SET IDENTITY_INSERT Inventory.Systems ON

	insert into Inventory.Systems(Sys_ID,Sys_Name)
	select 
			distinct 
			MS_ID
			,MS_Name
	from	@t

	SET IDENTITY_INSERT Inventory.Systems OFF

	
	SET IDENTITY_INSERT Inventory.SystemHosts ON

	insert into Inventory.SystemHosts (SHS_ID,SHS_ShortName,SHS_Sys_Id)
	select
			SH_ID
			
			,SH_ShortName
			,SHT_ID
			
	from	@t t
	left join @outt o on SLG_LOGIN = logi

	SET IDENTITY_INSERT Inventory.SystemHosts OFF
	

--ROLLBACK TRAN xxx
COMMIT TRAN xxx
GO
