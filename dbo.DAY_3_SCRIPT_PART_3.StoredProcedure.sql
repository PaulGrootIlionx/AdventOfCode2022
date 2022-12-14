USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_3_SCRIPT_PART_3]    Script Date: 04/12/2022 14:44:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_3_SCRIPT_PART_3] as
begin;

	declare @elfID int;
	declare @maxID int;
	declare @value1 nvarchar(100);
	declare @value2 nvarchar(100);
	declare @value3 nvarchar(100);
	declare @i1 int;
	declare @i2 int;
	declare @i3 int;
	declare @ascii1 int;
	declare @ascii2 int;
	declare @ascii3 int;

	declare @score int;
	declare @priority int;

	set @score = 0;

	select @maxID = max(AutoID) from DAY_3_INPUT
	set @elfID = 1;

	while (@elfID <= @maxID)
	begin
		select @value1 = InputValue from DAY_3_INPUT where AutoID = @elfID;
		select @value2 = InputValue from DAY_3_INPUT where AutoID = @elfID + 1;
		select @value3 = InputValue from DAY_3_INPUT where AutoID = @elfID + 2;

		--print concat('Set #', @elfID, ': ', @value1);

		set @i1 = 1;

		--Loop door input 1 heen
		while (@i1 <= len(@value1))
		begin
			set @ascii1 = ascii(substring(@value1, @i1, 1));

			--print concat('- ',char(@ascii1));

			--Reset values
			set @i2 = 1;
			set @priority = 0;

			--Controleren of er een zelfde waarde is bij de tweede elf dmv loop
			while (@i2 <= len(@value2))
			begin
				set @ascii2 = ascii(substring(@value2, @i2, 1));

				--Als waarde 1 = waarde 2: dan controleren of deze ook in waarde 3 voorkomt dmv loop
				if (@ascii1 = @ascii2)
				begin
					set @i3 = 1;

					while (@i3 <= len(@value3))
					begin
						set @ascii3 = ascii(substring(@value3, @i3, 1));

						--Als waarde 2 = waarde 3, dan priority bepalen en while loops sluiten
						if (@ascii2 = @ascii3)
						begin
							--Hoofdletters
							if (@ascii3 >=65 and @ascii3 <= 90)
							begin
								set @priority = ((@ascii3-64)+26);
							end
							--Lage letter
							else
							begin
								set @priority = (@ascii3-96);
							end

							break;
						end

						set @i3 = @i3 + 1;
						--loop sluiten als priority > 0
						if (@priority > 0) break;
					end
				end

				set @i2 = @i2 + 1;
				--loop sluiten als priority > 0
				if (@priority > 0) break;
			end

			set @i1 = @i1 + 1;
			--loop sluiten als priority > 0
			if (@priority > 0) break;
		end;

		set @score = @score + @priority;

		set @elfID = @elfID + 3;
	end

	print @score;

end
GO
