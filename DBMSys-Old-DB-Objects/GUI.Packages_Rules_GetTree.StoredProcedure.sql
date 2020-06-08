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
/****** Object:  StoredProcedure [GUI].[Packages_Rules_GetTree]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[Packages_Rules_GetTree]
AS
BEGIN
	WITH R (Item_ID, Item_Name, Parent_Item_Name, Is_Package) AS
	(
		SELECT
			CAST(P.PKG_ID AS int) AS Item_ID,
			CAST(P.PKG_Name AS varchar(200)) AS Item_Name, 
			CAST(NULL AS varchar(200)) AS Parent_Item_Name,
			CAST(1 AS bit) AS Is_Package
		FROM
			BusinessLogic.Packages AS P
		UNION ALL
		SELECT
			BR.RUL_ID AS Item_ID,
			CAST(BR.RUL_Name AS varchar(200)) AS Item_Name,
			CAST(R.Item_Name AS varchar(200)) AS Parent_Item_Name,
			CAST(0 AS bit) AS Is_Package
		FROM
			BusinessLogic.Packages_Rules AS RC
			INNER JOIN BusinessLogic.Rules AS BR
			ON BR.RUL_ID = RC.PKR_RUL_ID
			INNER JOIN R
			ON RC.PKR_PKG_ID = R.Item_ID
			AND R.Is_Package = 1
	)
	SELECT * FROM R
END
GO
