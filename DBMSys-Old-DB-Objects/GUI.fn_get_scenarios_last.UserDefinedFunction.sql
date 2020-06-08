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
/****** Object:  UserDefinedFunction [GUI].[fn_get_scenarios_last]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [GUI].[fn_get_scenarios_last] (@HST_ID INT)
returns table 
as
return (
WITH ProcessStepsForScenarios AS
(
 SELECT * FROM 
 (
  SELECT 1 as PSS_ID UNION ALL
  SELECT 2   UNION ALL
  SELECT 4   UNION ALL
  SELECT 5   UNION ALL
  SELECT 6   UNION ALL
  SELECT 8   UNION ALL
  SELECT 10   UNION ALL
  SELECT 14   UNION ALL
  SELECT 15 
 )T
 WHERE exists (select * from Consolidation.HostTypes where HST_ID = @HST_ID and HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0)
 UNION ALL

 SELECT * FROM 
 (
 SELECT 1 as PSS_ID UNION ALL
 SELECT 5   UNION ALL
 SELECT 6   UNION ALL
 SELECT 11
 )T
 WHERE exists (select * from Consolidation.HostTypes where HST_ID = @HST_ID and HST_IsCloud = 1 and HST_IsPerSingleDatabase = 1) 
 UNION ALL

 SELECT * FROM
 (
  SELECT 1 as PSS_ID UNION ALL
  SELECT 4   UNION ALL
  SELECT 5   UNION ALL
  SELECT 8   UNION ALL
  SELECT 9   UNION ALL
  SELECT 10   UNION ALL
  SELECT 12   UNION ALL
  SELECT 13  
 )T
 WHERE exists (select * from Consolidation.HostTypes where HST_ID = @HST_ID and HST_IsCloud = 0)
 UNION ALL
 SELECT PSP_ID as PSS_ID FROM CapacityPlanningWizard.ProcessSteps WHERE @HST_ID = 0
)
,

 History AS
(
 select PSP_ID , PSP_Ordinal, PSP_Name,
  case when PRH_StartDate is null then 'Never ran'
    when PRH_EndDate is null then 'In progress'
    when PRH_ErrorMessage is not null then 'Error [' + PSP_Name + ']'
    else 'Completed'
   end [Status]
   ,PRH_EndDate
 from CapacityPlanningWizard.ProcessSteps
  outer apply (select top 1 PRH_StartDate, PRH_EndDate, PRH_ErrorMessage
      from CapacityPlanningWizard.ProcessStepsRunHistory
      where PRH_PSP_ID = PSP_ID
      order by PRH_ID desc) h
  join ProcessStepsForScenarios on PSP_ID = PSS_ID
 where PSP_IsActive = 1
)
, Final as
(
SELECT 
  MAX(convert(char(19), PRH_EndDate, 121)) as Res
FROM History
WHERE Status = 'Completed'
  and not exists (SELECT 
        *
      FROM History
      WHERE Status <> 'Completed'
      )

UNION ALL
SELECT 
  TOP 1 Status as Res
FROM History
WHERE Status <> 'Completed'
order by PSP_ID
)
select 
  *
from Final where Res is not null
)
GO
