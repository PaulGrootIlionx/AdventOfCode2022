USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_5_SCRIPT_PART_1]    Script Date: 05/12/2022 16:39:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_5_SCRIPT_PART_1] as
begin;

	set nocount on;

	select
		*
	into #stacks
	from DAY_5_INITIAL_LAYOUT;
	
	declare @amount int;
	declare @from int;
	declare @to int;
	declare @amount_moved int;
	declare @crate nvarchar(1);
	declare @crateID int;

	declare cur cursor for
	select
		replace(substring(InputValue, 6, 2),' ','') as [amount],
		substring(InputValue, (12 + len(replace(substring(InputValue, 6, 2),' ',''))), 1) as [from],
		substring(InputValue, (17 + len(replace(substring(InputValue, 6, 2),' ',''))), 1) as [to]
	from DAY_5_INPUT
	order by
		AutoID;

	open cur;

	fetch next from cur into @amount, @from, @to;

	while @@FETCH_STATUS = 0
	begin
		set @amount_moved = 0;
		while (@amount_moved < @amount)
		begin
			--Get crate
			select top 1 @crateID = AutoId, @crate = StackValue from #stacks where StackNr = @from order by AutoID desc;
			--Remote crate from stack
			delete from #stacks where AutoID = @crateID;
			--Insert crate into new stack
			insert into #stacks (StackNr, StackValue) values (@to, @crate);
			set @amount_moved = @amount_moved + 1;
		end

		fetch next from cur into @amount, @from, @to;
	end;

	close cur;
	deallocate cur;

	select
		StackNr
		,StackValue
		,row_number() over (partition by StackNr order by AutoID desc) as Position
	into #result
	from #stacks
	order by
		StackNr;

	declare @result nvarchar(20);

	set @result =  (select top 1 StackValue from #result where StackNr = 1 and Position = 1);
	set @result = @result + (select top 1 StackValue from #result where StackNr = 2 and Position = 1)
	set @result = @result + (select top 1 StackValue from #result where StackNr = 3 and Position = 1)
	set @result = @result + (select top 1 StackValue from #result where StackNr = 4 and Position = 1)
	set @result = @result + (select top 1 StackValue from #result where StackNr = 5 and Position = 1)
	set @result = @result + (select top 1 StackValue from #result where StackNr = 6 and Position = 1)
	set @result = @result + (select top 1 StackValue from #result where StackNr = 7 and Position = 1)
	set @result = @result + (select top 1 StackValue from #result where StackNr = 8 and Position = 1)
	set @result = @result + (select top 1 StackValue from #result where StackNr = 9 and Position = 1)

	print @result;

	drop table #stacks;
	drop table #result;
end
GO
