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
/****** Object:  UserDefinedTableType [GUI].[TT_ImportMonitoredObjects]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [GUI].[TT_ImportMonitoredObjects] AS TABLE(
	[System_Name] [nvarchar](255) NULL,
	[System_Descr] [nvarchar](255) NULL,
	[HostName] [nvarchar](255) NULL,
	[Short_HostName] [nvarchar](255) NULL,
	[Host_Type] [nvarchar](255) NULL,
	[SYL_Login] [nvarchar](255) NULL,
	[SYL_Description] [nvarchar](255) NULL,
	[SYL_Password] [nvarchar](255) NULL,
	[SYL_IsDefault] [bit] NULL,
	[SYL_LGY_ID] [tinyint] NULL,
	[CLTR_Name] [nvarchar](255) NULL,
	[CLTR_Descr] [nvarchar](max) NULL
)
GO
