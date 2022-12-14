USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_10_SCRIPT_PART_2]    Script Date: 10/12/2022 07:47:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_10_SCRIPT_PART_2] as
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

	create table #screen (
		RowID int identity
		,ScreenValue nvarchar(40)
	);

	declare @x int;
	declare @screenValue nvarchar(40);
	declare @spritePosition nvarchar(40);
	declare @spriteX int;

	set @spritePosition = '###.....................................';
	set @x = 0;

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
		print concat('Start cycle ',right(concat('  ',@cycle),3),': begin executing ',@instruction,' ',@instructionValue);
		print concat('During cycle',right(concat('  ',@cycle),3),': CRT draws pixel in position ',@x);

		if (substring(@spritePosition, (@x+1),1) = '#')
		begin
			set @screenValue = concat(@screenValue,'#');
		end;
		else
		begin
			set @screenValue = concat(@screenValue,'.');
		end;
		print concat('Current CRT row: ',@screenValue);
		print '';

		set @signalStrength = @cycle * @valueX;
		insert into #cycles (CycleNumber, InstructionValue, ValueX, SignalStrength)
		values (@cycle, @instructionValue, @valueX, @signalStrength);
		set @cycle = @cycle + 1;
		set @x = @x + 1;

		--draw screen row if @x>39, reset screenvalue
		if (@x > 39)
		begin
			insert into #screen (ScreenValue) values (@screenValue);
			set @screenValue = '';
			set @x = 0;
		end;
		
		if (@instruction = 'addx')
		begin
			print concat('During cycle',right(concat('  ',@cycle),3),': CRT draws pixel in position ',@x);

			if (substring(@spritePosition, (@x+1),1) = '#')
			begin
				set @screenValue = concat(@screenValue,'#');
			end;
			else
			begin
				set @screenValue = concat(@screenValue,'.');
			end;
			print concat('Current CRT row: ',@screenValue);
			
			set @signalStrength = @cycle * @valueX;
			insert into #cycles (CycleNumber, InstructionValue, ValueX, SignalStrength)
			values (@cycle, @instructionValue, @valueX, @signalStrength);
			set @cycle = @cycle + 1;
			set @x = @x + 1;
			set @valueX = @valueX + @instructionValue;
			print concat('End of cycle',right(concat('  ',@cycle),3),': finish executing addx ',@instructionValue, ' (Register X is now ',@valueX,')');
			--set new sprite position
			set @spriteX = 0;
			set @spritePosition = '';
			while (@spriteX < 40)
			begin
				if (@spriteX in (@valueX-1,@valueX,@valueX+1)) set @spritePosition = concat(@spritePosition,'#');
				else set @spritePosition = concat(@spritePosition,'.');
				set @spriteX = @spriteX+1;
			end;
			print concat('Sprite position: ', @spritePosition);
			--draw screen row if @x>39, reset screenvalue
			if (@x > 39)
			begin
				insert into #screen (ScreenValue) values (@screenValue);
				set @screenValue = '';
				set @x = 0;
			end;
		end;
		if (@instruction = 'noop')
		begin
			print concat('End of cycle',right(concat('  ',@cycle-1),3),': finish executing noop');
			print '';
		end

		fetch next from cur into @instruction, @instructionValue, @cyclesCost;
	end

	--insert last
	set @signalStrength = @cycle * @valueX;
	insert into #cycles (CycleNumber, InstructionValue, ValueX, SignalStrength)
	values (@cycle, @instructionValue, @valueX, @signalStrength);
	set @cycle = @cycle + 1;

	close cur;
	deallocate cur;

	--draw screen

	declare pix_cur cursor for
	select
		ScreenValue
	from #screen
	order by
		RowID;

	open pix_cur;

	fetch next from pix_cur into @screenValue;

	while @@FETCH_STATUS = 0
	begin
		--Puntjes verwijderen voor leesbaarheid
		print replace(@screenValue,'.',' ');

		fetch next from pix_cur into @screenValue;
	end;

	close pix_cur;
	deallocate pix_cur;

	drop table #cycles;
	drop table #screen;

end;
GO
