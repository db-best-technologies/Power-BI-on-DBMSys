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
/****** Object:  Table [Consolidation].[NetworkInfo]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[NetworkInfo](
	[NTI_MOB_ID] [int] NOT NULL,
	[NTI_NetworkSpeedMbit] [decimal](15, 3) NOT NULL,
	[NTI_NetworkUsageUploadMbit] [int] NOT NULL,
	[NTI_NetworkUsageDownloadMbit] [decimal](15, 3) NOT NULL,
	[NTI_AvgMonthlyNetworkOutboundIOMB] [bigint] NOT NULL,
	[NTI_AvgMonthlyNetworkInboundIOMB] [bigint] NOT NULL,
 CONSTRAINT [PK_NetworkInfo] PRIMARY KEY CLUSTERED 
(
	[NTI_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
