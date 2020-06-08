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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_SetContactsIntoContactList]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_SetContactsIntoContactList]
	@Contacts [ResponseProcessing].[TT_ContactList_Contact_List] READONLY
AS
	DECLARE @clientID int 
	SELECT @clientID = CAST(SET_Value AS INT)
	FROM   Management.Settings
	WHERE  SET_Key ='Client ID'

	MERGE ResponseProcessing.ContactLists_Contacts t
		USING @Contacts s
		ON  s.ContactListID = CLC_CLS_ID AND s.ContactID = CLC_CON_ID
		WHEN NOT MATCHED THEN INSERT (CLC_ClientID, CLC_CLS_ID, CLC_CON_ID)
								VALUES (@clientID, s.ContactListID, s.ContactID)

		WHEN NOT MATCHED BY SOURCE THEN DELETE ;
GO
