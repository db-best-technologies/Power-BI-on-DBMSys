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
/****** Object:  Table [Activity].[AvailabilityGroupErrors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[AvailabilityGroupErrors](
	[AGE_ID] [int] IDENTITY(1,1) NOT NULL,
	[AGE_ClientID] [int] NOT NULL,
	[AGE_MOB_ID] [int] NOT NULL,
	[AGE_GroupID] [uniqueidentifier] NOT NULL,
	[AGE_ReplicaID] [uniqueidentifier] NOT NULL,
	[AGE_AGT_ID] [tinyint] NOT NULL,
	[AGE_ErrorNumber] [int] NULL,
	[AGE_ErrorDescription] [nvarchar](1024) NOT NULL,
	[AGE_FirstOccurence] [datetime2](3) NOT NULL,
	[AGE_LastOccurence] [datetime2](3) NOT NULL,
	[AGE_NumberOfOccurences] [int] NOT NULL,
	[AGE_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_AvailabilityGroupErrors] PRIMARY KEY CLUSTERED 
(
	[AGE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AvailabilityGroupErrors_AGE_LastOccurence]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AvailabilityGroupErrors_AGE_LastOccurence] ON [Activity].[AvailabilityGroupErrors]
(
	[AGE_LastOccurence] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AvailabilityGroupErrors_AGE_MOB_ID#AGE_GroupID#AGE_ReplicaID#AGE_AGT_ID#AGE_LastOccurence#AGE_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AvailabilityGroupErrors_AGE_MOB_ID#AGE_GroupID#AGE_ReplicaID#AGE_AGT_ID#AGE_LastOccurence#AGE_ID] ON [Activity].[AvailabilityGroupErrors]
(
	[AGE_MOB_ID] ASC,
	[AGE_GroupID] ASC,
	[AGE_ReplicaID] ASC,
	[AGE_AGT_ID] ASC,
	[AGE_LastOccurence] ASC,
	[AGE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AvailabilityGroupErrors_AGE_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AvailabilityGroupErrors_AGE_Timestamp] ON [Activity].[AvailabilityGroupErrors]
(
	[AGE_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
