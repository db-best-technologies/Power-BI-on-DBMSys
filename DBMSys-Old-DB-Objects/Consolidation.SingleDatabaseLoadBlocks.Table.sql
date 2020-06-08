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
/****** Object:  Table [Consolidation].[SingleDatabaseLoadBlocks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[SingleDatabaseLoadBlocks](
	[SDL_ID] [int] IDENTITY(1,1) NOT NULL,
	[SDL_HST_ID] [tinyint] NOT NULL,
	[SDL_MOB_ID] [int] NOT NULL,
	[SDL_IDB_ID] [int] NOT NULL,
	[SDL_DTUs] [int] NOT NULL,
	[SDL_SizeGB] [decimal](15, 3) NOT NULL,
 CONSTRAINT [PK_SingleDatabaseLoadBlocks] PRIMARY KEY CLUSTERED 
(
	[SDL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SingleDatabaseLoadBlocks_SDL_HST_ID#SDL_MOB_ID#SDL_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SingleDatabaseLoadBlocks_SDL_HST_ID#SDL_MOB_ID#SDL_IDB_ID] ON [Consolidation].[SingleDatabaseLoadBlocks]
(
	[SDL_HST_ID] ASC,
	[SDL_MOB_ID] ASC,
	[SDL_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
