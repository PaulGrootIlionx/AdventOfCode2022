USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_11_SCRIPT_PART_2]    Script Date: 12/12/2022 07:24:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[DAY_11_SCRIPT_PART_2] as
begin

	set nocount on;

	declare @totalTurns int;
	set @totalTurns = 20;

	create table #monkeys (
		MonkeyNumber int primary key
		,OperationOperator nvarchar(10)
		,OperationValue nvarchar(5)
		,Test int
		,IfTrueMonkeyNumber int
		,IfFalseMonkeyNumber int
		,ItemsInspected int not null default 0
	);

	create table #items (
		ItemID int identity primary key
		,StartWorryLevel int
		,CurrentWorryLevel decimal(38,0)
		,CurrentRoundNumber int
		,StartMonkeyNumber int
		,CurrentMonkeyNumber int
	)

	--Extract input to #monkeys and #items
	declare @inputValue nvarchar(50);
	declare @type nvarchar(20);

	declare @monkeyNumber int;
	declare @itemID int;
	declare @itemWorryLevel decimal(38,0);
	declare @operationOperator nvarchar(10);
	declare @operationValue nvarchar(5);
	declare @test int;
	declare @ifTrueMonkeyNumber int;
	declare @ifFalseMonkeyNumber int;

	declare @worryDecreaser int;
	set @worryDecreaser = 1;

	declare input_cur cursor for
	select
		case
			when InputValue like 'Monkey %' then 'MonkeyNumber'
			when InputValue like '  Starting items: %' then 'StartingItems'
			when InputValue like '  Operation: new = %' then 'Operation'
			when InputValue like '  Test: divisible by %' then 'Test'
			when InputValue like '    If true: throw to monkey %' then 'IfTrue'
			when InputValue like '    If false: throw to monkey %' then 'IfFalse'
			when InputValue = '' then 'Separator'
		end as [Type]
		,case
			when InputValue like 'Monkey %' then left(right(InputValue,2),1)
			when InputValue like '  Starting items: %' then trim(substring(InputValue, 19,30))
			when InputValue like '  Operation: new = %' then trim(substring(InputValue, 20,30))
			when InputValue like '  Test: divisible by %' then trim(substring(InputValue, 22,30))
			when InputValue like '    If true: throw to monkey %' then trim(substring(InputValue, 30,30))
			when InputValue like '    If false: throw to monkey %' then trim(substring(InputValue, 31,30))
			when InputValue = '' then ''
		end as [InputValue]
	from DAY_11_INPUT
	order by
		AutoID;

	open input_cur;

	fetch next from input_cur into @type, @inputValue;

	while @@FETCH_STATUS = 0
	begin
		--Set monkey number
		if (@type = 'MonkeyNumber')
		begin
			set @monkeyNumber = @inputValue;
			insert into #monkeys (MonkeyNumber) values (@monkeyNumber);
		end;

		--Save monkey items
		if (@type = 'StartingItems')
		begin
			--Loop through input numbers
			while (@inputValue <> '')
			begin
				if (charindex(',', @inputValue) > 0)
				begin
					set @itemWorryLevel = trim(left(@inputValue, charindex(',',@inputValue)-1));
					set @inputValue = trim(substring(@inputValue, charindex(',',@inputValue)+1, 99));
				end;
				else
				begin
					set @itemWorryLevel = trim(@inputValue);
					set @inputValue = '';
				end;
				insert into #items (StartWorryLevel, CurrentWorryLevel, StartMonkeyNumber, CurrentMonkeyNumber, CurrentRoundNumber)
				values (@itemWorryLevel, @itemWorryLevel, @monkeyNumber, @monkeyNumber, 0);
			end;
		end;

		--Get operation values
		if (@type = 'Operation')
		begin
			--operation = add
			if (@inputValue like '%+%') set @operationOperator = 'ADD';
			--operation = multiply
			if (@inputValue like '%*%') set @operationOperator = 'MULTIPLY';

			--Get left inputvalue
			set @operationValue = reverse(trim(left(reverse(@inputValue), charindex(' ', reverse(@inputValue)))));

			update #monkeys set OperationOperator = @operationOperator, OperationValue = @operationValue where MonkeyNumber = @monkeyNumber;
		end;

		--Get test value
		if (@type = 'Test')
		begin
			set @worryDecreaser = @worryDecreaser * cast(@inputValue as int);
			update #monkeys set Test = @inputValue where MonkeyNumber = @monkeyNumber;
		end;

		--Get true monkey
		if (@type = 'IfTrue') update #monkeys set IfTrueMonkeyNumber = @inputValue where MonkeyNumber = @monkeyNumber;

		--Get false monkey
		if (@type = 'IfFalse') update #monkeys set IfFalseMonkeyNumber = @inputValue where MonkeyNumber = @monkeyNumber;

		fetch next from input_cur into @type, @inputValue;
	end;

	close input_cur;
	deallocate input_cur;

	--Run through rounds
	declare @turn int;
	set @turn = 1;

	declare @old decimal(38,0);
	declare @new decimal(38,0);
	declare @toMonkeyNumber int;

	while (@turn <= @totalTurns)
	begin
		print '';
		print concat('--Round ', @turn,'--');

		--Loop through monkeys
		declare monkey_cur cursor for
		select
			m.MonkeyNumber
			,m.OperationOperator
			,m.OperationValue
			,m.Test
			,IfTrueMonkeyNumber
			,IfFalseMonkeyNumber
		from #monkeys m;

		open monkey_cur;

		fetch next from monkey_cur into @monkeyNumber, @operationOperator, @operationValue, @test, @ifTrueMonkeyNumber, @ifFalseMonkeyNumber;

		while @@FETCH_STATUS = 0
		begin
			--check if the monkey currently has any items if yes, then continue
			if ((select count(*) from #items where CurrentMonkeyNumber = @monkeyNumber) > 0)
			begin
				print concat('Monkey ',@monkeyNumber,':');

				declare items_cur cursor for
				select
					ItemID
					,CurrentWorryLevel
				from #items
				where
					CurrentMonkeyNumber = @monkeyNumber
				order by
					CurrentWorryLevel;

				open items_cur;

				fetch next from items_cur into @itemID, @old;

				while @@FETCH_STATUS = 0
				begin
					print concat('  Monkey inspects an item with a worry level of  ',@old,'.');

					--multiply by old
					if (@operationOperator = 'MULTIPLY' and @operationValue = 'old')
					begin
						set @new = @old * @old;
						print concat('    Worry level is multiplied by itself to ',@new,'.');
					end
					--multiply by x
					if (@operationOperator = 'MULTIPLY' and isnumeric(@operationValue) = 1)
					begin
						set @new = @old * cast(@operationValue as int);
						print concat('    Worry level is multiplied by ',@operationValue,' to ',@new,'.');
					end
					--add with old
					if (@operationOperator = 'ADD' and @operationValue = 'old')
					begin
						set @new = @old + @old;
						print concat('    Worry level increases by itself to ',@new,'.');
					end
					--add with x
					if (@operationOperator = 'ADD' and isnumeric(@operationValue) = 1)
					begin
						set @new = @old + cast(@operationValue as int);
						print concat('    Worry level increases by ',@operationValue,' to ',@new,'.');
					end

					--Decrease worry
					set @new = floor(cast(@new as decimal(32,2)) % cast(@worryDecreaser as decimal(32,2)));
					print concat('    Monkey gets bored with item. Worry level % by ',@worryDecreaser,' to ',@new,'.');

					--Check test
					if ((@new % @test) = 0)
					begin
						set @toMonkeyNumber = @ifTrueMonkeyNumber;
						print concat('    Current worry level is divisible by ',@test,'.');
					end; 
					else
					begin
						set @toMonkeyNumber = @ifFalseMonkeyNumber;
						print concat('    Current worry level is not divisible by ',@test,'.');
					end;

					print concat('    Item with worry level ',@new,' is thrown to monkey ',@toMonkeyNumber);

					update #items
						set CurrentRoundNumber = @turn
						   ,CurrentMonkeyNumber = @toMonkeyNumber
						   ,CurrentWorryLevel = @new
					where
						ItemID = @itemID;

					update #monkeys set ItemsInspected = ItemsInspected + 1 where MonkeyNumber = @monkeyNumber;

					fetch next from items_cur into @itemID, @old;;
				end

				close items_cur;
				deallocate items_cur;

			end;

			fetch next from monkey_cur into @monkeyNumber, @operationOperator, @operationValue, @test, @ifTrueMonkeyNumber, @ifFalseMonkeyNumber;
		end;

		close monkey_cur;
		deallocate monkey_cur;

		set @turn = @turn + 1;
	end;

	declare @monkey1 int;
	declare @monkey2 int;

	select top 1
		@monkey1 = ItemsInspected
	from #monkeys
	order by
		ItemsInspected desc;

	select top 1
		@monkey2 = ItemsInspected
	from
		(select top 2
			ItemsInspected
		from #monkeys
		order by
			ItemsInspected desc) src
	order by
		ItemsInspected;

	declare @result int;

	set @result = cast(@monkey1 as decimal(32,2)) * cast(@monkey2 as decimal(32,2));

	print '';
	print concat('Result: ', @result);

	drop table #items;
	drop table #monkeys;

end
GO
