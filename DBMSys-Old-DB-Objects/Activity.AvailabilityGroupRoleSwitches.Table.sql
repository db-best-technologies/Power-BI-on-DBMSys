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
/****** Object:  Table [Activity].[AvailabilityGroupRoleSwitches]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[AvailabilityGroupRoleSwitches](
	[AGS_ID] [int] IDENTITY(1,1) NOT NULL,
	[AGS_ClientID] [int] NOT NULL,
	[AGS_MOB_ID] [int] NOT NULL,
	[AGS_DateRecorded] [datetime2](3) NOT NULL,
	[AGS_AGR_ID] [int] NOT NULL,
	[AGS_GroupID] [uniqueidentifier] NOT NULL,
	[AGS_GroupName] [nvarchar](128) NOT NULL,
	[AGS_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_AvailabilityGroupRoleSwitches] PRIMARY KEY CLUSTERED 
(
	[AGS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AvailabilityGroupRoleSwitches_AGS_DateRecorded#AGS_GroupName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AvailabilityGroupRoleSwitches_AGS_DateRecorded#AGS_GroupName] ON [Activity].[AvailabilityGroupRoleSwitches]
(
	[AGS_DateRecorded] ASC,
	[AGS_GroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AvailabilityGroupRoleSwitches_AGS_MOB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AvailabilityGroupRoleSwitches_AGS_MOB_ID] ON [Activity].[AvailabilityGroupRoleSwitches]
(
	[AGS_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AvailabilityGroupRoleSwitches_AGS_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_AvailabilityGroupRoleSwitches_AGS_Timestamp] ON [Activity].[AvailabilityGroupRoleSwitches]
(
	[AGS_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
