USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_13_SCRIPT_PART_2]    Script Date: 13/12/2022 23:33:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_13_SCRIPT_PART_2] as
begin

	set nocount on;

	create table #result (
		ResultID int identity primary key
		,Packet nvarchar(255)
	);

	create table #workList (
		WorkListID int identity primary key
		,Packet nvarchar(255)
	);

	declare @valueLeft nvarchar(255);
	declare @valueRight nvarchar(255);

	insert into #workList (Packet)
	select
		InputValue
	from DAY_13_INPUT
	where
		InputValue <> ''
	union all
	select '[[2]]'
	union all
	select '[[6]]';

	declare @loopNumber int = 1;
	declare @loop bit = 1;
	declare @currentId int;
	declare @maxID int;
	declare @return_value int;

	select @maxID = max(WorkListID) from #workList

	print concat('Records to check: ',@maxID);

	while (@loop = 1)
	begin
		declare @check int = (select count(*) from #workList);
		print concat('== Loop: ',@loopNumber,' records: ',@check,' ==');
		truncate table #result;
		set @loop = 0;
		set @currentId = 2;

		select @valueLeft = Packet from #workList where WorkListID = 1;

		while (@currentId <= @maxID)
		begin
			select @valueRight = Packet from #workList where WorkListID = @currentId;

			exec @return_value = dbo.sp_D13P1_comparePairs @valueLeft, N'JSON', @valueRight, N'JSON', 1;

			--left is smaller than right
			if (@return_value = 1)
			begin
				insert into #result (Packet) values (@valueLeft);
				set @valueLeft = @valueRight;
			end
			--right is smaller than left
			if (@return_value = 2)
			begin
				insert into #result (Packet) values (@valueRight);
				set @loop = 1;
			end

			set @currentId = @currentId + 1;
		end;

		if ((select count(*) from #result where Packet = @valueLeft) = 0)
		begin
			insert into #result (Packet) values (@valueLeft);
		end;

		--refresh worklist
		truncate table #workList;
		insert into #workList (Packet)
		select
			Packet
		from (
		select
			min(ResultID) ResultID, Packet
		from #result
		group by
			Packet) src
		order by
			ResultID;

		set @loopNumber = @loopNumber + 1;
	end;

	--select * from #result;
	declare @resultTwo int;
	select @resultTwo = ResultID from #result where Packet = '[[2]]';
	declare @resultSix int;
	select @resultSix = ResultID from #result where Packet = '[[6]]';
	declare @output int;

	set @output = @resultTwo * @resultSix;

	print @output;

	drop table #result;
	drop table #workList;

end;
GO
