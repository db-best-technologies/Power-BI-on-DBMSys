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
/****** Object:  Table [Consolidation].[SingleDatabaseTransactions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[SingleDatabaseTransactions](
	[SDT_ID] [int] IDENTITY(1,1) NOT NULL,
	[SDT_MOB_ID] [int] NOT NULL,
	[SDT_IDB_ID] [int] NOT NULL,
	[SDT_TransactionsSec] [int] NOT NULL,
	[SDT_PercentOfServerActivity] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_SingleDatabaseTransactions] PRIMARY KEY CLUSTERED 
(
	[SDT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SingleDatabaseTransactions_SDT_MOB_ID#SDT_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SingleDatabaseTransactions_SDT_MOB_ID#SDT_IDB_ID] ON [Consolidation].[SingleDatabaseTransactions]
(
	[SDT_MOB_ID] ASC,
	[SDT_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
