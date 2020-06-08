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
/****** Object:  Table [Inventory].[DBInstancePortfolioAssessment]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DBInstancePortfolioAssessment](
	[SPA_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SPA_ClientID] [bigint] NULL,
	[SPA_MOB_ID] [int] NULL,
	[SPA_DatabaseName] [nvarchar](255) NULL,
	[SPA_SchemaName] [nvarchar](255) NULL,
	[SPA_ObjectType] [nvarchar](255) NULL,
	[SPA_ObjectCount] [int] NULL,
	[SPA_LastTRH_ID] [bigint] NULL,
 CONSTRAINT [PK_DBInstancePortfolioAssessment] PRIMARY KEY CLUSTERED 
(
	[SPA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_DBInstancePortfolioAssessment###SPA_MOB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IDX_DBInstancePortfolioAssessment###SPA_MOB_ID] ON [Inventory].[DBInstancePortfolioAssessment]
(
	[SPA_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
