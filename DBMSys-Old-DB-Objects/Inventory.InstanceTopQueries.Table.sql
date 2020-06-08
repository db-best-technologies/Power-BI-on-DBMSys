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
/****** Object:  Table [Inventory].[InstanceTopQueries]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceTopQueries](
	[ITQ_ID] [int] IDENTITY(1,1) NOT NULL,
	[ITQ_ClientID] [int] NOT NULL,
	[ITQ_MOB_ID] [int] NOT NULL,
	[ITQ_IDB_ID] [int] NULL,
	[ITQ_OBN_ID] [int] NULL,
	[ITQ_SQS_ID] [int] NOT NULL,
	[ITQ_AverageExecutionsPerDay] [bigint] NOT NULL,
	[ITQ_AverageReadsPerDay] [bigint] NOT NULL,
	[ITQ_AverageCPUMilliPerDay] [bigint] NOT NULL,
	[ITQ_AverageDurationMilliPerDay] [bigint] NOT NULL,
	[ITQ_AverageReadsPerExecution] [bigint] NOT NULL,
	[ITQ_AverageCPUMilliPerExecution] [bigint] NOT NULL,
	[ITQ_AverageDurationMilliPerExecution] [bigint] NOT NULL,
	[ITQ_InsertDate] [datetime2](3) NULL,
	[ITQ_LastSeenDate] [datetime2](3) NULL,
	[ITQ_Last_TRH_ID] [int] NULL,
	[ITQ_RankByCPU] [smallint] NULL,
	[ITQ_RankByReads] [smallint] NULL,
	[ITQ_ImplicitlyConvertedColumns] [nvarchar](max) NULL,
	[ITQ_LookupCount] [int] NULL,
	[ITQ_ScalarFunctionsUsed] [nvarchar](max) NULL,
 CONSTRAINT [PK_InstanceTopQueries] PRIMARY KEY CLUSTERED 
(
	[ITQ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_InstanceTopQueries_ITQ_MOB_ID#ITQ_IDB_ID#ITQ_OBN_ID#ITQ_SQS_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceTopQueries_ITQ_MOB_ID#ITQ_IDB_ID#ITQ_OBN_ID#ITQ_SQS_ID] ON [Inventory].[InstanceTopQueries]
(
	[ITQ_MOB_ID] ASC,
	[ITQ_SQS_ID] ASC,
	[ITQ_IDB_ID] ASC,
	[ITQ_OBN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
