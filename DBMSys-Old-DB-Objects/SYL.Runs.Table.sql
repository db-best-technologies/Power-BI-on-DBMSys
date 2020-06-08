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
/****** Object:  Table [SYL].[Runs]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SYL].[Runs](
	[RUN_ID] [int] IDENTITY(1,1) NOT NULL,
	[RUN_QRT_ID] [tinyint] NOT NULL,
	[RUN_StartDate] [datetime] NOT NULL,
	[RUN_ServerList] [varchar](max) NOT NULL,
	[RUN_Database] [nvarchar](255) NOT NULL,
	[RUN_Command] [nvarchar](max) NOT NULL,
	[RUN_ExpectsResults] [bit] NOT NULL,
	[RUN_EndDatetime] [datetime] NULL,
	[RUN_NumberOfErrors] [int] NULL,
	[RUN_ErrorMessage] [varchar](max) NULL,
 CONSTRAINT [PK_Runs] PRIMARY KEY CLUSTERED 
(
	[RUN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_Runs_RUN_EndDatetime]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_Runs_RUN_EndDatetime] ON [SYL].[Runs]
(
	[RUN_EndDatetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [SYL].[Runs] ADD  CONSTRAINT [DF_Runs_RUN_StartDate]  DEFAULT (getdate()) FOR [RUN_StartDate]
GO
