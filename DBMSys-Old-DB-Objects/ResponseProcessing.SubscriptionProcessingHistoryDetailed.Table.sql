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
/****** Object:  Table [ResponseProcessing].[SubscriptionProcessingHistoryDetailed]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ResponseProcessing].[SubscriptionProcessingHistoryDetailed](
	[SPD_ID] [int] IDENTITY(1,1) NOT NULL,
	[SPD_ClientID] [int] NOT NULL,
	[SPD_SPH_ID] [int] NOT NULL,
	[SPD_TRE_ID] [int] NOT NULL,
	[SPD_InsertDate] [datetime2](3) NOT NULL,
	[SPD_IsClosed] [bit] NOT NULL,
	[SPD_RunCount] [int] NOT NULL,
 CONSTRAINT [PK_SubscriptionProcessingHistoryDetailed] PRIMARY KEY CLUSTERED 
(
	[SPD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SubscriptionProcessingHistoryDetailed_SPD_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_SubscriptionProcessingHistoryDetailed_SPD_InsertDate] ON [ResponseProcessing].[SubscriptionProcessingHistoryDetailed]
(
	[SPD_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [ResponseProcessing].[SubscriptionProcessingHistoryDetailed] ADD  CONSTRAINT [DF_SubscriptionProcessingHistoryDetailed_SPD_InsertDate]  DEFAULT (sysdatetime()) FOR [SPD_InsertDate]
GO
