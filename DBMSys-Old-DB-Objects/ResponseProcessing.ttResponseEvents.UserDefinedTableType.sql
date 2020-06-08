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
/****** Object:  UserDefinedTableType [ResponseProcessing].[ttResponseEvents]    Script Date: 6/8/2020 1:14:31 PM ******/
CREATE TYPE [ResponseProcessing].[ttResponseEvents] AS TABLE(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TRE_ID] [int] NOT NULL,
	[EventDescription] [nvarchar](1000) NOT NULL,
	[ClientID] [int] NOT NULL,
	[IsClosed] [bit] NOT NULL,
	[MOB_ID] [int] NOT NULL,
	[EventInstanceName] [varchar](850) NULL,
	[OpenDate] [datetime2](3) NOT NULL,
	[CloseDate] [datetime2](3) NULL,
	[EventMessage] [nvarchar](max) NULL,
	[AllEventData] [xml] NULL,
	[TimesProcessed] [int] NOT NULL,
	[EventTimestamp] [binary](8) NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[TRE_ID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
