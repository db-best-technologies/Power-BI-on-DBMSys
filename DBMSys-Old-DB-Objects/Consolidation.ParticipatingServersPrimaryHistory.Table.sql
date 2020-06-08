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
/****** Object:  Table [Consolidation].[ParticipatingServersPrimaryHistory]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[ParticipatingServersPrimaryHistory](
	[PPH_ID] [int] IDENTITY(1,1) NOT NULL,
	[PPH_Server_MOB_ID] [int] NOT NULL,
	[PPH_Database_MOB_ID] [int] NULL,
	[PPH_Primary_Server_MOB_ID] [int] NOT NULL,
	[PPH_Primary_Database_MOB_ID] [int] NULL,
	[PPH_StartDate] [datetime2](3) NOT NULL,
	[PPH_EndDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_ParticipatingServersPrimaryHistory] PRIMARY KEY CLUSTERED 
(
	[PPH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ParticipatingServersPrimaryHistory_PPH_Server_MOB_ID_ID##PPH_Primary_MOB_ID#PPH_StartDate#PPH_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ParticipatingServersPrimaryHistory_PPH_Server_MOB_ID_ID##PPH_Primary_MOB_ID#PPH_StartDate#PPH_EndDate] ON [Consolidation].[ParticipatingServersPrimaryHistory]
(
	[PPH_Server_MOB_ID] ASC
)
INCLUDE([PPH_Database_MOB_ID],[PPH_Primary_Server_MOB_ID],[PPH_Primary_Database_MOB_ID],[PPH_StartDate],[PPH_EndDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
