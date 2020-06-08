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
/****** Object:  Table [ResponseProcessing].[SubscriptionProcessingHistory]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ResponseProcessing].[SubscriptionProcessingHistory](
	[SPH_ID] [int] IDENTITY(1,1) NOT NULL,
	[SPH_ClientID] [int] NOT NULL,
	[SPH_ESP_ID] [int] NOT NULL,
	[SPH_IsRerun] [bit] NOT NULL,
	[SPH_StartDate] [datetime2](3) NOT NULL,
	[SPH_LastHandledTimestamp] [binary](8) NULL,
	[SPH_EndDate] [datetime2](3) NULL,
	[SPH_ErrorMessage] [nvarchar](max) NULL,
	[SPH_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_SubscriptionProcessingHistory] PRIMARY KEY CLUSTERED 
(
	[SPH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_SubscriptionProcessingHistory_SPH_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_SubscriptionProcessingHistory_SPH_EndDate] ON [ResponseProcessing].[SubscriptionProcessingHistory]
(
	[SPH_EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SubscriptionProcessingHistory_SPH_Timestamp#SPH_StartDate##SPH_EndDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_SubscriptionProcessingHistory_SPH_Timestamp#SPH_StartDate##SPH_EndDate] ON [ResponseProcessing].[SubscriptionProcessingHistory]
(
	[SPH_Timestamp] ASC,
	[SPH_StartDate] ASC
)
INCLUDE([SPH_EndDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [ResponseProcessing].[SubscriptionProcessingHistory] ADD  CONSTRAINT [DF_SubscriptionProcessingHistory_RPH_StartDate]  DEFAULT (sysdatetime()) FOR [SPH_StartDate]
GO
