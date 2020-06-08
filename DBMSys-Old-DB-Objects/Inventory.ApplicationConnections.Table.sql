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
/****** Object:  Table [Inventory].[ApplicationConnections]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[ApplicationConnections](
	[ACN_ID] [int] IDENTITY(1,1) NOT NULL,
	[ACN_ClientID] [int] NOT NULL,
	[ACN_MOB_ID] [int] NOT NULL,
	[ACN_IDB_ID] [int] NOT NULL,
	[ACN_HSN_ID] [int] NULL,
	[ACN_PGN_ID] [int] NULL,
	[ACN_INL_ID] [int] NOT NULL,
	[ACN_AIA_ID] [int] NULL,
	[ACN_LastSeen] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_ApplicationConnections] PRIMARY KEY CLUSTERED 
(
	[ACN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ApplicationConnections_ACN_MOB_ID#ACN_IDB_ID#ACN_HSN_ID#ACN_PGN_ID#ACN_INL_ID#ACN_AIA_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ApplicationConnections_ACN_MOB_ID#ACN_IDB_ID#ACN_HSN_ID#ACN_PGN_ID#ACN_INL_ID#ACN_AIA_ID] ON [Inventory].[ApplicationConnections]
(
	[ACN_MOB_ID] ASC,
	[ACN_IDB_ID] ASC,
	[ACN_HSN_ID] ASC,
	[ACN_PGN_ID] ASC,
	[ACN_INL_ID] ASC,
	[ACN_AIA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
