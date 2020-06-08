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
/****** Object:  StoredProcedure [Consolidation].[usp_EliminateCloudExpensiveOptions]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_EliminateCloudExpensiveOptions]
	@Reset bit = 1,
	@i_HST_ID int = null,
	@ComprehensiveAlgorithmThreshold bit = 200,
	@MaxBlockMachinesToConsider int = 25
as

set nocount on

declare @Init bit = 1,
		@BlockID int,
		@BlockMachines int,
		@BlocksLeft int,
		@S_BlockID varchar(10),
		@S_SourceMachineID varchar(10),
		@S_Price decimal(15, 3),
		@S_MachineSerial bigint,
		@S_BlockMachines int,
		@TotalSerialBin bigint,
		@Continue bit,
		@HST_ID int,
		@Edition tinyint,
		@TotalBlocks int,
		@rn int,
		@IsOdd bit,
		@SQL nvarchar(max)

if object_id('tempdb..#CouldBeEvenCheaper') is not null
	drop table #CouldBeEvenCheaper
if object_id('tempdb..#recOdd') is not null
	drop table #recOdd
if object_id('tempdb..#recEven') is not null
	drop table #recEven
if object_id('tempdb..#RecInput') is not null
	drop table #RecInput

if @Reset = 1
	truncate table Consolidation.CloudCheaperAlternatives

update Consolidation.ConsolidationBlocks
set CLB_DLR_ID = null
from Consolidation.HostTypes
where HST_ID = CLB_HST_ID
	and HST_IsCloud = 1
	and HST_IsConsolidation = 1
	and CLB_DLR_ID = 1
	and (CLB_HST_ID = @i_HST_ID
					or @i_HST_ID is null
					) 

;with Combinations as
		(select CLB_HST_ID HostType, isnull(PSH_CHE_ID, 0) Edition, cast(CLB_ID as varchar(10)) BlockID, PSH_ID MachineID, cast(CBL_LBL_ID as varchar(10)) SourceMachineID,
				ISNULL(CLB_BasePriceWithSQLLicensePerMonthUSD, CLB_BasePricePerMonthUSD) + isnull(CLB_PricePerDisk, 0) Price,
				COUNT(*) over(partition by CLB_ID) BlockMachines,
				ROW_NUMBER() over (partition by CLB_ID order by CBL_LBL_ID) MachineSerial
			from Consolidation.ConsolidationBlocks
				inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
				inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
				inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
			where HST_IsCloud = 1
				and HST_IsConsolidation = 1
				and CLB_DLR_ID is null
				and CBL_DLR_ID is null
				and (CLB_HST_ID = @i_HST_ID
					or @i_HST_ID is null
					)
		)
select HostType, Edition, BlockID S_BlockID, SourceMachineID S_SourceMachineID, Price S_Price, MachineSerial S_MachineSerial, BlockMachines S_BlockMachines, 0 IsDeleted
into #RecInput
from Combinations
where not exists (select *
					from Consolidation.CloudCheaperAlternatives
					where CCA_CLB_ID = BlockID)

create unique clustered index IX_#RecInput1 on #RecInput(S_SourceMachineID, S_Price, S_BlockID)
create unique index IX_#RecInput_S_BlockID##S_MachineSerial on #RecInput(S_BlockID, S_MachineSerial) include(HostType, Edition, S_SourceMachineID, S_Price)
create unique index IX_#RecInput_HostType#Edition#S_SourceMachineID#S_Price#S_BlockID on #RecInput(HostType, Edition, S_SourceMachineID, S_Price, S_BlockID)
create index IX_#RecInput_IsDeleted#S_BlockID on #RecInput(IsDeleted, S_BlockID)

create table #recOdd
	(Blocks varchar(200) collate database_default,
		RunningPrice decimal(15, 3),
		SerialBinSum bigint)

create table #recEven
	(Blocks varchar(200) collate database_default,
		RunningPrice decimal(15, 3),
		SerialBinSum bigint)

select @TotalBlocks = count(*)
from (select distinct HostType, Edition, S_BlockID, S_BlockMachines
			from #RecInput a
			where IsDeleted = 0) t

truncate table Consolidation.CloudCheaperAlternatives

update #RecInput
set IsDeleted = 1
where S_BlockMachines > @MaxBlockMachinesToConsider

declare cBlocks cursor static forward_only for
	select *, row_number() over (order by (select 1)) rn
	from (select distinct HostType, Edition, S_BlockID, S_BlockMachines
			from #RecInput a
			where IsDeleted = 0) t
	order by S_BlockMachines desc, S_BlockID

open cBlocks
fetch next from cBlocks into @HST_ID, @Edition, @BlockID, @BlockMachines, @rn
while @@FETCH_STATUS = 0
begin
	set @BlocksLeft = @TotalBlocks - @rn
	if @BlocksLeft%100 = 0 or @rn = 1
		raiserror('Blocks left = %d, Block machines = %d', 0, 0, @BlocksLeft, @BlockMachines) with nowait

	if object_id('tempdb..#BlockRecInput') is not null
		drop table #BlockRecInput
	
	select b.S_BlockID, b.S_SourceMachineID, b.S_Price, power(cast(2 as bigint), a.S_MachineSerial - 1) S_MachineSerial
	into #BlockRecInput
	from #RecInput a with (forceseek)
		cross apply (select b.S_BlockID, b.S_SourceMachineID, b.S_Price
						from #RecInput b 
						where a.HostType = b.HostType
								and a.Edition = b.Edition
								and a.S_SourceMachineID = b.S_SourceMachineID
								and a.S_Price > b.S_Price
								and a.S_BlockID <> b.S_BlockID) b
	where a.S_BlockID = cast(@BlockID as varchar(10))

	create unique clustered index IX_#BlockRecInput on #BlockRecInput(S_SourceMachineID, S_BlockID)
	create unique index IX_#BlockRecInput1 on #BlockRecInput(S_BlockID, S_SourceMachineID)

	if (select count(distinct S_SourceMachineID)
			from #BlockRecInput) = @BlockMachines
	begin
		if object_id('tempdb..#UBlocks2') is not null
			drop table #UBlocks2
		if object_id('tempdb..#UBlocks1') is not null
			drop table #UBlocks1
		if object_id('tempdb..#UBlocks') is not null
			drop table #UBlocks

		select cast(S_BlockID as int) BlockID, S_Price Price, count(*) MachineCount, S_BlockID sBlockID, cast(SUM(S_MachineSerial) as bigint) MachineBin
		into #UBlocks2
		from #BlockRecInput
		group by S_BlockID, S_Price

		create unique index IX_#UBlocks2 on #UBlocks2(MachineBin, Price, BlockID) include(MachineCount)

		select *
		into #UBlocks1
		from #UBlocks2 a
		where not exists (select *
								from #UBlocks2 b with (forceseek)
								where a.BlockID <> b.BlockID
									and b.MachineBin >= a.MachineBin
									and b.MachineBin & a.MachineBin = a.MachineBin
									and (b.Price < a.Price
											or (b.Price = a.Price
													and (b.BlockID < a.BlockID
															or b.MachineCount > a.MachineCount
														)
												)
										)
							)

		select top 0 *
		into #UBlocks
		from #UBlocks1

		if (select COUNT(*) from #UBlocks1) > @ComprehensiveAlgorithmThreshold
		begin
			create unique index IX_#UBlocks1 on #UBlocks1(MachineBin, Price, BlockID) include(MachineCount)

			insert into #UBlocks
			select *
			from #UBlocks1 a
			where not exists (select *
									from #UBlocks1 b
									where a.BlockID <> b.BlockID
										and b.MachineBin >= a.MachineBin
										and b.MachineBin & a.MachineBin = a.MachineBin
										and (b.Price < a.Price
												or (b.Price = a.Price
														and b.BlockID < a.BlockID
													)
												or b.MachineCount > a.MachineCount
											)
								)
		end
		else
			insert into #UBlocks
			select *
			from #UBlocks1

		create unique clustered index IX_#UBlocks on #UBlocks(BlockID)
		create unique index IX_#UBlocks1 on #UBlocks(MachineBin, Price, BlockID) include(MachineCount)
		create unique index IX_#UBlocks2 on #UBlocks(MachineBin, BlockID) include(Price, MachineCount, sBlockID)

		declare cMachines cursor static forward_only for
			select S_BlockID, S_SourceMachineID, S_Price, power(cast(2 as bigint), S_MachineSerial - 1), S_BlockMachines, power(cast(2 as bigint), S_BlockMachines - 1)*2 - 1 TotalSerialBin
			from #RecInput
			where S_BlockID = cast(@BlockID as varchar(10))
			order by S_MachineSerial

		set @Continue = 1
		open cMachines
		fetch next from cMachines into @S_BlockID, @S_SourceMachineID, @S_Price, @S_MachineSerial, @S_BlockMachines, @TotalSerialBin
		while @@FETCH_STATUS = 0
			and @Continue = 1
		begin
			set @Continue = 1
			set @IsOdd = cast(log(@S_MachineSerial)/log(2) as int)%2

			set @SQL =
			'if @S_MachineSerial = 1
			begin
				truncate table ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + '
				insert into ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + '
				select cast('','' + ri.sBlockID + '','' as varchar(200)) Blocks, ri.Price RunningPrice, MachineBin
				from #UBlocks ri with (index=IX_#UBlocks2)
				where ri.MachineBin >= @S_MachineSerial
					and ri.MachineBin & @S_MachineSerial = @S_MachineSerial
			end
			else
			begin
				truncate table ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + '
				
				insert into ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + '
				select cast(r.Blocks + ri.sBlockID + '','' as varchar(200)) Blocks,
						cast(r.RunningPrice + ri.Price as decimal(15, 3)) RunningPrice,
						r.SerialBinSum | ri.MachineBin SerialBinSum
				from ' + iif(@IsOdd = 1, '#recEven', '#recOdd') + ' r
					inner join #UBlocks ri  with (index=IX_#UBlocks2) on ri.MachineBin >= @S_MachineSerial
																			and ri.MachineBin & @S_MachineSerial = @S_MachineSerial
				where  r.RunningPrice < cast(@S_Price - ri.Price as decimal(15, 3))
					and r.SerialBinSum & ((@S_MachineSerial*2 - 1) ^ @S_MachineSerial) = ((@S_MachineSerial*2 - 1) ^ @S_MachineSerial)
					and r.SerialBinSum & @S_MachineSerial = 0

				insert into ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + '
				select *
				from ' + iif(@IsOdd = 1, '#recEven', '#recOdd') + '
				where SerialBinSum & @S_MachineSerial = @S_MachineSerial

			end
			if exists (select * from ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + ')
			begin
				insert into Consolidation.CloudCheaperAlternatives
				select top 1 @S_BlockID, @S_Price, Blocks, RunningPrice, @S_MachineSerial, @HST_ID, @Edition
				from ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + '
				where SerialBinSum & @TotalSerialBin = @TotalSerialBin

				if @@ROWCOUNT > 0
					set @Continue = 0
			end

			if @Continue = 1
			begin
				if not exists (select *
								from ' + iif(@IsOdd = 1, '#recOdd', '#recEven') + '
								where SerialBinSum & @S_MachineSerial = @S_MachineSerial)
					set @Continue = 0
			end'
			exec sp_executesql @SQL,
								N'@S_BlockID varchar(10),
									@S_SourceMachineID varchar(10),
									@S_Price decimal(15, 3),
									@S_MachineSerial bigint,
									@S_BlockMachines int,
									@TotalSerialBin bigint,
									@HST_ID tinyint,
									@Edition tinyint,
									@Continue bit output',
									@S_BlockID = @S_BlockID,
									@S_SourceMachineID = @S_SourceMachineID,
									@S_Price = @S_Price,
									@S_MachineSerial = @S_MachineSerial,
									@S_BlockMachines = @S_BlockMachines,
									@TotalSerialBin = @TotalSerialBin,
									@HST_ID = @HST_ID,
									@Edition = @Edition,
									@Continue = @Continue output

			fetch next from cMachines into @S_BlockID, @S_SourceMachineID, @S_Price, @S_MachineSerial, @S_BlockMachines, @TotalSerialBin
		end
		close cMachines
		deallocate cMachines
	end

	if not exists (select *
					from Consolidation.CloudCheaperAlternatives
					where CCA_CLB_ID = @S_BlockID)
		insert into Consolidation.CloudCheaperAlternatives(CCA_CLB_ID)
		values(@BlockID)

	update #RecInput
	set IsDeleted = 1
	where S_BlockID = cast(@BlockID as varchar(10))

	fetch next from cBlocks into @HST_ID, @Edition, @BlockID, @BlockMachines, @rn
end
close cBlocks
deallocate cBlocks

select CCA_HST_ID HostType, CCA_CHE_ID Edition, CCA_CLB_ID SourceBlockID, CCA_OriginalPrice OriginalPrice, CCA_BlockCode BlockCode, CCA_RunningPrice RunningPrice
into #CouldBeEvenCheaper
from Consolidation.CloudCheaperAlternatives c
where c.CCA_OriginalPrice is not null
	and exists (select *
				from Consolidation.CloudCheaperAlternatives c1 with (forceseek, index=IX_CloudCheaperAlternatives_CCA_HST_ID#CCA_CHE_ID##CCA_BlockCode#CCA_CLB_ID###CCA_OriginalPrice_IS_NOT_NULL)
				where c1.CCA_HST_ID = c.CCA_HST_ID
					and c1.CCA_CHE_ID = c.CCA_CHE_ID
					and (c1.CCA_BlockCode like '%,' + cast(c.CCA_CLB_ID as varchar(15)) + ',%'
							or c.CCA_BlockCode like '%,' + cast(c1.CCA_CLB_ID as varchar(15)) + ',%')
					and c1.CCA_OriginalPrice is not null
					and c.CCA_CLB_ID <> c1.CCA_CLB_ID
			)

set @Init = 1

while @@ROWCOUNT > 0
	or @Init = 1
begin
	if @Init = 1
		set @Init = 0

	update c
	set RunningPrice = c.OriginalPrice - c1.OriginalPrice + c1.RunningPrice,
		BlockCode = replace(c.BlockCode, ',' + cast(c1.SourceBlockID as varchar(15)) + ',', c1.BlockCode)
	from #CouldBeEvenCheaper c
		cross apply (select top 1 *
						from #CouldBeEvenCheaper c1
						where c.HostType = c1.HostType
							and c.Edition = c1.Edition
							and c.BlockCode like '%,' + cast(c1.SourceBlockID as varchar(15)) + ',%') c1
	where c.RunningPrice > c.OriginalPrice - c1.OriginalPrice + c1.RunningPrice
end

update c
set CCA_RunningPrice = c1.RunningPrice,
	c.CCA_BlockCode = BlockCode
from Consolidation.CloudCheaperAlternatives c
	inner join #CouldBeEvenCheaper c1 on c1.SourceBlockID = c.CCA_CLB_ID
										and c1.RunningPrice < c.CCA_RunningPrice
where CCA_RunningPrice is not null

;with ExpensiveBlocks as
	(select b.CCA_CLB_ID SourceBlockID
		from Consolidation.CloudCheaperAlternatives b
		where b.CCA_RunningPrice is not null
			and not exists (select * --Don't remove blocks that are the cheapest possibillity for other blocks
							from Consolidation.CloudCheaperAlternatives b1
								cross apply Infra.fn_SplitString(b1.CCA_BlockCode, ',')
							where b1.CCA_RunningPrice is not null
								and b.CCA_CLB_ID = cast(Val as int)
						)
	)
update Consolidation.ConsolidationBlocks
set CLB_DLR_ID = 1
where exists (select *
					from ExpensiveBlocks
					where SourceBlockID = CLB_ID
				)

select @@ROWCOUNT BlocksEliminated
GO
