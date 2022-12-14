USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_3_SCRIPT_PART_1]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_3_SCRIPT_PART_1] as
begin;

	declare @value nvarchar(100);
	declare @splitter int;
	declare @value_left nvarchar(50);
	declare @value_right nvarchar(50);
	declare @ascii_left int;
	declare @ascii_right int;
	declare @score int;
	declare @priority int;

	declare @while_left int;
	declare @while_right int;

	set @score = 0;

	declare cur cursor for
	select
		InputValue
	from DAY_3_INPUT;

	open cur;

	fetch next from cur into @value;

	while @@FETCH_STATUS = 0
	begin
		set @splitter = len(@value)/2;

		set @value_left = left(@value, @splitter);
		set @value_right = right(@value, @splitter);

		set @priority = 0;

		--print concat('L: ', @value_left, '; R: ', @value_right);

		set @while_left = 1;

		while (@while_left <= @splitter)
		begin
			set @ascii_left = ascii(substring(@value_left, @while_left, 1));
			set @while_right = 1;

			while (@while_right <= @splitter)
			begin
				set @ascii_right = ascii(substring(@value_right, @while_right, 1));

				if (@ascii_left = @ascii_right)
				begin
					--Hoofdletters
					if (@ascii_left >=65 and @ascii_left <= 90)
					begin
						set @priority = ((@ascii_left-64)+26);
					end
					--Lage letter
					else
					begin
						set @priority = (@ascii_left-96);
					end
				end

				set @while_right = @while_right + 1;

				if (@priority > 0) break;
			end

			set @while_left = @while_left + 1;

			if (@priority > 0) break;
		end

		set @score = @score + @priority;

		--print concat(char(@ascii_left),': ', @priority, ', ', @score);

		fetch next from cur into @value;
	end

	print @score;

	close cur;
	deallocate cur;


end
GO
