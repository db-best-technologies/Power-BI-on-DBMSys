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
/****** Object:  Table [Consolidation].[VirtualizationBuckets]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[VirtualizationBuckets](
	[VBC_ID] [tinyint] IDENTITY(1,1) NOT NULL,
	[VBC_SizeRank] [tinyint] NOT NULL,
	[VBC_FromNumberOfCores] [tinyint] NOT NULL,
	[VBC_ToNumberOfCores] [tinyint] NOT NULL,
	[VBC_FromMemoryMB] [bigint] NOT NULL,
	[VBC_ToMemoryMB] [bigint] NOT NULL,
 CONSTRAINT [PK_VirtualizationBuckets] PRIMARY KEY CLUSTERED 
(
	[VBC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
