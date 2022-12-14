USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_9_SCRIPT_PART_1]    Script Date: 09/12/2022 14:07:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_9_SCRIPT_PART_1] as
begin

	set nocount on;

	declare @direction nvarchar(5);
	declare @steps int;

	select
		AutoID
		,case left(InputValue,1)
			when 'R' then 'RIGHT'
			when 'L' then 'LEFT'
			when 'U' then 'UP'
			when 'D' then 'DOWN'
		end as Direction
		,cast(trim(substring(InputValue, charindex(' ',InputValue),99)) as int) as Steps
	into #commands
	from DAY_9_INPUT;

	create table #grid (
		X int
		,Y int
		,visitsHead int not null default 0
		,visitsTail int not null default 0
		,symbol nvarchar(1)
	);

	--calculate max x and y
	declare @x int = 1;
	declare @y int = 1;
	declare @maxX int;
	declare @maxY int;
	declare @startX int;
	declare @startY int;

	set @startX = 1;
	set @startY = 1;

	declare @xH int;
	declare @yH int;
	declare @xT int;
	declare @yT int;
	declare @xH_new int;
	declare @yH_new int;
	declare @xT_new int;
	declare @yT_new int;
	declare @currentStep int;

	declare @difX int;
	declare @difY int;

	declare @printValue nvarchar(255);
	declare @printMessage nvarchar(255);

	set @xH = @startX;
	set @yH = @startY;
	set @xT = @startX;
	set @yT = @startY;

	--startpositie vastleggen
	insert into #grid (X, Y, visitsHead, visitsTail) values (1,1,1,1);
	--update #grid set visitsHead = 1, visitsTail = 1 where X = @xH and Y = @yH;

	set @xH_new = @xH;
	set @yH_new = @yH;
	set @xT_new = @xT;
	set @yT_new = @yT;

	declare cur cursor for
	select Direction, Steps from #commands order by AutoID;

	open cur;

	fetch next from cur into @direction, @steps;

	while @@FETCH_STATUS = 0
	begin
		set @currentStep = 1;

		--print concat('== ',@direction, ' ', @steps, ' ==');

		while (@currentStep <= @steps)
		begin
			if (@direction = 'RIGHT') set @xH_new = @xH + 1;
			if (@direction = 'LEFT') set @xH_new = @xH - 1;
			if (@direction = 'UP') set @yH_new = @yH + 1;
			if (@direction = 'DOWN') set @yH_new = @yH - 1;

			set @printMessage = '';

			--check difference H/T
			set @difX = @xH_new - @xT;
			set @difY = @yH_new - @yT;

			--only x movement right
			if (@difX > 1 and @difY = 0) set @xT_new = @xT + 1;
			--only x movement left
			if (@difX < -1 and @difY = 0) set @xT_new = @xT - 1;
			--only y movement up
			if (@difX = 0 and @difY > 1) set @yT_new = @yT + 1;
			--only y movement down
			if (@difX = 0 and @difY < -1) set @yT_new = @yT - 1;
			--diagonal up right right
			if (@difX > 1 and @difY = 1) begin set @xT_new = @xT + 1; set @yT_new = @yT + 1; end;
			--diagonal up up right
			if (@difX = 1 and @difY > 1) begin set @xT_new = @xT + 1; set @yT_new = @yT + 1; end;
			--diagonal up left left
			if (@difX < -1 and @difY = 1) begin set @xT_new = @xT - 1; set @yT_new = @yT + 1; end;
			--diagonal up up left
			if (@difX = -1 and @difY > 1) begin set @xT_new = @xT - 1; set @yT_new = @yT + 1; end;
			--diagonal down right right
			if (@difX > 1 and @difY = -1) begin set @xT_new = @xT + 1; set @yT_new = @yT - 1; end;
			--diagonal down down right
			if (@difX = 1 and @difY < -1) begin set @xT_new = @xT + 1; set @yT_new = @yT - 1; end;
			--diagonal down left left
			if (@difX < -1 and @difY = -1) begin set @xT_new = @xT - 1; set @yT_new = @yT - 1; end;
			--diagonal down down left
			if (@difX = -1 and @difY < -1) begin set @xT_new = @xT - 1; set @yT_new = @yT - 1; end;

			update #grid set symbol = '.';
			update #grid set symbol = '#' where visitsHead > 0 and visitsTail > 0;
			update #grid set symbol = 's' where X = @startX and Y = @startY;

			--create grid position if it does not exist
			if ((select count(*) from #grid where X = @xT_new and Y = @yT_new) = 0) insert into #grid (X, Y) values (@xT_new, @yT_new);
			if ((select count(*) from #grid where X = @xH_new and Y = @yH_new) = 0) insert into #grid (X, Y) values (@xH_new, @yH_new);

			--set tail (only if tail has changed)
			if (@xT <> @xT_new or @yT <> @yT_new) update #grid set symbol = 'T', visitsTail = visitsTail + 1 where X = @xT_new and Y = @yT_new;
			else update #grid set symbol = 'T' where X = @xT_new and Y = @yT_new;

			--set head
			update #grid set symbol = 'H', visitsHead = visitsHead + 1 where X = @xH_new and Y = @yH_new;

			if (@xH_new = @xT_new and @yH_new = @yT_new) set @printMessage = '  (H covers T)';

			set @xH = @xH_new;
			set @yH = @yH_new;
			set @xT = @xT_new;
			set @yT = @yT_new;

			set @currentStep = @currentStep + 1;
		end;

		fetch next from cur into @direction, @steps;
	end;

	close cur;
	deallocate cur;

	update #grid set symbol = '.';
	update #grid set symbol = '#' where visitsHead > 0 and visitsTail > 0;
	update #grid set symbol = 's' where X = @startX and Y = @startY;

	print '== RESULT ==';

	--draw grid
	declare @minX int;
	declare @minY int;

	select @minX = min(X) from #grid;
	select @maxX = max(X) from #grid;
	select @minY = min(Y) from #grid;
	select @maxY = max(Y) from #grid;

	set @y = @maxY;
	while (@y >= @minY)
	begin
		set @x = @minX;
		set @printValue = '';
		while @x <= @maxX
		begin
			if ((select count(*) from #grid where X = @x and Y = @y) > 0) select @printValue = concat(@printValue,symbol) from #grid where X = @x and Y = @y;
			else set @printValue = concat(@printValue,'.');
			set @x = @x + 1;
		end
		print @printValue;
		set @y = @y - 1
	end

	declare @result int;
	select @result = count(*) from #grid where visitsHead > 0 and visitsTail > 0

	print '';
	print concat('There are ', @result,' positions the tail visited at least once.')

	drop table #commands;
	drop table #grid;

end;
GO
