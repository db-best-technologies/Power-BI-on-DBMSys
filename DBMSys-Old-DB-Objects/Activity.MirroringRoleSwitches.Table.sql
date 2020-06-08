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
/****** Object:  Table [Activity].[MirroringRoleSwitches]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[MirroringRoleSwitches](
	[MRS_ID] [int] IDENTITY(1,1) NOT NULL,
	[MRS_ClientID] [int] NOT NULL,
	[MRS_MOB_ID] [int] NOT NULL,
	[MRS_DateRecorded] [datetime2](3) NOT NULL,
	[MRS_MRD_GUID] [uniqueidentifier] NOT NULL,
	[MRS_Previous_MRL_ID] [tinyint] NOT NULL,
	[MRS_Current_MRL_ID] [tinyint] NOT NULL,
	[MRS_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_MirroringRoleSwitches] PRIMARY KEY CLUSTERED 
(
	[MRS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_MirroringRoleSwitches_MRS_DateRecorded#MRS_MRD_GUID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_MirroringRoleSwitches_MRS_DateRecorded#MRS_MRD_GUID] ON [Activity].[MirroringRoleSwitches]
(
	[MRS_DateRecorded] ASC,
	[MRS_MRD_GUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_MirroringRoleSwitches_MRS_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_MirroringRoleSwitches_MRS_Timestamp] ON [Activity].[MirroringRoleSwitches]
(
	[MRS_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
