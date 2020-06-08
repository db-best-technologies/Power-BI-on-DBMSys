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
/****** Object:  Table [Inventory].[TopDatabaseTables]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[TopDatabaseTables](
	[TDT_ID] [int] IDENTITY(1,1) NOT NULL,
	[TDT_ClientID] [int] NOT NULL,
	[TDT_MOB_ID] [int] NOT NULL,
	[TDT_IDB_ID] [int] NOT NULL,
	[TDT_TableName] [nvarchar](257) NOT NULL,
	[TDT_NumberOfRows] [bigint] NOT NULL,
	[TDT_NumberOfPartitions] [int] NOT NULL,
	[TDT_PrecentCompressed] [tinyint] NULL,
	[TDT_InsertDate] [datetime2](3) NULL,
	[TDT_LastSeenDate] [datetime2](3) NULL,
	[TDT_Last_TRH_ID] [int] NULL,
 CONSTRAINT [PK_TopDatabaseTables] PRIMARY KEY CLUSTERED 
(
	[TDT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TopDatabaseTables_TDT_MOB_ID#TDT_IDB_ID#TDT_TableName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TopDatabaseTables_TDT_MOB_ID#TDT_IDB_ID#TDT_TableName] ON [Inventory].[TopDatabaseTables]
(
	[TDT_MOB_ID] ASC,
	[TDT_IDB_ID] ASC,
	[TDT_TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TopDatabaseTables_TDT_MOB_ID#TDT_Last_TRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TopDatabaseTables_TDT_MOB_ID#TDT_Last_TRH_ID] ON [Inventory].[TopDatabaseTables]
(
	[TDT_MOB_ID] ASC,
	[TDT_Last_TRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
