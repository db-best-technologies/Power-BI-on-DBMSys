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
/****** Object:  StoredProcedure [Internal].[usp_LogJobFailure]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Internal].[usp_LogJobFailure]
	@JobID uniqueidentifier
as
declare @Info xml,
		@ErrorMessage nvarchar(2000)

select top 1 @ErrorMessage = h.[message],
		@Info = (select 'Job Running' [@Process], j.name [@JobName], h.step_id [@StepID], h.step_name [@StepName]
					for xml path('Info'))
from msdb.dbo.sysjobhistory h
	inner join msdb.dbo.sysjobs j on h.job_id = j.job_id
where h.job_id = @JobID
	and h.step_id > 0
	and h.run_status = 0
order by h.instance_id desc

if @ErrorMessage is not null
	exec Internal.usp_LogError @Info, @ErrorMessage
GO
