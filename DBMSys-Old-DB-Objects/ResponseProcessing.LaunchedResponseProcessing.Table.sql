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
/****** Object:  Table [ResponseProcessing].[LaunchedResponseProcessing]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ResponseProcessing].[LaunchedResponseProcessing](
	[LRP_ID] [int] IDENTITY(1,1) NOT NULL,
	[LRP_ClientID] [int] NOT NULL,
	[LRP_ESP_ID] [int] NOT NULL,
	[LRP_FromTimestamp] [binary](8) NULL,
	[LRP_ToTimestamp] [binary](8) NOT NULL,
	[LRP_LRS_ID] [tinyint] NOT NULL,
	[LRP_LaunchDate] [datetime2](3) NOT NULL,
	[LRP_InterceptionDate] [datetime2](3) NULL,
	[LRP_CompleteDate] [datetime2](3) NULL,
 CONSTRAINT [PK_LaunchedResponseProcessing] PRIMARY KEY CLUSTERED 
(
	[LRP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_LaunchedResponseProcessing_LRP_LaunchDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_LaunchedResponseProcessing_LRP_LaunchDate] ON [ResponseProcessing].[LaunchedResponseProcessing]
(
	[LRP_LaunchDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LaunchedResponseProcessing_LRP_LRS_ID#LRP_LaunchDate##LRP_ESP_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_LaunchedResponseProcessing_LRP_LRS_ID#LRP_LaunchDate##LRP_ESP_ID] ON [ResponseProcessing].[LaunchedResponseProcessing]
(
	[LRP_LRS_ID] ASC,
	[LRP_LaunchDate] ASC
)
INCLUDE([LRP_ESP_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
