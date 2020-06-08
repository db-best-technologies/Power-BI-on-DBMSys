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
/****** Object:  Table [Activity].[FailedLogins]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[FailedLogins](
	[FLG_ID] [int] IDENTITY(1,1) NOT NULL,
	[FLG_ClientID] [int] NOT NULL,
	[FLG_MOB_ID] [int] NOT NULL,
	[FLG_FirstDate] [datetime2](3) NOT NULL,
	[FLG_LastDate] [datetime2](3) NOT NULL,
	[FLG_Count] [int] NOT NULL,
	[FLG_LGN_ID] [int] NOT NULL,
	[FLG_HSN_ID] [int] NOT NULL,
	[FLG_IsUnknownLogin] [bit] NOT NULL,
	[FLG_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_FailedLogins] PRIMARY KEY CLUSTERED 
(
	[FLG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_FailedLogins_FLG_LastDate##FLG_MOB_ID#FLG_FLN_ID#FLG_FLL_ID#FLG_IsUnknownLogin]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_FailedLogins_FLG_LastDate##FLG_MOB_ID#FLG_FLN_ID#FLG_FLL_ID#FLG_IsUnknownLogin] ON [Activity].[FailedLogins]
(
	[FLG_LastDate] ASC
)
INCLUDE([FLG_MOB_ID],[FLG_LGN_ID],[FLG_HSN_ID],[FLG_IsUnknownLogin]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FailedLogins_FLG_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_FailedLogins_FLG_Timestamp] ON [Activity].[FailedLogins]
(
	[FLG_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
