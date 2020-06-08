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
/****** Object:  UserDefinedFunction [RuleChecks].[fn_GetLastPerformanceCounterValue]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [RuleChecks].[fn_GetLastPerformanceCounterValue](@FromDate datetime2(3),
													@ToDate datetime2(3),
													@MOB_ID int,
													@SystemID tinyint,
													@CounterID int,
													@InstanceName varchar(900) = null,
													@IDB_ID int = null,
													@BeforeDate datetime2(3) = null,
													@LessOrEqualToValue decimal(18, 5) = null) returns table
as
	return (select top 1 CRS_DateTime SnapshotDate, CIN_Name InstanceName, CRS_Value ResultValue, CRT_Name ResultStatus
						from PerformanceData.CounterResults with (forceseek)
							left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
							left join PerformanceData.CounterResultStatuses on CRT_ID = CRS_CRT_ID
						where CRS_DateTime between @FromDate and @ToDate
								and CRS_MOB_ID = @MOB_ID
								and CRS_SystemID = @SystemID
								and CRS_CounterID = @CounterID
								and (@IDB_ID is null
										or CRS_IDB_ID = @IDB_ID)
								and (@InstanceName is null
										or CIN_Name = @InstanceName)
								and (@BeforeDate is null
										or CRS_DateTime < @BeforeDate)
								and (@LessOrEqualToValue is null
										or CRS_Value <= @LessOrEqualToValue)
						order by CRS_DateTime desc)
GO
