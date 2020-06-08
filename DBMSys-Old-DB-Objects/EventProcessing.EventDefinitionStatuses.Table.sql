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
/****** Object:  Table [EventProcessing].[EventDefinitionStatuses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[EventDefinitionStatuses](
	[EDS_ID] [int] IDENTITY(1,1) NOT NULL,
	[EDS_ClientID] [int] NOT NULL,
	[EDS_EDF_ID] [int] NOT NULL,
	[EDS_MOB_ID] [int] NOT NULL,
	[EDS_EventInstanceName] [varchar](850) NULL,
	[EDS_FirstEventDate] [datetime2](3) NOT NULL,
	[EDS_LastEventDate] [datetime2](3) NOT NULL,
	[EDS_EventCount] [int] NOT NULL,
	[EDS_FirstOKEventDate] [datetime2](3) NULL,
	[EDS_LastOKEventDate] [datetime2](3) NULL,
	[EDS_OKEventCount] [int] NULL,
	[EDS_IsClosed] [bit] NOT NULL,
	[EDS_IsOpenAndShut] [bit] NOT NULL,
	[EDS_Open_PRC_ID] [int] NOT NULL,
	[EDS_Last_PRC_ID] [int] NOT NULL,
	[EDS_Timestamp] [binary](8) NULL,
	[EDS_Message] [nvarchar](max) NULL,
	[EDS_OK_PRC_ID] [int] NULL,
	[EDS_OKTimestamp] [binary](8) NULL,
	[EDS_OKMessage] [nvarchar](max) NULL,
	[EDS_AlertEventData] [xml] NULL,
	[EDS_OKEventData] [xml] NULL,
	[EDS_AutoResolveAtDate] [datetime2](3) NULL,
	[EDS_TEC_ID] [tinyint] NULL,
 CONSTRAINT [PK_EventDefinitionStatuses] PRIMARY KEY CLUSTERED 
(
	[EDS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_EventDefinitionStatuses_EDS_EDF_ID#EDS_MOB_ID#EDS_EventInstanceName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventDefinitionStatuses_EDS_EDF_ID#EDS_MOB_ID#EDS_EventInstanceName] ON [EventProcessing].[EventDefinitionStatuses]
(
	[EDS_EDF_ID] ASC,
	[EDS_MOB_ID] ASC,
	[EDS_EventInstanceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
