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
/****** Object:  Table [Inventory].[InMemoryIssues]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InMemoryIssues](
	[IMI_ID] [int] IDENTITY(1,1) NOT NULL,
	[IMI_ClientID] [int] NOT NULL,
	[IMI_MOB_ID] [int] NOT NULL,
	[IMI_IDB_ID] [int] NOT NULL,
	[IMI_DNS_ID] [int] NOT NULL,
	[IMI_DON_ID] [int] NOT NULL,
	[IMI_IMF_ID] [int] NOT NULL,
	[IMI_IssueCount] [int] NOT NULL,
	[IMI_InsertDate] [datetime2](3) NOT NULL,
	[IMI_LastSeenDate] [datetime2](3) NOT NULL,
	[IMI_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_InMemoryIssues] PRIMARY KEY CLUSTERED 
(
	[IMI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_InMemoryIssues_IMCMOBID_IMCIDBID_IMCDNSID_IMCDONID_IMCCFNID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InMemoryIssues_IMCMOBID_IMCIDBID_IMCDNSID_IMCDONID_IMCCFNID] ON [Inventory].[InMemoryIssues]
(
	[IMI_MOB_ID] ASC,
	[IMI_IDB_ID] ASC,
	[IMI_DNS_ID] ASC,
	[IMI_DON_ID] ASC,
	[IMI_IMF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
