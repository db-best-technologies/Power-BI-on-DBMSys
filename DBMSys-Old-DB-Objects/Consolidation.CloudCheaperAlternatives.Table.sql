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
/****** Object:  Table [Consolidation].[CloudCheaperAlternatives]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudCheaperAlternatives](
	[CCA_CLB_ID] [int] NOT NULL,
	[CCA_OriginalPrice] [decimal](15, 3) NULL,
	[CCA_BlockCode] [varchar](1000) NULL,
	[CCA_RunningPrice] [decimal](15, 3) NULL,
	[CCA_Level] [int] NULL,
	[CCA_HST_ID] [tinyint] NULL,
	[CCA_CHE_ID] [tinyint] NULL,
 CONSTRAINT [PK_CloudCheaperAlternatives] PRIMARY KEY CLUSTERED 
(
	[CCA_CLB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudCheaperAlternatives_CCA_HST_ID#CCA_CHE_ID##CCA_BlockCode#CCA_CLB_ID###CCA_OriginalPrice_IS_NOT_NULL]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_CloudCheaperAlternatives_CCA_HST_ID#CCA_CHE_ID##CCA_BlockCode#CCA_CLB_ID###CCA_OriginalPrice_IS_NOT_NULL] ON [Consolidation].[CloudCheaperAlternatives]
(
	[CCA_HST_ID] ASC,
	[CCA_CHE_ID] ASC
)
INCLUDE([CCA_BlockCode],[CCA_CLB_ID]) 
WHERE ([CCA_OriginalPrice] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
