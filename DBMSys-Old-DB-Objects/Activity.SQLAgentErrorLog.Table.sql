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
/****** Object:  Table [Activity].[SQLAgentErrorLog]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[SQLAgentErrorLog](
	[SAL_ID] [int] IDENTITY(1,1) NOT NULL,
	[SAL_ClientID] [int] NOT NULL,
	[SAL_MOB_ID] [int] NOT NULL,
	[SAL_FirstErrorDate] [datetime2](3) NOT NULL,
	[SAL_LastErrorDate] [datetime2](3) NOT NULL,
	[SAL_ErrorCount] [int] NOT NULL,
	[SAL_ErrorLevel] [int] NOT NULL,
	[SAL_ErrorMessage] [nvarchar](max) NOT NULL,
	[SAL_Timestamp] [timestamp] NOT NULL,
	[SAL_InsertDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_SQLAgentErrorLog] PRIMARY KEY CLUSTERED 
(
	[SAL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_SQLAgentErrorLog_SAL_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_SQLAgentErrorLog_SAL_InsertDate] ON [Activity].[SQLAgentErrorLog]
(
	[SAL_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Activity].[SQLAgentErrorLog] ADD  CONSTRAINT [DF_SQLAgentErrorLog_SAL_InsertDate]  DEFAULT (sysdatetime()) FOR [SAL_InsertDate]
GO
