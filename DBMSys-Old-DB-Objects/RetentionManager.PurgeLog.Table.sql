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
/****** Object:  Table [RetentionManager].[PurgeLog]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RetentionManager].[PurgeLog](
	[PLG_ID] [int] IDENTITY(1,1) NOT NULL,
	[PLG_TAS_ID] [int] NOT NULL,
	[PLG_StartDate] [datetime2](3) NOT NULL,
	[PLG_EndDate] [datetime2](3) NULL,
	[PLG_RowCount] [int] NULL,
	[PLG_ErrorCode] [int] NULL,
	[PLG_ErrorMessage] [nvarchar](2000) NULL,
	[PLG_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_PurgeLog] PRIMARY KEY CLUSTERED 
(
	[PLG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PurgeLog_PLG_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PurgeLog_PLG_EndDate] ON [RetentionManager].[PurgeLog]
(
	[PLG_EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PurgeLog_PLG_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PurgeLog_PLG_Timestamp] ON [RetentionManager].[PurgeLog]
(
	[PLG_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
