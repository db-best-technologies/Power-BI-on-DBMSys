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
/****** Object:  StoredProcedure [ExternalData].[GetOrderedEditions]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ExternalData].[GetOrderedEditions]
	@PLT_ID	int
AS
BEGIN
	SELECT 
		E.*
	FROM 
		Inventory.Editions AS E
		OUTER APPLY (
				SELECT TOP 1 ORI_OrdinalValue
				FROM ExternalData.OrderingInfo
				WHERE 
					E.EDT_Name like ORI_Value
					AND ORI_TableName = 'Inventory.Editions'
					AND E.EDT_PLT_ID = ORD_PLT_ID
				ORDER BY len(ORI_Value) DESC) AS O
	WHERE 
		E.EDT_PLT_ID = @PLT_ID
	ORDER BY
		O.ORI_OrdinalValue, E.EDT_Name
END
GO
