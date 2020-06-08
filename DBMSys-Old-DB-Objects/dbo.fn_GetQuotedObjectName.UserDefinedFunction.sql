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
/****** Object:  UserDefinedFunction [dbo].[fn_GetQuotedObjectName]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetQuotedObjectName] (@Object_Name nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE
		@Output	nvarchar(max),
		@Value	nvarchar(2048)

	SET @Output = ''

	DECLARE A CURSOR LOCAL FORWARD_ONLY FOR 
		SELECT '['+Val+'].' FROM [Infra].[fn_SplitString](@Object_Name, '.')

	OPEN A

	FETCH NEXT FROM A INTO @Value

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Output = @Output + @Value

		FETCH NEXT FROM A INTO @Value
	END

	CLOSE A
	DEALLOCATE A

	SET @Output = SUBSTRING(@Output, 1 , LEN(@Output) - 1)

	RETURN @Output
END
GO
