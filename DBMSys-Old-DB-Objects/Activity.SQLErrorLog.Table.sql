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
/****** Object:  Table [Activity].[SQLErrorLog]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[SQLErrorLog](
	[SEL_ID] [int] IDENTITY(1,1) NOT NULL,
	[SEL_ClientID] [int] NOT NULL,
	[SEL_MOB_ID] [int] NOT NULL,
	[SEL_FirstErrorDate] [datetime2](3) NOT NULL,
	[SEL_LastErrorDate] [datetime2](3) NOT NULL,
	[SEL_ErrorCount] [int] NOT NULL,
	[SEL_ProcessInfo] [varchar](1000) NOT NULL,
	[SEL_ErrorMessage] [nvarchar](max) NOT NULL,
	[SEL_Timestamp] [timestamp] NOT NULL,
	[SEL_InsertDate] [datetime2](3) NULL,
 CONSTRAINT [PK_SQLErrorLog] PRIMARY KEY CLUSTERED 
(
	[SEL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_SQLErrorLog_SEL_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_SQLErrorLog_SEL_InsertDate] ON [Activity].[SQLErrorLog]
(
	[SEL_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SQLErrorLog_SEL_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_SQLErrorLog_SEL_Timestamp] ON [Activity].[SQLErrorLog]
(
	[SEL_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Activity].[SQLErrorLog] ADD  CONSTRAINT [DF_SQLErrorLog_SEL_InsertDate]  DEFAULT (sysdatetime()) FOR [SEL_InsertDate]
GO
