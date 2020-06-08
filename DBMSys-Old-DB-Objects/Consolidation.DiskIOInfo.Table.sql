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
/****** Object:  Table [Consolidation].[DiskIOInfo]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[DiskIOInfo](
	[DII_MOB_ID] [int] NOT NULL,
	[DII_DataFileReads] [decimal](38, 5) NULL,
	[DII_DataFileWrites] [decimal](38, 5) NULL,
	[DII_DataFileTransfers] [decimal](38, 5) NULL,
	[DII_LogFileReads] [decimal](38, 5) NULL,
	[DII_LogFileWrites] [decimal](38, 5) NULL,
	[DII_LogFileTransfers] [decimal](38, 5) NULL,
	[DII_TempdbReads] [decimal](38, 5) NULL,
	[DII_TempdbWrites] [decimal](38, 5) NULL,
	[DII_TempdbTransfers] [decimal](38, 5) NULL,
	[DII_OtherDatabaseFileReads] [decimal](38, 5) NULL,
	[DII_OtherDatabaseFileWrites] [decimal](38, 5) NULL,
	[DII_OtherDatabaseFileTransfers] [decimal](38, 5) NULL,
	[DII_TotalReads] [decimal](38, 5) NOT NULL,
	[DII_TotalWrites] [decimal](38, 5) NOT NULL,
	[DII_TotalTransfers] [decimal](38, 5) NOT NULL,
	[DII_AvgMonthlyIOPS] [bigint] NOT NULL,
	[DII_DataMaxTransfers] [decimal](38, 5) NULL,
	[DII_LogMaxTransfers] [decimal](38, 5) NULL,
	[DII_TotalMaxTransfers] [decimal](38, 5) NOT NULL,
 CONSTRAINT [PK_DiskIOInfo] PRIMARY KEY CLUSTERED 
(
	[DII_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
