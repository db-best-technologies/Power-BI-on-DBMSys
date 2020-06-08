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
/****** Object:  Table [Consolidation].[DiskThroughputInfo]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[DiskThroughputInfo](
	[DTI_MOB_ID] [int] NOT NULL,
	[DTI_DataFileReadsMB] [decimal](38, 5) NULL,
	[DTI_DataFileWritesMB] [decimal](38, 5) NULL,
	[DTI_DataFileTransfersMB] [decimal](38, 5) NULL,
	[DTI_LogFileReadsMB] [decimal](38, 5) NULL,
	[DTI_LogFileWritesMB] [decimal](38, 5) NULL,
	[DTI_LogFileTransfersMB] [decimal](38, 5) NULL,
	[DTI_TempdbReadsMB] [decimal](38, 5) NULL,
	[DTI_TempdbWritesMB] [decimal](38, 5) NULL,
	[DTI_TempdbTransfersMB] [decimal](38, 5) NULL,
	[DTI_OtherDatabaseFileReadsMB] [decimal](38, 5) NULL,
	[DTI_OtherDatabaseFileWritesMB] [decimal](38, 5) NULL,
	[DTI_OtherDatabaseFileTransfersMB] [decimal](38, 5) NULL,
	[DTI_TotalReadsMB] [decimal](38, 5) NOT NULL,
	[DTI_TotalWritesMB] [decimal](38, 5) NOT NULL,
	[DTI_TotalTransfersMB] [decimal](38, 5) NOT NULL,
	[DTI_AvgMonthlyMBs] [bigint] NOT NULL,
	[DTI_DataMaxMBPs] [decimal](38, 5) NULL,
	[DTI_LogMaxMBPs] [decimal](38, 5) NULL,
	[DTI_TotalMaxMBPs] [decimal](38, 5) NOT NULL,
 CONSTRAINT [PK_DiskThroughputInfo] PRIMARY KEY CLUSTERED 
(
	[DTI_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
