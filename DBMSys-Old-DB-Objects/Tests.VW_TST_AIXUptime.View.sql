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
/****** Object:  View [Tests].[VW_TST_AIXUptime]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_AIXUptime]
as
select top 0 CAST(null as varchar(20)) Column1,
			CAST(null as varchar(20)) Column2,
			CAST(null as varchar(20)) Column3,
			CAST(null as varchar(20)) Column4,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AIXUptime]    Script Date: 6/8/2020 1:15:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_AIXUptime] on [Tests].[VW_TST_AIXUptime]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

declare @LastRebootDate datetime,
	@TRH_ID int

if exists (select * from inserted where Column4 = '')
	select @TRH_ID = Metadata_TRH_ID,
		@LastRebootDate = cast(Column1 + ' ' + Column2 + ' ' + cast(year(getdate()) as char(4)) + ' ' + Column3 as datetime)
	from inserted
else
	select @TRH_ID = Metadata_TRH_ID,
		@LastRebootDate = cast(Column1 + ' ' + Column2 + ' ' + Column3 + ' ' + Column4 as datetime)
	from inserted

if @LastRebootDate > GETDATE()
	set @LastRebootDate = DATEADD(year, -1, getdate())

update Inventory.OSServers
set OSS_LastBootUpTime = @LastRebootDate
from Collect.TestRunHistory
where TRH_ID = @TRH_ID
	and TRH_MOB_ID = OSS_MOB_ID
GO
