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
/****** Object:  UserDefinedFunction [RuleChecks].[fn_PredictDataFileSize]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [RuleChecks].[fn_PredictDataFileSize](@DBF_ID int,
													@FromDate date,
													@ToDate date,
													@Buffer int = 20) returns table
as

return with DBStats as
		(select DBF_ID, fs.ResultValue FileSize, fus.ResultValue FileUsedSize,
				(fus.ResultValue - isnull(hfus.ResultValue, fus.ResultValue))/(datediff(minute, hfus.SnapshotDate, fus.SnapshotDate)/24./60) DailyGrowth
			from Inventory.DatabaseFiles
				cross apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, DBF_MOB_ID, 3, 41, DBF_FileName, DBF_IDB_ID, default, default) fs
				outer apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, DBF_MOB_ID, 3, 42, DBF_FileName, DBF_IDB_ID, default, default) fus
				outer apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, DBF_MOB_ID, 3, 42, DBF_FileName, DBF_IDB_ID, fus.SnapshotDate, fus.ResultValue) hfus
			where DBF_ID = @DBF_ID
				and DBF_DFT_ID = 0
		)
	, Predicion as
		(select FileSize, FileUsedSize, DailyGrowth,
				FileUsedSize + DailyGrowth*365 SizeIn1Year,
				FileUsedSize + DailyGrowth*365*2 SizeIn2Years,
				FileUsedSize + DailyGrowth*365*3 SizeIn3Years
			from DBStats
		)
	select cast(FileSize as bigint) FileSize,
			cast(case when FileSize > SizeIn1Year + SizeIn1Year*(@Buffer/100.)
					then FileSize
					else SizeIn1Year + SizeIn1Year*(@Buffer/100.)
				end as bigint) SizeIn1Year,
			cast(case when FileSize > SizeIn2Years + SizeIn2Years*(@Buffer/100.)
					then FileSize
					else SizeIn2Years + SizeIn2Years*(@Buffer/100.)
				end as bigint) SizeIn2Years,
			cast(case when FileSize > SizeIn3Years + SizeIn3Years*(@Buffer/100.)
					then FileSize
					else SizeIn3Years + SizeIn3Years*(@Buffer/100.)
				end as bigint) SizeIn3Years
		from Predicion
GO
