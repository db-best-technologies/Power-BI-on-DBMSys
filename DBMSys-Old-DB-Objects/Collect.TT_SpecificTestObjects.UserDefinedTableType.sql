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
/****** Object:  UserDefinedTableType [Collect].[TT_SpecificTestObjects]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [Collect].[TT_SpecificTestObjects] AS TABLE(
	[STO_ClientID] [int] NOT NULL,
	[STO_TST_ID] [int] NOT NULL,
	[STO_MOB_ID] [int] NOT NULL,
	[STO_IntervalType] [char](1) NULL,
	[STO_IntervalPeriod] [int] NULL,
	[STO_Comments] [varchar](1000) NULL
)
GO
