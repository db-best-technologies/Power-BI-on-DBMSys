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
/****** Object:  UserDefinedTableType [GUI].[MonitoredobjectInstance]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [GUI].[MonitoredobjectInstance] AS TABLE(
	[MOI_MOB_ID] [int] NOT NULL,
	[MOI_CIN_ID] [int] NULL
)
GO
