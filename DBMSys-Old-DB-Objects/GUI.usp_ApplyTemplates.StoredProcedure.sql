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
/****** Object:  StoredProcedure [GUI].[usp_ApplyTemplates]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_ApplyTemplates]
--DECLARE 
		@t GUI.TT_Identity_List	readonly
AS
DECLARE @OCFID	TINYINT

UPDATE Management.OperationConfigurations set OCF_IsApply = 0 where not exists (SELECT * FROM @t WHERE OCF_ID = ILS_ID)

declare cCommands cursor local static for
		SELECT 
				OCF_ID 
		FROM	Management.OperationConfigurations
		WHERE	EXISTS (SELECT * FROM @t WHERE OCF_ID = ILS_ID)
		ORDER BY OCF_Priority DESC

	open cCommands
	fetch next from cCommands into @OCFID
	while @@fetch_status = 0
	begin
	
		exec [GUI].[usp_SetOperationConfigurations] @OCFID
		UPDATE Management.OperationConfigurations set OCF_IsApply = 1 where OCF_ID = @OCFID

		fetch next from cCommands into @OCFID
	end
	close cCommands
	deallocate cCommands
GO
