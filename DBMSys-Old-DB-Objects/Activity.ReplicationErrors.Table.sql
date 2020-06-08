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
/****** Object:  Table [Activity].[ReplicationErrors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[ReplicationErrors](
	[RPE_ID] [int] IDENTITY(1,1) NOT NULL,
	[RPE_ClientID] [int] NOT NULL,
	[RPE_MOB_ID] [int] NOT NULL,
	[RPE_TRP_ID] [int] NOT NULL,
	[RPE_TRB_ID] [int] NULL,
	[RPE_RAT_ID] [tinyint] NOT NULL,
	[RPE_FirstFailureDate] [datetime2](3) NOT NULL,
	[RPE_LastFailureDate] [datetime2](3) NOT NULL,
	[RPE_FailureCount] [int] NULL,
	[RPE_ErrorMessage] [nvarchar](max) NULL,
	[RPE_HashedErrorMessage]  AS (hashbytes('MD5',left(CONVERT([varchar](max),[RPE_ErrorMessage],(0)),(8000)))),
	[RPE_IsClosed] [bit] NOT NULL,
	[RPE_CloseDate] [datetime2](3) NULL,
	[RPE_ObjectDeleted] [bit] NOT NULL,
	[RPE_Timestamp] [timestamp] NOT NULL,
	[RPE_InsertDate] [datetime2](3) NOT NULL,
	[RPE_LastSeenDate] [datetime2](3) NOT NULL,
	[RPE_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_ReplicationErrors] PRIMARY KEY CLUSTERED 
(
	[RPE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [IX_RE_RPE_MOB_ID#RPE_MOB_ID#RPE_TRP_ID#RPE_TRB_ID#RPE_RAT_ID#RPE_HashedErrorMessage##RPE_LastFailureDate###RPE_IsClosed_EQ_0]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RE_RPE_MOB_ID#RPE_MOB_ID#RPE_TRP_ID#RPE_TRB_ID#RPE_RAT_ID#RPE_HashedErrorMessage##RPE_LastFailureDate###RPE_IsClosed_EQ_0] ON [Activity].[ReplicationErrors]
(
	[RPE_MOB_ID] ASC,
	[RPE_TRP_ID] ASC,
	[RPE_TRB_ID] ASC,
	[RPE_RAT_ID] ASC,
	[RPE_HashedErrorMessage] ASC
)
INCLUDE([RPE_LastFailureDate]) 
WHERE ([RPE_IsClosed]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReplicationErrors_ReplicationErrors_RPE_LastFailureDate#RPE_IsClosed]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ReplicationErrors_ReplicationErrors_RPE_LastFailureDate#RPE_IsClosed] ON [Activity].[ReplicationErrors]
(
	[RPE_LastFailureDate] ASC,
	[RPE_IsClosed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReplicationErrors_ReplicationErrors_RPE_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_ReplicationErrors_ReplicationErrors_RPE_Timestamp] ON [Activity].[ReplicationErrors]
(
	[RPE_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Activity].[trg_ReplicationErrors]    Script Date: 6/8/2020 1:14:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Activity].[trg_ReplicationErrors] on [Activity].[ReplicationErrors]
	instead of delete
as
set nocount on

merge Activity.ReplicationErrors d
using deleted s
	on d.RPE_ID = s.RPE_ID
	when matched and d.RPE_IsClosed = 0 then update set
											RPE_IsClosed = 1,
											RPE_ObjectDeleted = 1
	when matched and d.RPE_IsClosed = 1 then delete;
GO
ALTER TABLE [Activity].[ReplicationErrors] ENABLE TRIGGER [trg_ReplicationErrors]
GO
