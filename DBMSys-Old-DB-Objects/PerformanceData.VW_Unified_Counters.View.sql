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
/****** Object:  View [PerformanceData].[VW_Unified_Counters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [PerformanceData].[VW_Unified_Counters]
AS
	SELECT
		T.SystemID, T.CounterID, UCI.UCI_ID AS UCounterID, T.CategoryName, T.CounterName, UFT.UFT_ID AS UCounterType, UFT.UFT_Name AS UCounterName, 
		T.IsAggregative, T.IgnoreIfValueIsOrUnder, T.PerformanceGroupID, PLT.PLT_ID, PLT.PLT_Name, UCI.UCI_DivideBy, UCI.UCI_ConstantValue, UFT.UFT_IsRead, PC.PLC_ID, PC.PLC_Name AS Platform_Category
	FROM
		PerformanceData.UnifiedCounterImplementations AS UCI
		INNER JOIN PerformanceData.UnifiedCounterTypes AS UFT
			ON UCI.UCI_UFT_ID = UFT.UFT_ID
		INNER JOIN PerformanceData.UnifiedCounterCategories AS UCO
			ON UFT.UFT_UCO_ID = UCO.UCO_ID
		INNER JOIN Management.PlatformTypes AS PLT
			ON UCI.UCI_PLT_ID = PLT.PLT_ID
		INNER JOIN PerformanceData.VW_Counters AS T
			ON UCI.UCI_SystemID = T.SystemID
				AND T.CounterID = UCI.UCI_CounterID
		INNER JOIN Management.PlatformCategories AS PC
			ON PC.PLC_ID = PLT.PLT_PLC_ID
GO
