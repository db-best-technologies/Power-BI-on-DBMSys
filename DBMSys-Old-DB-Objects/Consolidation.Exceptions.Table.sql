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
/****** Object:  Table [Consolidation].[Exceptions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[Exceptions](
	[EXP_ID] [int] IDENTITY(1,1) NOT NULL,
	[EXP_EXT_ID] [tinyint] NOT NULL,
	[EXP_MOB_ID] [int] NOT NULL,
	[EXP_IDB_ID] [int] NULL,
	[EXP_Reason] [varchar](1000) NOT NULL,
	[EXP_HST_ID] [tinyint] NULL,
 CONSTRAINT [PK_Exceptions] PRIMARY KEY CLUSTERED 
(
	[EXP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Exceptions_EXP_EXT_ID#EXP_MOB_ID#EXP_IDB_ID#EXP_HST_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_Exceptions_EXP_EXT_ID#EXP_MOB_ID#EXP_IDB_ID#EXP_HST_ID] ON [Consolidation].[Exceptions]
(
	[EXP_EXT_ID] ASC,
	[EXP_MOB_ID] ASC,
	[EXP_IDB_ID] ASC,
	[EXP_HST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
