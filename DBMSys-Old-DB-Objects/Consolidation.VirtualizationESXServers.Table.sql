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
/****** Object:  Table [Consolidation].[VirtualizationESXServers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[VirtualizationESXServers](
	[VES_ID] [int] IDENTITY(1,1) NOT NULL,
	[VES_ServerType] [varchar](100) NULL,
	[VES_CPUName] [varchar](100) NOT NULL,
	[VES_NumberOfCPUSockets] [int] NOT NULL,
	[VES_MemoryMB] [bigint] NOT NULL,
	[VES_NetworkSpeedMbit] [int] NOT NULL,
	[VES_IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_VirtualizationESXServers] PRIMARY KEY CLUSTERED 
(
	[VES_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
