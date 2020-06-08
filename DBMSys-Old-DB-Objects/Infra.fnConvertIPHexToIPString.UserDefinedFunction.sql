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
/****** Object:  UserDefinedFunction [Infra].[fnConvertIPHexToIPString]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Infra].[fnConvertIPHexToIPString](@IPHex varchar(20)) returns table
as
	return (select cast(ClassA as varchar(3)) + '.'
					+ cast(ClassB as varchar(3))
					+ '.' + cast(ClassC as varchar(3))
					+ '.' + cast(ClassD as varchar(3)) IPAddress
			from (select cast(convert(varbinary, '0x' + @IPHex, 1) as int) IPNumber) ip
				cross apply (select IPNumber/POWER(256, 3) ClassD) d
				cross apply (select (IPNumber -ClassD*POWER(256, 3))/POWER(256, 2) ClassC) c
				cross apply (select (IPNumber - ClassD*POWER(256, 3) - ClassC*POWER(256, 2))/256 ClassB) b
				cross apply (select IPNumber - ClassD*POWER(256, 3) - ClassC*POWER(256, 2) - ClassB*256 ClassA) a
			)
GO
