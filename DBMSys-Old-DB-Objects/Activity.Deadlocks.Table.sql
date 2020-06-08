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
/****** Object:  Table [Activity].[Deadlocks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[Deadlocks](
	[DLK_ID] [int] IDENTITY(1,1) NOT NULL,
	[DLK_ClientID] [int] NOT NULL,
	[DLK_MOB_ID] [int] NOT NULL,
	[DLK_EventDate] [datetime2](3) NOT NULL,
	[DLK_Graph] [xml] NOT NULL,
	[DLK_InsertDate] [datetime2](3) NOT NULL,
	[DLK_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_Deadlocks] PRIMARY KEY CLUSTERED 
(
	[DLK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_Deadlocks_DLK_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_Deadlocks_DLK_InsertDate] ON [Activity].[Deadlocks]
(
	[DLK_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Deadlocks_DLK_MOB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_Deadlocks_DLK_MOB_ID] ON [Activity].[Deadlocks]
(
	[DLK_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Activity].[Deadlocks] ADD  CONSTRAINT [DF_Deadlocks_DLK_InsertDate]  DEFAULT (sysdatetime()) FOR [DLK_InsertDate]
GO
