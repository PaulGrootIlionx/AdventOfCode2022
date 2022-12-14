USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_5_SCRIPT_PART_2]    Script Date: 05/12/2022 16:39:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_5_SCRIPT_PART_2] as
begin;

	set nocount on;

	select
		StackNr
		,StackValue
		,row_number() over (partition by StackNr order by AutoID) as Position
	into #stacks
	from DAY_5_INITIAL_LAYOUT;
	
	declare @amount int;
	declare @from int;
	declare @to int;
	declare @amount_moved int;
	declare @crate nvarchar(1);
	declare @crateID int;
	declare @position_old int;
	declare @position_new int;

	declare cur cursor for
	select
		replace(substring(InputValue, 6, 2),' ','') as [amount],
		substring(InputValue, (12 + len(replace(substring(InputValue, 6, 2),' ',''))), 1) as [from],
		substring(InputValue, (17 + len(replace(substring(InputValue, 6, 2),' ',''))), 1) as [to]
	from DAY_5_INPUT
	order by
		AutoID;

	--select * from #stacks order by StackNr, Position;

	open cur;

	fetch next from cur into @amount, @from, @to;

	while @@FETCH_STATUS = 0
	begin
		set @amount_moved = 0;

		print concat('Move ', @amount,' from ',@from, ' to ', @to);
		
		--get minimum position from from-stack
		set @position_old = (select max(Position) from #stacks where StackNr = @from) - @amount;
		set @position_new = (select max(Position) from #stacks where StackNr = @to);

		--select * from #stacks where StackNr = @from and Position > @position_old;

		--insert stack into new stack
		insert into #stacks (StackValue, StackNr, Position)
		select
			StackValue
			,@to as StackNr
			,(row_number() over (order by Position)) + isnull(@position_new,0) as Position
		from #stacks
		where
			StackNr = @from
			and Position > @position_old;

		--remove from old stack
		delete from #stacks where StackNr = @from and Position > @position_old

		--select * from #stacks order by StackNr, Position;

		fetch next from cur into @amount, @from, @to;
	end;

	close cur;
	deallocate cur;

	select
		StackNr
		,StackValue
		,row_number() over (partition by StackNr order by Position desc) as Position
	into #result
	from #stacks
	order by
		StackNr;

	declare @result nvarchar(20);

	set @result =  isnull((select top 1 StackValue from #result where StackNr = 1 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 2 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 3 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 4 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 5 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 6 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 7 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 8 and Position = 1),'');
	set @result = @result + isnull((select top 1 StackValue from #result where StackNr = 9 and Position = 1),'');

	print @result;

	--select * from #stacks order by StackNr, Position;

	drop table #stacks;
	drop table #result;
end
GO
