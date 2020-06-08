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
/****** Object:  Table [Consolidation].[ServerPossibleHostTypes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[ServerPossibleHostTypes](
	[SHT_ID] [int] IDENTITY(1,1) NOT NULL,
	[SHT_MOB_ID] [int] NOT NULL,
	[SHT_HST_ID] [tinyint] NOT NULL,
	[SHT_ExclusivityGroupID] [tinyint] NULL,
 CONSTRAINT [PK_ServerPossibleHostTypes] PRIMARY KEY CLUSTERED 
(
	[SHT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ServerPossibleHostTypes_SHT_MOB_ID#SHT_ExclusivityGroupID###SHT_ExclusivityGroupID_IS_NOT_NULL]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ServerPossibleHostTypes_SHT_MOB_ID#SHT_ExclusivityGroupID###SHT_ExclusivityGroupID_IS_NOT_NULL] ON [Consolidation].[ServerPossibleHostTypes]
(
	[SHT_MOB_ID] ASC,
	[SHT_ExclusivityGroupID] ASC
)
WHERE ([SHT_ExclusivityGroupID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ServerPossibleHostTypes_SHT_MOB_ID#SHT_HST_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ServerPossibleHostTypes_SHT_MOB_ID#SHT_HST_ID] ON [Consolidation].[ServerPossibleHostTypes]
(
	[SHT_MOB_ID] ASC,
	[SHT_HST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
