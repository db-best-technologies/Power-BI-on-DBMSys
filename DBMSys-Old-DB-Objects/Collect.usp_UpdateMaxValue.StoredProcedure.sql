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
/****** Object:  StoredProcedure [Collect].[usp_UpdateMaxValue]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_UpdateMaxValue]
	@TST_ID int,
	@MOB_ID int,
	@LastValue varchar(100)
as
set nocount on
if @LastValue is not null
	if isnumeric(@LastValue) = 1
		merge Collect.TestObjectLastValues d
			using (select @TST_ID TST_ID, @MOB_ID MOB_ID, @LastValue LastValue) s
				on TOL_TST_ID = TST_ID
					and TOL_MOB_ID = MOB_ID
			when matched and cast(@LastValue as int) > cast(TOL_Value as int) then update set
								TOL_Value = LastValue
			when not matched then insert(TOL_TST_ID, TOL_MOB_ID, TOL_Value)
								values(TST_ID, MOB_ID, LastValue);
	else if isdate(@LastValue) = 1
		merge Collect.TestObjectLastValues d
			using (select @TST_ID TST_ID, @MOB_ID MOB_ID, @LastValue LastValue) s
				on TOL_TST_ID = TST_ID
					and TOL_MOB_ID = MOB_ID
			when matched and cast(@LastValue as datetime) > cast(TOL_Value as datetime) then update set
								TOL_Value = LastValue
			when not matched then insert(TOL_TST_ID, TOL_MOB_ID, TOL_Value)
								values(TST_ID, MOB_ID, LastValue);
	else
		merge Collect.TestObjectLastValues d
			using (select @TST_ID TST_ID, @MOB_ID MOB_ID, @LastValue LastValue) s
				on TOL_TST_ID = TST_ID
					and TOL_MOB_ID = MOB_ID
			when matched then update set
								TOL_Value = LastValue
			when not matched then insert(TOL_TST_ID, TOL_MOB_ID, TOL_Value)
								values(TST_ID, MOB_ID, LastValue);
GO
