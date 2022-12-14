USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_4_SCRIPT_PART_2]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_4_SCRIPT_PART_2] as
begin;

	set nocount on;

	declare @score int = 0;

	declare @pairID int;
	declare @elf1 nvarchar(5);
	declare @elf2 nvarchar(5);

	declare @start int
	declare @end int;

	create table #temp (
		AutoID int identity
		,PairID int
		,ElfID int
		,Val int
	);

	declare cur cursor for
	select
		AutoID,
		left(InputValue, charindex(',',InputValue)-1) Elf1,
		substring(InputValue, charindex(',',InputValue)+1,5) Elf2
	from DAY_4_INPUT;

	open cur;

	fetch next from cur into @pairID, @elf1, @elf2;

	while @@FETCH_STATUS = 0
	begin
		--Elf 1
		set @start = left(@elf1,charindex('-',@elf1)-1);
		set @end = substring(@elf1,charindex('-',@elf1)+1,3);

		while (@start <= @end)
		begin
			insert into #temp (PairID, ElfID, Val) values (@pairID, 1, @start);
			set @start = @start + 1;
		end

		--Elf 2
		set @start = left(@elf2,charindex('-',@elf2)-1);
		set @end = substring(@elf2,charindex('-',@elf2)+1,3);

		while (@start <= @end)
		begin
			insert into #temp (PairID, ElfID, Val) values (@pairID, 2, @start);
			set @start = @start + 1;
		end

		fetch next from cur into @pairID, @elf1, @elf2;
	end

	close cur;
	deallocate cur;

	select
		@score = count(*)
	from
		(select
			elf_1.PairID, elf_1.ElfID as Elf_1, elf_2.ElfID as Elf_2, count(*) as Counts
		from #temp elf_1
		join #temp elf_2
			on elf_1.PairID = elf_2.PairID
		where
			elf_1.ElfID = 1
			and elf_2.ElfID = 2
			and elf_1.Val = elf_2.Val
		group by
			elf_1.PairID, elf_1.ElfID, elf_2.ElfID) src;

	drop table #temp;

	print @score;
end
GO
