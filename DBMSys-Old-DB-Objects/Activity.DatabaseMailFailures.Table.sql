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
/****** Object:  Table [Activity].[DatabaseMailFailures]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[DatabaseMailFailures](
	[DMF_ID] [int] IDENTITY(1,1) NOT NULL,
	[DMF_ClientID] [int] NOT NULL,
	[DMF_MOB_ID] [int] NOT NULL,
	[DMF_AccountID] [int] NULL,
	[DMF_DMR_ID] [int] NULL,
	[DMF_SRU_ID] [int] NULL,
	[DMF_FirstFailureDate] [datetime2](3) NOT NULL,
	[DMF_LastFailureDate] [datetime2](3) NOT NULL,
	[DMF_FailureCount] [int] NOT NULL,
	[DMF_LastErrorMessage] [nvarchar](max) NOT NULL,
	[DMF_IsClosed] [bit] NOT NULL,
	[DMF_FirstSuccessDate] [datetime2](3) NULL,
	[DMF_LastSuccessDate] [datetime2](3) NULL,
	[DMF_SuccessCount] [int] NULL,
	[DMF_Timestamp] [timestamp] NOT NULL,
	[DMF_InsertDate] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_DatabaseMailFailures] PRIMARY KEY CLUSTERED 
(
	[DMF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_DatabaseMailFailures_DMF_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_DatabaseMailFailures_DMF_InsertDate] ON [Activity].[DatabaseMailFailures]
(
	[DMF_InsertDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DatabaseMailFailures_DMF_IsClosed#DMF_MOB_ID#DMF_AccountID#DMF_DMR_ID###DMF_IsClosed_EQ_0]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_DatabaseMailFailures_DMF_IsClosed#DMF_MOB_ID#DMF_AccountID#DMF_DMR_ID###DMF_IsClosed_EQ_0] ON [Activity].[DatabaseMailFailures]
(
	[DMF_IsClosed] ASC,
	[DMF_MOB_ID] ASC,
	[DMF_AccountID] ASC,
	[DMF_DMR_ID] ASC
)
WHERE ([DMF_IsClosed]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Activity].[DatabaseMailFailures] ADD  CONSTRAINT [DF_DatabaseMailFailures]  DEFAULT (sysdatetime()) FOR [DMF_InsertDate]
GO
