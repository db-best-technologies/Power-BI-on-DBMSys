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
/****** Object:  UserDefinedTableType [GUI].[SystemHostTableType]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [GUI].[SystemHostTableType] AS TABLE(
	[MS_ID] [int] NULL,
	[MS_Name] [nvarchar](255) NULL,
	[SH_ID] [int] NULL,
	[SH_Name] [nvarchar](255) NULL,
	[SH_ShortName] [nvarchar](255) NULL,
	[SHT_ID] [int] NULL,
	[SHT_Name] [nvarchar](255) NULL,
	[SH_Login] [nvarchar](255) NULL,
	[SH_Password] [nvarchar](255) NULL,
	[SLG_ID] [int] NULL,
	[SLG_Description] [nvarchar](255) NULL,
	[SLG_Login] [nvarchar](255) NULL,
	[SLG_Password] [nvarchar](255) NULL,
	[SLG_IsDefault] [bit] NULL,
	[SLG_LGY_ID] [tinyint] NULL
)
GO
