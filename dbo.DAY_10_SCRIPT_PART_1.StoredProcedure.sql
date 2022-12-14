USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_10_SCRIPT_PART_1]    Script Date: 10/12/2022 07:47:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_10_SCRIPT_PART_1] as
begin

	set nocount on;

	create table #cycles (
		CycleNumber int
		,InstructionValue int
		,ValueX int
		,SignalStrength int
	);

	declare @instruction nvarchar(4);
	declare @instructionValue int;
	declare @cyclesCost int;
	declare @valueX int;
	declare @cycle int;
	declare @signalStrength int;

	set @valueX = 1;
	set @cycle = 1;

	declare cur cursor for
	select
		case
			when charindex(' ',InputValue) > 0 then trim(left(InputValue, charindex(' ',InputValue)))
			else InputValue
		end as [instruction]
		,case
			when charindex(' ',InputValue) > 0 then cast(trim(substring(InputValue, charindex(' ',InputValue), 99)) as int)
			else cast(null as int)
		end as [instructionValue]
		,case
			when InputValue like 'addx%' then 2
			else 1
		end as [cyclesCost]
	from DAY_10_INPUT
	order by
		AutoID;

	open cur;

	fetch next from cur into @instruction, @instructionValue, @cyclesCost;

	while @@FETCH_STATUS = 0
	begin
		set @signalStrength = @cycle * @valueX;
		insert into #cycles (CycleNumber, InstructionValue, ValueX, SignalStrength)
		values (@cycle, @instructionValue, @valueX, @signalStrength);
		set @cycle = @cycle + 1;
		
		if (@instruction = 'addx')
		begin
			set @signalStrength = @cycle * @valueX;
			insert into #cycles (CycleNumber, InstructionValue, ValueX, SignalStrength)
			values (@cycle, @instructionValue, @valueX, @signalStrength);
			set @cycle = @cycle + 1;
			set @valueX = @valueX + @instructionValue;
		end;

		fetch next from cur into @instruction, @instructionValue, @cyclesCost;
	end

	--insert last
	set @signalStrength = @cycle * @valueX;
	insert into #cycles (CycleNumber, InstructionValue, ValueX, SignalStrength)
	values (@cycle, @instructionValue, @valueX, @signalStrength);
	set @cycle = @cycle + 1;

	close cur;
	deallocate cur;

	select
		sum(SignalStrength)
	from #cycles
	where
		CycleNumber in (20, 60, 100, 140, 180, 220);

	drop table #cycles;

end;
GO
