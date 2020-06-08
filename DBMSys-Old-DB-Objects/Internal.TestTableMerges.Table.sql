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
/****** Object:  Table [Internal].[TestTableMerges]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Internal].[TestTableMerges](
	[TTM_ID] [int] IDENTITY(1,1) NOT NULL,
	[TTM_TST_ID] [int] NOT NULL,
	[TTM_SchemaName] [nvarchar](128) NOT NULL,
	[TTM_TableName] [nvarchar](128) NOT NULL,
	[TTM_ColumnOrder] [tinyint] NOT NULL,
	[TTM_ColumnName] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_TestTableMerges] PRIMARY KEY CLUSTERED 
(
	[TTM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
