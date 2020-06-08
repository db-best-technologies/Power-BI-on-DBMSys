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
/****** Object:  Table [EventProcessing].[TrappedEvents]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[TrappedEvents](
	[TRE_ID] [int] IDENTITY(1,1) NOT NULL,
	[TRE_ClientID] [int] NOT NULL,
	[TRE_MOB_ID] [int] NOT NULL,
	[TRE_MOV_ID] [int] NOT NULL,
	[TRE_MEG_ID] [int] NULL,
	[TRE_Level] [tinyint] NULL,
	[TRE_IsClosed] [bit] NULL,
	[TRE_IsOpenAndShut] [bit] NOT NULL,
	[TRE_EventInstanceName] [varchar](850) NULL,
	[TRE_OpenDate] [datetime2](3) NOT NULL,
	[TRE_CloseDate] [datetime2](3) NULL,
	[TRE_AlertMessage] [nvarchar](max) NULL,
	[TRE_OKMessage] [nvarchar](max) NULL,
	[TRE_AlertEventData] [xml] NULL,
	[TRE_OKEventData] [xml] NULL,
	[TRE_TEC_ID] [tinyint] NULL,
	[TRE_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_TrappedEvents] PRIMARY KEY CLUSTERED 
(
	[TRE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_TrappedEvents_TRE_CloseDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TrappedEvents_TRE_CloseDate] ON [EventProcessing].[TrappedEvents]
(
	[TRE_CloseDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TrappedEvents_TRE_MEG_ID#TRE_Level###TRE_IsClosed_EQ_0]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TrappedEvents_TRE_MEG_ID#TRE_Level###TRE_IsClosed_EQ_0] ON [EventProcessing].[TrappedEvents]
(
	[TRE_MEG_ID] ASC,
	[TRE_Level] ASC
)
WHERE ([TRE_IsClosed]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TrappedEvents_TRE_MOV_ID#TRE_Timestamp#TRE_IsClosed##TRE_MOB_ID#TRE_EventInstanceName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TrappedEvents_TRE_MOV_ID#TRE_Timestamp#TRE_IsClosed##TRE_MOB_ID#TRE_EventInstanceName] ON [EventProcessing].[TrappedEvents]
(
	[TRE_MOV_ID] ASC,
	[TRE_Timestamp] ASC,
	[TRE_IsClosed] ASC
)
INCLUDE([TRE_MOB_ID],[TRE_EventInstanceName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TrappedEvents_TRE_Timestamp#TRE_OpenDate##TRE_CloseDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TrappedEvents_TRE_Timestamp#TRE_OpenDate##TRE_CloseDate] ON [EventProcessing].[TrappedEvents]
(
	[TRE_Timestamp] ASC,
	[TRE_OpenDate] ASC
)
INCLUDE([TRE_CloseDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [EventProcessing].[trg_TrappedEvents]    Script Date: 6/8/2020 1:14:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [EventProcessing].[trg_TrappedEvents] on [EventProcessing].[TrappedEvents]
	for update
as
delete EventProcessing.EventDefinitionStatuses
from inserted
	inner join EventProcessing.EventDefinitions on TRE_MOV_ID = EDF_MOV_ID
where EDS_EDF_ID = EDF_ID
	and TRE_IsClosed = 1
	and TRE_TEC_ID = 2
	and TRE_MOB_ID = EDS_MOB_ID
	and (TRE_EventInstanceName = EDS_EventInstanceName
			or (TRE_EventInstanceName is null
					and EDS_EventInstanceName is null)
			)
GO
ALTER TABLE [EventProcessing].[TrappedEvents] ENABLE TRIGGER [trg_TrappedEvents]
GO
