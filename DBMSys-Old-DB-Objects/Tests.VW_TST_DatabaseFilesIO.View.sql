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
/****** Object:  View [Tests].[VW_TST_DatabaseFilesIO]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_DatabaseFilesIO]
AS
SELECT TOP 0 cast(null as nvarchar(900)) InstanceName,
			cast(null as nvarchar(128)) DatabaseName,
			cast(null as decimal(28, 5)) NumOfReads,
			cast(null as decimal(28, 5)) NumOfBytesRead,
			cast(null as decimal(28, 5)) ReadLatency,
			cast(null as decimal(28, 5)) NumOfWrites,
			cast(null as decimal(28, 5)) NumOfBytesWritten,
			cast(null as decimal(28, 5)) WriteLatency,
			cast(null as decimal(28, 5)) NumOfTransfers,
			cast(null as decimal(28, 5)) NumOfBytesTransfered,
			cast(null as decimal(28, 5)) Latency,
			cast(null as decimal(28, 5)) MillisecondsBetweenCollections,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabaseFilesIO]    Script Date: 6/8/2020 1:15:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_DatabaseFilesIO] on [Tests].[VW_TST_DatabaseFilesIO]
	instead of insert
as
set nocount on

;with Total as
		(select isnull(InstanceName, '_Total') InstanceName, NumOfReads, NumOfBytesRead, ReadLatency, NumOfWrites, NumOfBytesWritten, WriteLatency,
				NumOfTransfers, NumOfBytesTransfered, Latency, MillisecondsBetweenCollections, Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from inserted
		),
		Input as
		(select 'Database Files IO' as Category, 'Reads/sec' as [Counter], InstanceName, NumOfReads, Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total
			union all
			select 'Database Files IO'as Category, 'Bytes Read/sec' as [Counter], InstanceName, NumOfBytesRead, Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total				  
			union all				  
			select 'Database Files IO'as Category, 'Avg. sec/Read' as [Counter], InstanceName, isnull(ReadLatency, MillisecondsBetweenCollections/(NumOfReads + 1))/1000., Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total				  
			union all				  
			select 'Database Files IO'as Category, 'Writes/sec' as [Counter], InstanceName, NumOfWrites, Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total				  
			union all				  
			select 'Database Files IO'as Category, 'Bytes Written/sec' as [Counter], InstanceName, NumOfBytesWritten, Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total				 
			union all				 
			select 'Database Files IO'as Category, 'Avg. sec/Write' as [Counter], InstanceName, isnull(WriteLatency, MillisecondsBetweenCollections/(NumOfWrites + 1))/1000., Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total				 
			union all				 
			select 'Database Files IO'as Category, 'Transfers/sec' as [Counter], InstanceName, NumOfTransfers, Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total				 
			union all				 
			select 'Database Files IO'as Category, 'Bytes Transferred/sec' as [Counter], InstanceName, NumOfBytesTransfered, Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total				  
			union all				  
			select 'Database Files IO'as Category, 'Avg. sec/Transfer' as [Counter], InstanceName, isnull(Latency, MillisecondsBetweenCollections/(NumOfTransfers + 1))/1000., Metadata_TRH_ID, Metadata_ClientID, DatabaseName
			from Total
		)
		
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID, DatabaseName)
select * from Input
GO
