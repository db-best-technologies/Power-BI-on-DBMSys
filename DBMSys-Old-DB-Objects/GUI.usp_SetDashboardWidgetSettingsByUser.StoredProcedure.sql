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
/****** Object:  StoredProcedure [GUI].[usp_SetDashboardWidgetSettingsByUser]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_SetDashboardWidgetSettingsByUser]
--DECLARE
		@DUS_ID					 INT = NULL OUTPUT
		,@DUS_Name				 NVARCHAR(255)
		,@DUS_DWT_ID			 INT
		,@DUS_DWP_ID			 INT
		,@DUS_USR_ID			 INT
		,@DUS_CSY_ID			 INT = NULL
		,@DUS_CounteID			 INT = NULL
		,@DUS_IntervalTime		 INT
		,@DUS_IntervalPeriod	 NVARCHAR(4)
		,@DUS_DCT_ID			 INT = 2	--AVG
		,@MOBID_LIST			 GUI.MonitoredobjectInstance READONLY
		,@DUS_ThresholdType		 CHAR	= NULL
		,@DUS_ThresholdPerc		 FLOAT  = NULL
		,@DUS_NegativeType		 CHAR	= NULL
		,@DUS_NegativeValue		 FLOAT	= NULL
		,@DUS_NeutralType		 CHAR	= NULL
		,@DUS_NeutralValue		 FLOAT	= NULL
		,@DUS_PositiveType		 CHAR	= NULL
		,@DUS_PositiveValue		 FLOAT	= NULL
		,@DCC_ID				 INT	= NULL
		,@DUS_Height			 FLOAT	= 0.0
		,@DUS_Width				 FLOAT	= 0.0
AS

--SET @DUS_DCT_ID = ISNULL(@DUS_DCT_ID,2)	--AVG

DECLARE @T Table
(
	ID	INT
)
IF @DUS_ID IS NULL
BEGIN

	DECLARE @OrderID INT = 0
	SELECT 
			@OrderID = ISNULL(MAX(DUS_OrderID),0) + 1 
	FROM	GUI.DashboardWidgetsUserSettings 
	WHERE	DUS_USR_ID = @DUS_USR_ID


	INSERT	INTO GUI.DashboardWidgetsUserSettings(DUS_Name,DUS_DWT_ID,DUS_DWP_ID,DUS_USR_ID,DUS_CSY_ID,DUS_CounteID,DUS_IntervalTime,DUS_IntervalPeriod,DUS_DCT_ID,DUS_ThresholdType,DUS_ThresholdPerc,DUS_NegativeType,DUS_NegativeValue,DUS_NeutralType,DUS_NeutralValue,DUS_PositiveType,DUS_PositiveValue,DUS_DCC_ID,DUS_OrderID,DUS_Width,DUS_Height)
	OUTPUT	inserted.DUS_ID into @T(ID)
	SELECT	@DUS_Name,@DUS_DWT_ID,@DUS_DWP_ID, @DUS_USR_ID,@DUS_CSY_ID,@DUS_CounteID,@DUS_IntervalTime,@DUS_IntervalPeriod,@DUS_DCT_ID,@DUS_ThresholdType,@DUS_ThresholdPerc,@DUS_NegativeType,@DUS_NegativeValue,@DUS_NeutralType,@DUS_NeutralValue,@DUS_PositiveType,@DUS_PositiveValue,@DCC_ID,@OrderID,ISNULL(@DUS_Width,0.0),ISNULL(@DUS_Height,0.0)
	SELECT @DUS_ID = ID FROM @T
END
ELSE
	UPDATE	GUI.DashboardWidgetsUserSettings
	SET		DUS_Name				= @DUS_Name				
			,DUS_DWT_ID				= @DUS_DWT_ID			
			,DUS_DWP_ID				= @DUS_DWP_ID
			,DUS_USR_ID				= @DUS_USR_ID			
			,DUS_CSY_ID				= @DUS_CSY_ID			
			,DUS_CounteID			= @DUS_CounteID			
			,DUS_IntervalTime		= @DUS_IntervalTime		
			,DUS_IntervalPeriod		= @DUS_IntervalPeriod	
			,DUS_DCT_ID				= @DUS_DCT_ID	
			,DUS_ThresholdType		= @DUS_ThresholdType	
			,DUS_ThresholdPerc		= @DUS_ThresholdPerc	
			,DUS_NegativeType		= @DUS_NegativeType	
			,DUS_NegativeValue		= @DUS_NegativeValue	
			,DUS_NeutralType		= @DUS_NeutralType	
			,DUS_NeutralValue		= @DUS_NeutralValue	
			,DUS_PositiveType		= @DUS_PositiveType	
			,DUS_PositiveValue		= @DUS_PositiveValue	
			,DUS_DCC_ID				= @DCC_ID
			,DUS_Width				= @DUS_Width
			,DUS_Height				= @DUS_Height
			
	WHERE	DUS_ID = @DUS_ID

DELETE FROM GUI.DashboradWidgetHostsInstances WHERE DWH_DUS_ID = @DUS_ID 
INSERT INTO GUI.DashboradWidgetHostsInstances (DWH_DUS_ID, DWH_MOB_ID, DWH_CIN_ID)
SELECT 
		@DUS_ID
		,MOI_MOB_ID 
		,MOI_CIN_ID 
FROM	@MOBID_LIST
GO
