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
/****** Object:  Table [DTUCalculator].[PieChart]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DTUCalculator].[PieChart](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](128) NOT NULL,
	[ChartType] [varchar](15) NOT NULL,
	[TierType] [varchar](100) NOT NULL,
	[Percentage] [decimal](6, 2) NOT NULL,
	[Total] [decimal](6, 2) NOT NULL,
 CONSTRAINT [PK_PieChart] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
