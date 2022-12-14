USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_12_SCRIPT_PART_1]    Script Date: 12/12/2022 09:44:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_12_SCRIPT_PART_1] as
begin

	set nocount on;

	--Day 12: Dijkstra Algorithm

	create table #nodes (
		NodeID int identity primary key
		,X int
		,Y int
		,Symbol nvarchar(1)
		,Height int
		,Movement nvarchar(1)
	);

	create table #edges (
		AutoID int identity primary key
		,FromNodeID int
		,ToNodeID int
		,[Weight] decimal(10,3)
	);

	create table #nodeEstimates (
		NodeID int primary key
		,Estimate decimal(10,3) not null -- Distance to this node so far
		,Predecessor int       -- The node we came from fo get to this node with this distance
		,Done bit              -- Is the estimate final?
	);

	declare @x int;
	declare @y int;
	declare @inputValue nvarchar(100);

	declare input_cur cursor for
	select
		*
	from DAY_12_INPUT
	order by
		AutoID;

	open input_cur;

	fetch next from input_cur into @y, @inputValue;

	while @@FETCH_STATUS = 0
	begin
		set @x = 1;

		while (@x <= len(@inputValue))
		begin
			insert into #nodes (X, Y, Symbol, Height)
			values (@x, @y, substring(@inputValue, @x, 1), ascii(substring(@inputValue, @x, 1))-96);
			set @x = @x + 1;
		end;

		fetch next from input_cur into @y, @inputValue;
	end;

	close input_cur;
	deallocate input_cur;

	--Assume S=0;
	update #nodes set Height = 0 where Height = -13;
	--Assume E = 27;
	update #nodes set Height = 27 where Height = -27;

	--create edges
	insert into #edges (FromNodeID, ToNodeID, [Weight])
	select
		FromNodeID, ToNodeID, 1 as [Weight]
	from
		(select
			a.NodeID as FromNodeID
			,b.NodeID as ToNodeID
			,case
				when a.X = b.X and a.Y = b.Y - 1 and (b.Height <= a.Height or b.Height = a.Height + 1) then 1
				when a.X = b.X and a.Y = b.Y + 1 and (b.Height <= a.Height or b.Height = a.Height + 1) then 1
				when a.Y = b.Y and a.X = b.X - 1 and (b.Height <= a.Height or b.Height = a.Height + 1) then 1
				when a.Y = b.Y and a.X = b.X + 1 and (b.Height <= a.Height or b.Height = a.Height + 1) then 1
				else 0
			end as [PosibleRoute]
		from #nodes a
		join #nodes b
			on b.X in (a.X-1, a.X, a.X + 1)) src
	where
		PosibleRoute = 1;

	declare @startNodeID int;
	declare @endNodeID int;

	--set start node
	select @startNodeID = NodeID, @x = X, @y = Y from #nodes where Height = 0;
	--set end node
	select @endNodeID = NodeID, @x = X, @y = Y from #nodes where Height = 27;

	
	--Fill the temp table with initial data
	insert into #nodeEstimates (NodeID, Estimate, Predecessor, Done)
	select
		NodeID
		,9999999.999
		,null
		,0
	from #nodes;

	--Set start node estimate to be 0
	update #nodeEstimates set Estimate = 0 where NodeID = @startNodeID;
	
	declare @fromNodeId int;
	declare @currentEstimate int;

	while (1=1)
	begin
		set @fromNodeId = null;

		--select the id and current estimate for an node not done
		select top 1
			@fromNodeId = NodeID,
			@currentEstimate = Estimate
		from #nodeEstimates
		where
			Done = 0
			and Estimate < 9999999.999
		order by
			Estimate;

		--break is no more reachable nodes
		if @fromNodeId is null or @fromNodeId = @endNodeID break;

		--this node is done
		update #nodeEstimates set Done = 1 where NodeID = @fromNodeId;

		-- update the other estimates of neighbors
		update ne
			set Estimate = @currentEstimate + e.Weight
			   ,Predecessor = @fromNodeId
		from #nodeEstimates ne
		join #edges e
			on ne.NodeID = e.ToNodeID
		where
			Done = 0
			and e.FromNodeID = @fromNodeId
			and (@currentEstimate + e.Weight) < ne.Estimate;

	end;

	select cast(Estimate as int) from #nodeEstimates where NodeID = @endNodeID;

	drop table #nodes;
	drop table #edges;
	drop table #nodeEstimates;

end;
GO
