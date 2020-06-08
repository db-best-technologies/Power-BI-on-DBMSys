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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_ContactListManagement]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_ContactListManagement]
@ContactListID INT OUTPUT
,@Name VARCHAR(255) 
,@isDelete bit = 0
AS
	DECLARE @clientID int 
	SELECT @clientID=CAST(SET_Value AS INT)
	FROM   Management.Settings
	WHERE  SET_Key ='Client ID'

	IF EXISTS (select top 1 1 from ResponseProcessing.ContactLists where CLS_Name = @Name AND CLS_ID <> @ContactListID)
		BEGIN
			RAISERROR ('Group with name %s already exists', 16,3, @Name)
			RETURN
		END

	IF(@Name IS NULL)
				BEGIN
					RAISERROR ('Name could not be empty', 16,3)
					RETURN
				END

	IF(@ContactListID IS NOT NULL)
		BEGIN
			DECLARE @GroupName VARCHAR(255)
			SELECT TOP 1 @GroupName=CLS_Name FROM  ResponseProcessing.ContactLists WHERE CLS_ID = @ContactListID
			
			IF OBJECT_ID('tempdb..#temp') is not null
			DROP TABLE #temp

			SELECT ESP_ID, g.groupName INTO #temp
			FROM ResponseProcessing.EventSubscriptions
			OUTER APPLY (SELECT groupName
					FROM
					(
						SELECT 					
						Name = t.n.value('@Name', 'varchar(500)')
						,groupName = t.n.value ('@Value', 'varchar(500)')
						FROM ESP_Parameters.nodes('/Parameters/Parameter') as t(n)
					) AS T
					WHERE Name = 'Contact Lists') AS G
			WHERE G.groupName = @GroupName
		END

	DECLARE  @ids TABLE
	(ID INT NULL)

	IF(@ContactListID IS NULL)
		BEGIN
		
			INSERT INTO ResponseProcessing.ContactLists (CLS_ClientID, CLS_Name) 
						OUTPUT INSERTED.CLS_ID INTO @ids(ID)
			VALUES (@clientID, @Name);

			SELECT TOP 1 @ContactListID=ID FROM @ids
		END
		
	ELSE IF(@isDelete = 1)
		BEGIN
		
			DELETE FROM ResponseProcessing.EventSubscriptions
			WHERE  ESP_ID IN (SELECT ESP_ID FROM #temp)


			DELETE FROM ResponseProcessing.ContactLists_Contacts
			WHERE CLC_CLS_ID = @ContactListID

			DELETE FROM ResponseProcessing.ContactLists
			WHERE CLS_ID = @ContactListID

		END

	ELSE 
		BEGIN	
			UPDATE ResponseProcessing.ContactLists
			SET 
				 CLS_Name = ISNULL(@Name,CLS_Name)				
			WHERE CLS_ID = @ContactListID

				UPDATE ResponseProcessing.EventSubscriptions
				SET 
					ESP_Parameters.modify('  replace value of (/Parameters/Parameter[1]/@Value)[1]   
  with     sql:variable("@Name")')
				WHERE ESP_ID IN (SELECT ESP_ID FROM #temp)
		END
GO
