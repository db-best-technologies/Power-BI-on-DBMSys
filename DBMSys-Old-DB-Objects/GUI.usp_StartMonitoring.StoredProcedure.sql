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
/****** Object:  StoredProcedure [GUI].[usp_StartMonitoring]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_StartMonitoring]
	@t	Collect.TT_SpecificTestObjects readonly
	,@IsNeedSave bit = 0
as

begin

if @IsNeedSave = 1
begin
	exec [GUI].[usp_Host_Performance_save] @t
end

BEGIN TRY
	BEGIN TRAN
		update Inventory.MonitoredObjects set MOB_OOS_ID = 6 where MOB_OOS_ID in (0,1)

		update	MOB 
		set		MOB.MOB_OOS_ID = 1
		from	Inventory.MonitoredObjects MOB
		join	Collect.SpecificTestObjects STO on MOB.MOB_ID = STO.STO_MOB_ID
		where	MOB_OOS_ID <> 3
				and STO_IsActive = 1

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK;
	THROW;
END CATCH

end
GO
