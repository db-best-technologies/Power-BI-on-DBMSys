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
/****** Object:  Table [SYL].[ServerRunResult]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SYL].[ServerRunResult](
	[SRR_ID] [int] IDENTITY(1,1) NOT NULL,
	[SRR_RUN_ID] [int] NOT NULL,
	[SRR_ServerName] [nvarchar](255) NOT NULL,
	[SRR_StartDate] [datetime] NOT NULL,
	[SRR_EndDate] [datetime] NULL,
	[SRR_RecordsAffected] [int] NULL,
	[SRR_ErrorMessage] [varchar](max) NULL,
 CONSTRAINT [PK_ServerRunResult] PRIMARY KEY CLUSTERED 
(
	[SRR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_ServerRunResult_SRR_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ServerRunResult_SRR_EndDate] ON [SYL].[ServerRunResult]
(
	[SRR_EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ServerRunResult_SRR_RUN_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ServerRunResult_SRR_RUN_ID] ON [SYL].[ServerRunResult]
(
	[SRR_RUN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [SYL].[ServerRunResult] ADD  DEFAULT (getdate()) FOR [SRR_StartDate]
GO
