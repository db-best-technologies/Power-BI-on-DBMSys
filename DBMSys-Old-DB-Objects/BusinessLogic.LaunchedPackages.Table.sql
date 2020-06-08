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
/****** Object:  Table [BusinessLogic].[LaunchedPackages]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[LaunchedPackages](
	[LNP_ID] [int] IDENTITY(1,1) NOT NULL,
	[LNP_ClientID] [int] NOT NULL,
	[LNP_PKG_ID] [int] NOT NULL,
	[LNP_LPS_ID] [tinyint] NOT NULL,
	[LNP_LaunchDate] [datetime2](3) NOT NULL,
	[LNP_InterceptionDate] [datetime2](3) NULL,
	[LNP_CompleteDate] [datetime2](3) NULL,
 CONSTRAINT [PK_LaunchedPackages] PRIMARY KEY CLUSTERED 
(
	[LNP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_LaunchedPackages_LNP_LaunchDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_LaunchedPackages_LNP_LaunchDate] ON [BusinessLogic].[LaunchedPackages]
(
	[LNP_LaunchDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
