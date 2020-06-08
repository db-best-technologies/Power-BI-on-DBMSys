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
/****** Object:  StoredProcedure [PerformanceData].[usp_ExtractCounterCombinations]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [PerformanceData].[usp_ExtractCounterCombinations]
as
;with CounterData as
		(select CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, min(CRS_DateTime) FromDate, max(CRS_DateTime) ToDate
		from PerformanceData.CounterResults
		where CRS_DateTime > DATEADD(second, -2, isnull((select max(CCB_ToDate)
															from PerformanceData.CounterCombinations), '20130101'))
		group by CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID															
		),
	MatchingRecords as
		(select CCB_FromDate, CCB_ToDate, CCB_MOB_ID, CCB_CSY_ID, CCB_CounterID, CCB_CIN_ID, CCB_IDB_ID
			from PerformanceData.CounterCombinations with (forceseek)
				inner join CounterData on CRS_MOB_ID = CCB_MOB_ID
										and CRS_SystemID = CCB_CSY_ID
										and CRS_CounterID = CCB_CounterID
										and (CRS_InstanceID = CCB_CIN_ID
												or (CRS_InstanceID is null
														and CCB_CIN_ID is null)
												)
										and (CRS_IDB_ID = CCB_IDB_ID
												or (CRS_IDB_ID is null
														and CCB_IDB_ID is null)
											)
		)
merge MatchingRecords d
	using CounterData s
		on CRS_MOB_ID = CCB_MOB_ID
			and CRS_SystemID = CCB_CSY_ID
			and CRS_CounterID = CCB_CounterID
			and (CRS_InstanceID = CCB_CIN_ID
					or (CRS_InstanceID is null
							and CCB_CIN_ID is null)
					)
			and (CRS_IDB_ID = CCB_IDB_ID
					or (CRS_IDB_ID is null
							and CCB_IDB_ID is null)
				)
	when matched and ToDate > CCB_ToDate then update set
							CCB_ToDate = ToDate
	when not matched then insert (CCB_FromDate, CCB_ToDate, CCB_MOB_ID, CCB_CSY_ID, CCB_CounterID, CCB_CIN_ID, CCB_IDB_ID)
							values(FromDate, ToDate, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID);
GO
