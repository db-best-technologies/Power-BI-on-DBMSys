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
/****** Object:  Table [Activity].[TracerTokens]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[TracerTokens](
	[TCT_ID] [int] IDENTITY(1,1) NOT NULL,
	[TCT_ClientID] [int] NOT NULL,
	[TCT_MOB_ID] [int] NOT NULL,
	[TCT_TRP_ID] [int] NOT NULL,
	[TCT_TokenID] [int] NOT NULL,
	[TCT_DateSent] [datetime2](3) NOT NULL,
	[TCT_IsClosed] [bit] NOT NULL,
	[TCT_IsDeleted] [bit] NULL,
	[TCT_DateClosed] [datetime2](3) NULL,
	[TCT_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_TracerTokens] PRIMARY KEY CLUSTERED 
(
	[TCT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_TracerTokens_TCT_DateClosed#TCT_MOB_ID#TCT_DateSent]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TracerTokens_TCT_DateClosed#TCT_MOB_ID#TCT_DateSent] ON [Activity].[TracerTokens]
(
	[TCT_DateClosed] ASC,
	[TCT_MOB_ID] ASC,
	[TCT_DateSent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TracerTokens_TCT_TRP_ID###TCT_IsClosed_EQ_0]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TracerTokens_TCT_TRP_ID###TCT_IsClosed_EQ_0] ON [Activity].[TracerTokens]
(
	[TCT_TRP_ID] ASC
)
WHERE ([TCT_IsClosed]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
