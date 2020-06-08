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
/****** Object:  Table [Activity].[LogShippingErrors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[LogShippingErrors](
	[LSE_ID] [int] IDENTITY(1,1) NOT NULL,
	[LSE_ClientID] [int] NOT NULL,
	[LSE_MOB_ID] [int] NOT NULL,
	[LSE_IDB_ID] [int] NULL,
	[LSE_LSS_ID] [tinyint] NOT NULL,
	[LSE_LSA_ID] [tinyint] NOT NULL,
	[LSE_FirstOccurenceDate] [datetime2](3) NOT NULL,
	[LSE_LastOccurenceDate] [datetime2](3) NOT NULL,
	[LSE_NumberOfOccurences] [int] NOT NULL,
	[LSE_ErrorMessage] [nvarchar](max) NOT NULL,
	[LSE_ErrorMessageHashed]  AS (hashbytes('MD5',CONVERT([varchar](8000),[LSE_ErrorMessage],(0)))),
	[LSE_InsertDate] [datetime2](3) NOT NULL,
	[LSE_LastSeenDate] [datetime2](3) NOT NULL,
	[LSE_Last_TRH_ID] [int] NOT NULL,
	[LSE_Timestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_LogShippingErrors] PRIMARY KEY CLUSTERED 
(
	[LSE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_LogShippingErrors_LSE_LastOccurenceDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_LogShippingErrors_LSE_LastOccurenceDate] ON [Activity].[LogShippingErrors]
(
	[LSE_LastOccurenceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [IX_LogShippingErrors_LSE_MOB_ID#LSE_LSA_ID#LSE_ErrorMessageHashed#LSE_LastOccurenceDate#LSE_InsertDate]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LogShippingErrors_LSE_MOB_ID#LSE_LSA_ID#LSE_ErrorMessageHashed#LSE_LastOccurenceDate#LSE_InsertDate] ON [Activity].[LogShippingErrors]
(
	[LSE_MOB_ID] ASC,
	[LSE_LSA_ID] ASC,
	[LSE_ErrorMessageHashed] ASC,
	[LSE_LastOccurenceDate] ASC,
	[LSE_InsertDate] ASC,
	[LSE_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LogShippingErrors_LSE_Timestamp]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_LogShippingErrors_LSE_Timestamp] ON [Activity].[LogShippingErrors]
(
	[LSE_Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
