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
/****** Object:  View [Tests].[VW_TST_DatabaseMailFailures]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_DatabaseMailFailures]
as
select top 0 CAST(null as int) log_id,
			CAST(null as datetime) FirstDate,
			CAST(null as datetime) LastDate,
			CAST(null as int) EventCount,
			CAST(null as nvarchar(max)) [description],
			CAST(null as varchar(max)) recipients,
			CAST(null as nvarchar(128)) send_request_user,
			CAST(null as int) sent_account_id,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabaseMailFailures]    Script Date: 6/8/2020 1:16:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_DatabaseMailFailures] on [Tests].[VW_TST_DatabaseMailFailures]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@TST_ID int,
		@LastValue varchar(100)

select top 1 @TST_ID = TRH_TST_ID,
			@MOB_ID = TRH_MOB_ID
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Activity.DatabaseMailRecipients d
	using (select distinct recipients
			from inserted
			where recipients is not null) s
		on DMR_RecipientsHashed = hashbytes('MD5',left(CONVERT(varchar(max),recipients,0),(8000)))
	when not matched then insert(DMR_Recipients)
							values(recipients);

merge Activity.DatabaseMailSendRequestUser d
	using (select distinct send_request_user
			from inserted
			where send_request_user is not null) s
		on SRU_Name = send_request_user
	when not matched then insert(SRU_Name)
							values(send_request_user);

merge Activity.DatabaseMailFailures d
	using (select Metadata_ClientID, FirstDate, LastDate, EventCount, [description], DMR_ID, SRU_ID, sent_account_id
			from inserted
				left join Activity.DatabaseMailRecipients on DMR_RecipientsHashed = hashbytes('MD5',left(CONVERT(varchar(max),recipients,0),(8000)))
				left join Activity.DatabaseMailSendRequestUser on SRU_Name = send_request_user
			where [description] is not null
				and [description] <>  'Message sent OK'
			) s
		on DMF_IsClosed = 0
			and DMF_MOB_ID = @MOB_ID
			and (DMF_AccountID = sent_account_id
					or (DMF_AccountID is null
						and sent_account_id is null)
					)
			and (DMF_DMR_ID = DMR_ID
					or (DMF_DMR_ID is null
						and DMR_ID is null)
					)
	when matched then update
						set DMF_LastFailureDate = LastDate,
							DMF_FailureCount += EventCount
	when not matched then insert(DMF_ClientID, DMF_MOB_ID, DMF_AccountID, DMF_DMR_ID, DMF_SRU_ID, DMF_FirstFailureDate, DMF_LastFailureDate,
									DMF_FailureCount,  DMF_LastErrorMessage, DMF_IsClosed)
							values(Metadata_ClientID, @MOB_ID, sent_account_id, DMR_ID, SRU_ID, FirstDate, LastDate, EventCount, [description], 0);

update Activity.DatabaseMailFailures
set DMF_IsClosed = 1,
	DMF_FirstSuccessDate = FirstDate,
	DMF_LastSuccessDate = LastDate,
	DMF_SuccessCount = EventCount
from inserted
where [description] =  'Message sent OK'
		and DMF_IsClosed = 0
		and DMF_MOB_ID = @MOB_ID
		and (DMF_AccountID = sent_account_id
				or (DMF_AccountID is null
						and sent_account_id is null)
				)

select @LastValue = cast(log_id as varchar(100))
from inserted
where [description] is null

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
