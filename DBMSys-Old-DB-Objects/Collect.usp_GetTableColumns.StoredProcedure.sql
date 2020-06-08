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
/****** Object:  StoredProcedure [Collect].[usp_GetTableColumns]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collect].[usp_GetTableColumns] 
--DECLARE
	@TableName	NVARCHAR(255)
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
			name						AS CName 
			,type_name(user_type_id)	AS CType
			,max_length					AS CLength
	FROM	sys.columns c
	WHERE	c.object_id = object_id(@TableName)			
END
GO
