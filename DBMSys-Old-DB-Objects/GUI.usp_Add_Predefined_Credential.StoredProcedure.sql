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
/****** Object:  StoredProcedure [GUI].[usp_Add_Predefined_Credential]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Add_Predefined_Credential]
--declare 
		@SLG_ID				INT 					= null	OUT
		,@SLG_DESCRIPTION	NVARCHAR(255)			= null			
		,@SLG_LOGIN			NVARCHAR(50)			
		,@SLG_PASSWORD		NVARCHAR(50)			
		,@SLG_ISDEFAULT		BIT						= 0
		,@SLG_LGY_ID		INT						

AS

set @SLG_ID = ISNULL(@SLG_ID,-1)
declare 
	@msg NVARCHAR(2048)

set transaction isolation level serializable/* read*/;
begin transaction

set @SLG_DESCRIPTION = ISNULL(@SLG_DESCRIPTION,@SLG_LOGIN)

if exists (select 1 from SYL.SecureLogins where SLG_Login = @SLG_LOGIN and SLG_Password = @SLG_PASSWORD and (SLG_ID <> @SLG_ID or @SLG_ID is null))
BEGIN
	SET @msg = N'A login with these credentials already exists!'; 
	THROW 987654, @msg, 1;  
END
 
	declare @t table 
	(
	id int
	)


  
MERGE SYL.SecureLogins WITH (HOLDLOCK) AS slg
USING (SELECT 
				@SLG_ID				as iSLG_ID		
				,@SLG_DESCRIPTION	as iSLG_DESCRIPTION
				,@SLG_LOGIN			as iSLG_LOGIN
				,@SLG_PASSWORD		as iSLG_PASSWORD
				,@SLG_ISDEFAULT		as iSLG_ISDEFAULT
				,@SLG_LGY_ID		as iSLG_LGY_ID
		) AS i_slg
		ON (i_slg.iSLG_ID = slg.SLG_ID)

WHEN MATCHED THEN 
	UPDATE	 
	SET		SLG_DESCRIPTION	= i_slg.iSLG_DESCRIPTION
			,SLG_LOGIN		= i_slg.iSLG_LOGIN
			,SLG_PASSWORD	= i_slg.iSLG_PASSWORD
			,SLG_ISDEFAULT	= i_slg.iSLG_ISDEFAULT
			,SLG_LGY_ID		= i_slg.iSLG_LGY_ID
		
WHEN NOT MATCHED THEN
	INSERT
		(
			SLG_DESCRIPTION
			,SLG_LOGIN
			,SLG_PASSWORD
			,SLG_ISDEFAULT
			,SLG_LGY_ID
		)
	  
	VALUES
		(
			@SLG_DESCRIPTION	
			,@SLG_LOGIN			
			,@SLG_PASSWORD		
			,@SLG_ISDEFAULT		
			,@SLG_LGY_ID		
		)
		output inserted.SLG_ID into @t(id);

commit
select @SLG_ID = id from @t
GO
