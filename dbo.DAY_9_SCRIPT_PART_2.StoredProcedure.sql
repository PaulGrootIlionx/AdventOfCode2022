USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_9_SCRIPT_PART_2]    Script Date: 09/12/2022 22:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_9_SCRIPT_PART_2] as
begin

	set nocount on;

	declare @maxKnots int = 10;
	declare @knotID int;

	--create knots table for keeping track of knots
	create table #knots (
		KnotID int
		,Symbol nvarchar(1)
		,X int
		,Y int
	);

	--insert main knot
	insert into #knots values (1,'H',1,1);
	set @knotID = 2;

	while (@knotID <= @maxKnots)
	begin
		insert into #knots values (@knotID, @knotID-1, 1,1);
		set @knotID = @knotID + 1;
	end;

	--create grid table
	create table #grid (
		X int
		,Y int
		,Symbol nvarchar(1)
		,primary key (X, Y)
	);

	--create grid log table
	create table #gridLog (
		LogId int identity primary key
		,Step int
		,SubStep int
		,X int
		,Y int
		,KnotID int
	);

	--save commands to table
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

	--Save initial grid position
	insert into #grid (X, Y, Symbol) values (1,1,'s');
	insert into #gridLog (X, Y, Step, SubStep, KnotID)
	select
		X, Y, 0, 0, KnotID
	from #knots
	order by KnotID desc

	declare @direction nvarchar(5);
	declare @step int;
	declare @currentSubStep int;
	declare @steps int;
	declare @commandID int;
	declare @maxCommandID int;

	declare @prevKnotX int;
	declare @prevKnotY int;
	declare @currentKnotX int;
	declare @currentKnotY int;
	declare @difX int;
	declare @difY int;

	set @commandID = 1;
	set @step = 1;
	select @maxCommandID = max(AutoID) from #commands;
	
	while (@commandID <= @maxCommandID)
	begin
		select @direction = Direction, @steps = Steps from #commands where AutoID = @commandID;
		set @currentSubStep = 1;
		
		--print concat('== ',@direction,' ',@steps,' ==');

		while (@currentSubStep <= @steps)
		begin
			select @currentKnotX = X, @currentKnotY = Y from #knots where KnotID = 1;
			if (@direction = 'RIGHT') set @currentKnotX = @currentKnotX + 1;
			if (@direction = 'LEFT') set @currentKnotX = @currentKnotX - 1;
			if (@direction = 'UP') set @currentKnotY = @currentKnotY + 1;
			if (@direction = 'DOWN') set @currentKnotY = @currentKnotY - 1;

			insert into #gridLog (X, Y, Step, SubStep, KnotID) values (@currentKnotX, @currentKnotY, @step, @currentSubStep, 1);
			update #knots set X = @currentKnotX, Y = @currentKnotY where KnotID = 1;
			
			set @knotID = 2;
			
			while (@knotID <= @maxKnots)
			begin

				--Save settings from previous knot
				set @prevKnotX = @currentKnotX;
				set @prevKnotY = @currentKnotY;
				--Select next T knot
				select @currentKnotX = X, @currentKnotY = Y from #knots where KnotID = @knotID;

				--check difference H/T
				set @difX = @prevKnotX - @currentKnotX;
				set @difY = @prevKnotY - @currentKnotY;

				--print concat('current knot: ', @knotID,' - DifX: ',@difX, ' - DifY: ',@difY);

				--only x movement right
				if (@difX > 1 and @difY = 0) set @currentKnotX = @currentKnotX + 1;
				--only x movement left
				if (@difX < -1 and @difY = 0) set @currentKnotX = @currentKnotX - 1;
				--only y movement up
				if (@difX = 0 and @difY > 1) set @currentKnotY = @currentKnotY + 1;
				--only y movement down
				if (@difX = 0 and @difY < -1) set @currentKnotY = @currentKnotY - 1;
				--diagonal up right right
				if (@difX > 1 and @difY = 1) begin set @currentKnotX = @currentKnotX + 1; set @currentKnotY = @currentKnotY + 1; end;
				--diagonal up up right
				if (@difX = 1 and @difY > 1) begin set @currentKnotX = @currentKnotX + 1; set @currentKnotY = @currentKnotY + 1; end;
				--diagonal up up right right
				if (@difX > 1 and @difY > 1) begin set @currentKnotX = @currentKnotX + 1; set @currentKnotY = @currentKnotY + 1; end;
				--diagonal up left left
				if (@difX < -1 and @difY = 1) begin set @currentKnotX = @currentKnotX - 1; set @currentKnotY = @currentKnotY + 1; end;
				--diagonal up up left left
				if (@difX < -1 and @difY > 1) begin set @currentKnotX = @currentKnotX - 1; set @currentKnotY = @currentKnotY + 1; end;
				--diagonal up up left
				if (@difX = -1 and @difY > 1) begin set @currentKnotX = @currentKnotX - 1; set @currentKnotY = @currentKnotY + 1; end;
				--diagonal down right right
				if (@difX > 1 and @difY = -1) begin set @currentKnotX = @currentKnotX + 1; set @currentKnotY = @currentKnotY - 1; end;
				--diagonal down down right
				if (@difX = 1 and @difY < -1) begin set @currentKnotX = @currentKnotX + 1; set @currentKnotY = @currentKnotY - 1; end;
				--diagonal down down right right
				if (@difX > 1 and @difY < -1) begin set @currentKnotX = @currentKnotX + 1; set @currentKnotY = @currentKnotY - 1; end;
				--diagonal down left left
				if (@difX < -1 and @difY = -1) begin set @currentKnotX = @currentKnotX - 1; set @currentKnotY = @currentKnotY - 1; end;
				--diagonal down down left
				if (@difX = -1 and @difY < -1) begin set @currentKnotX = @currentKnotX - 1; set @currentKnotY = @currentKnotY - 1; end;
				--diagonal down down left left
				if (@difX < -1 and @difY < -1) begin set @currentKnotX = @currentKnotX - 1; set @currentKnotY = @currentKnotY - 1; end;

				insert into #gridLog (X, Y, Step, SubStep, KnotID) values (@currentKnotX, @currentKnotY, @step, @currentSubStep, @knotID);
				update #knots set X = @currentKnotX, Y = @currentKnotY where KnotID = @knotID;

				set @knotID = @knotID + 1;
			end

			--Grid bijwerken
			insert into #grid (X, Y, Symbol)
			select
				gl.X, gl.Y, '.'
			from #gridLog gl
			where
				not exists (select null from #grid g where g.X = gl.X and g.Y = gl.Y);

			--Testing purposes
			/*update #grid set Symbol = '.';
			update g
				set Symbol = k.Symbol
			from #grid g
			join #gridLog l
				on g.X = l.X
				and g.Y = l.Y
			join #knots k
				on l.KnotID = k.KnotID
			where
				l.Step = @step
				and l.SubStep = @currentSubStep;
			update g
				set Symbol = k.Symbol
			from #grid g
			join #gridLog l
				on g.X = l.X
				and g.Y = l.Y
			join #knots k
				on l.KnotID = k.KnotID
			where
				l.Step = @step
				and l.SubStep = @currentSubStep;
				and k.KnotID = 1;*/

			set @currentSubStep = @currentSubStep + 1;
		end

		--print '';
		set @commandID = @commandID + 1;
		set @step = @step + 1;
	end;

	--display grid
	declare @x int;
	declare @y int;
	declare @minX int;
	declare @minY int;
	declare @maxX int;
	declare @maxY int;
	declare @printValue nvarchar(4000);
	
	set @minX = (select min(X) from #grid);
	set @maxX = (select max(X) from #grid);
	set @minY = (select min(Y) from #grid);
	set @maxY = (select max(Y) from #grid);

	set @y = @maxY;

	--reset all symbols
	update #grid set Symbol = '.';

	--Set only where knot 9 (id 10) has been
	update g
		set Symbol = '#'
	from #grid g
	join #gridLog l
		on g.X = l.X
		and g.Y = l.Y
	where
		l.KnotID = 10;

	update #grid set Symbol = 's' where X = 1 and Y = 1;

	while (@y >= @minY)
	begin
		set @x = @minX;
		set @printValue = '';

		while (@x <= @maxX)
		begin
			set @printValue = concat(@printValue, isnull((select Symbol from #grid where X = @x and Y = @y),'.'));
			set @x = @x + 1;
		end
		print @printValue;
		set @y = @y -1;
	end

	declare @result int;

	select @result = count(*) from (select X, Y from #gridLog where KnotID = 10 group by X, Y) src;

	print '';
	print concat('The tail (9) visits ',@result,' positions (including s) at least once.');

	drop table #knots;
	drop table #commands
	drop table #grid;
	drop table #gridLog;

end;
GO
