USE [AOC2022]
GO
/****** Object:  StoredProcedure [dbo].[DAY_7_SCRIPT_PART_2]    Script Date: 07/12/2022 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DAY_7_SCRIPT_PART_2] as
begin

	set nocount on;

	declare @value nvarchar(50);

	declare @workingDirectory nvarchar(255);
	declare @directoryID int;
	declare @parentID int;
	declare @depth int;

	declare @type nvarchar(10);
	declare @commandType nvarchar(2);
	declare @command nvarchar(255);
	declare @name nvarchar(255);
	declare @fileSize int;

	--set working dir to outermost dir
	set @workingDirectory = '/';
	set @depth = 0;

	create table #directories (
		AutoID int identity primary key
		,[Path] nvarchar(255)
		,[Depth] int
		,[ParentID] int
		,[TotalSize] int
	);

	create table #files (
		AutoID int identity primary key
		,[DirectoryID] int
		,[FileName] nvarchar(255)
		,[FileSize] int
	);

	--insert level 0
	insert into #directories ([Path], [Depth], [ParentID]) values ('/', 0, null);
	select top 1 @directoryID = AutoID from #directories where [Path] = '/';

	declare cur cursor for
	select
		case
			when left(InputValue,1) = '$' then 'COMMAND'
			when left(InputValue,3) = 'dir' then 'DIRECTORY'
			else 'FILE'
		end as [type],
		case
			when left(InputValue,4) = '$ cd' then 'CD'
			when left(InputValue,4) = '$ ls' then 'LS'
		end as [commandType]
		,case
			when left(InputValue,4) = '$ cd' then trim(substring(InputValue, 6, 255))
		end as [command]
		,case
			when left(InputValue, 3) = 'dir' then trim(substring(InputValue, 4, 255))
			when ascii(left(InputValue, 1)) between 48 and 57 then trim(substring(InputValue, charindex(' ',InputValue), 255))
		end as [name]
		,case
			when ascii(left(InputValue, 1)) between 48 and 57 then cast(trim(left(InputValue,charindex(' ',InputValue))) as int)
		end as [fileSize]
	from DAY_7_INPUT
	order by
		AutoID

	open  cur;

	fetch next from cur into @type, @commandType, @command, @name, @fileSize;

	while @@FETCH_STATUS = 0
	begin
		--Move to outermost directory
		if (@type = 'COMMAND' and @commandType = 'CD' and @command = '/')
		begin
			set @workingDirectory = '/';
			set @depth = 0;
			set @parentID = null;
		end
		--Set directory to x
		if (@type = 'COMMAND' and @commandType = 'CD' and @command not in ('/', '..'))
		begin
			set @workingDirectory = concat(@workingDirectory,@command,'/');
			set @depth = @depth + 1;
			--check if directory exists, if no, create
			if ((select count(*) from #directories where [Path] = @workingDirectory) = 0) insert into #directories ([Path], [Depth], [ParentID]) values (@workingDirectory, @depth, @directoryID);
			--get directory from table
			select top 1 @directoryID = AutoID, @depth = [Depth], @parentID = [ParentID] from #directories where [Path] = @workingDirectory;
		end
		--Move one directory back
		if (@type = 'COMMAND' and @commandType = 'CD' and @command = '..')
		begin
			--remove last slash
			set @workingDirectory = left(@workingDirectory, len(@workingDirectory)-1);
			--remove directory
			set @workingDirectory = left(@workingDirectory, len(@workingDirectory) - (charindex('/',reverse(@workingDirectory))-1));
			-- get directory from table
			select top 1 @directoryID = AutoID, @depth = [Depth], @parentID = [ParentID] from #directories where [Path] = @workingDirectory;
		end

		--List dir
		if (@type = 'DIRECTORY')
		begin
			--check if directory exists, if no, create
			if ((select count(*) from #directories where [Path] = concat(@workingDirectory,'/',@name)) = 0) insert into #directories ([Path], [Depth], [ParentID]) values (concat(@workingDirectory,'/',@name), @depth, @directoryID);
		end

		--List file
		if (@type = 'FILE')
		begin
			--check if file exists, if no, create
			if ((select count(*) from #files f where [FileName] = @name and [DirectoryID] = @directoryID) = 0) insert into #files ([FileName], [FileSize], [DirectoryID]) values (@name, @fileSize, @directoryID);
		end

		fetch next from cur into @type, @commandType, @command, @name, @fileSize;
	end

	close cur;
	deallocate cur;

	--Calculate sizes
	declare @totalFileSize int;
	declare @totalSubDirSize int;
	
	update #directories set [TotalSize] = 0;
	declare d_cur cursor for
	select
		AutoID
	from #directories
	order by
		Depth desc
		,AutoID desc;

	open d_cur;

	fetch next from d_cur into @directoryID;

	while @@FETCH_STATUS = 0
	begin
		--caculate total size of files in dir
		select
			@totalFileSize = sum(FileSize)
		from #files
		where
			DirectoryID = @directoryID;

		--calculate total size of subdirs
		select
			@totalSubDirSize = sum(TotalSize)
		from #directories
		where
			ParentID = @directoryID;

		update #directories set TotalSize = isnull(@totalFileSize,0) + isnull(@totalSubDirSize,0) where AutoID = @directoryID;

		fetch next from d_cur into @directoryID;
	end

	close d_cur;
	deallocate d_cur;

	declare @diskSize int = 70000000;
	declare @totalUsed int;
	declare @available int;

	select @totalUsed = TotalSize from #directories where [Path] = '/'

	set @available = @diskSize - @totalUsed;

	declare @output int;

	select top 1
		@output = TotalSize
	from #directories
	where
		[TotalSize] >= (30000000 - @available)
	order by [TotalSize];

	print concat('Total Size: ', @diskSize,' - Total used: ', @totalUsed, ' - Available: ', @available);
	print concat('Min size needed: ', 30000000 - @available);
	print @output;

	drop table #files;
	drop table #directories;

end
GO
