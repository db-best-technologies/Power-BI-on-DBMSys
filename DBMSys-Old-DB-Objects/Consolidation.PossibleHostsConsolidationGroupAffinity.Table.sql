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
/****** Object:  Table [Consolidation].[PossibleHostsConsolidationGroupAffinity]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[PossibleHostsConsolidationGroupAffinity](
	[PSA_ID] [int] IDENTITY(1,1) NOT NULL,
	[PSA_PSH_ID] [int] NOT NULL,
	[PSA_CGR_ID] [int] NULL,
 CONSTRAINT [PK_PossibleHostsConsolidationGroupAffinity] PRIMARY KEY CLUSTERED 
(
	[PSA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PossibleHostsConsolidationGroupAffinity_PSA_PSH_ID#PSA_CGR_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PossibleHostsConsolidationGroupAffinity_PSA_PSH_ID#PSA_CGR_ID] ON [Consolidation].[PossibleHostsConsolidationGroupAffinity]
(
	[PSA_PSH_ID] ASC,
	[PSA_CGR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
