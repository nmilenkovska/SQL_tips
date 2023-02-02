--End date of price change
create table sales(
 item int,
 date date,
 price int
)

insert into ##sales(item, date, price) 
values
(1,'2021-05-01', 200),
(1,'2021-06-11', 210),
(1,'2021-06-27', 225),
(1,'2021-08-01', 250),
(2,'2021-02-10', 600),
(2,'2021-04-21', 650),
(2,'2021-06-17', 675),
(2,'2021-07-23', 700)

select item, date as DateStart, price, 
       lead(date,1, GETDATE()) over (partition by item order by date ) DateEnd
from sales

--Semipivoting without uising pivot
create table Employee (
 id int identity(1,1) primary key,
 name varchar(255),
 paymenttype varchar(255),
 payment bigint
)

insert into Employee (name, paymenttype, payment)
values 
('John  ',       'Salary' ,     100),
('Peter ',       'Salary' ,     100),
('John  ',       'Bonus ' ,     20 ),
('Russel',       'Salary' ,     100),
('Bill  ',       'Salary' ,     100),
('Bill  ',       'Bonus ' ,     40 ),
('John  ',       'Salary' ,     100)

SELECT
    Name,
    SUM(CASE WHEN PaymentType = 'Salary' THEN Payment ELSE 0 END) AS Salary,
    SUM(CASE WHEN PaymentType = 'Bonus'  THEN Payment ELSE 0 END) AS Bonus
FROM Employee
GROUP BY Name

--
create table Ingresaron (DepartmentId int,Fecha_Lunes date,Entraron int);
insert into Ingresaron (DepartmentId,Fecha_Lunes,Entraron) values
(26,'2022-08-01',1),
(26,'2022-08-15',2),
(26,'2022-08-22',3), 
(26,'2022-08-08',3);

create table Salieron (DepartmentId int,Fecha_Lunes date,Salieron int);
insert into Salieron (DepartmentId,Fecha_Lunes,Salieron) values
(26,'2022-08-15',3),
(26,'2022-08-22',4),
(26,'2022-08-08',2),
(26,'2022-08-29',1);

This query uses the FULL JOIN operator to combine the data from the ingresaron and Salieron tables. The FULL JOIN operator will return all rows from both tables, even if there are no matching rows in the other table. The coalesce function is used to combine the values from the DepartmentId and Fecha_lunes columns in the two input tables. The coalesce function returns the first non-null value from the list of arguments, so if a value is present in one table but not the other, the non-null value will be used.

select coalesce(ing.DepartmentId, s.DepartmentId) as DepartmentId,
   coalesce(ing.Fecha_lunes, s.Fecha_lunes) as Fecha_lunes,
   s.Salieron,
   ing.Entraron
from ingresaron ing
full join Salieron s 
on ing.DepartmentId = s.DepartmentId and ing.Fecha_lunes = s.Fecha_lunes;


--Delete duplicates data
CREATE TABLE [dbo].[table](
	[name] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
INSERT [dbo].[table] ([name]) VALUES (N'John')
GO
INSERT [dbo].[table] ([name]) VALUES (N'John')
GO
INSERT [dbo].[table] ([name]) VALUES (N'John')
GO
INSERT [dbo].[table] ([name]) VALUES (N'Bill')
GO
INSERT [dbo].[table] ([name]) VALUES (N'Bill')
GO
INSERT [dbo].[table] ([name]) VALUES (N'John')
GO
INSERT [dbo].[table] ([name]) VALUES (N'Russel')
GO
INSERT [dbo].[table] ([name]) VALUES (N'Peter')
GO
INSERT [dbo].[table] ([name]) VALUES (N'John')
GO

with cte as(
 SELECT 
  [name] 
  ,row_numbers=ROW_NUMBER() OVER(PARTITION BY [name] ORDER BY [name])
 FROM [dbo].[table]
)

DELETE FROM CTE WHERE row_numbers > 1
select name from [dbo].[table]

--Find Most Expensive Queries
SELECT TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1, 
					   ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.TEXT)
						ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1),
	qs.execution_count,
	qs.total_logical_reads, qs.last_logical_reads,
	qs.total_logical_writes, qs.last_logical_writes,
	qs.total_worker_time,
	qs.last_worker_time,
	qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
	qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
	qs.last_execution_time,
	qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_logical_reads DESC -- logical reads

SELECT TOP(50) 
	qs.execution_count AS [Execution Count],
	(qs.total_logical_reads)*8/1024.0 AS [Total Logical Reads (MB)],
	(qs.total_logical_reads/qs.execution_count)*8/1024.0 AS [Avg Logical Reads (MB)],
	(qs.total_worker_time)/1000.0 AS [Total Worker Time (ms)],
	(qs.total_worker_time/qs.execution_count)/1000.0 AS [Avg Worker Time (ms)],
	(qs.total_elapsed_time)/1000.0 AS [Total Elapsed Time (ms)],
	(qs.total_elapsed_time/qs.execution_count)/1000.0 AS [Avg Elapsed Time (ms)],
	qs.creation_time AS [Creation Time]
	,t.text AS [Complete Query Text], qp.query_plan AS [Query Plan]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
WHERE t.dbid = DB_ID()
ORDER BY qs.execution_count DESC OPTION (RECOMPILE);-- frequently ran query
-- ORDER BY [Total Logical Reads (MB)] DESC OPTION (RECOMPILE);-- High Disk Reading query
-- ORDER BY [Avg Worker Time (ms)] DESC OPTION (RECOMPILE);-- High CPU query
-- ORDER BY [Avg Elapsed Time (ms)] DESC OPTION (RECOMPILE);-- Long Running query

--Find the Currently Running Queries
SELECT      r.start_time [Start Time],session_ID [SPID],
            DB_NAME(database_id) [Database],
            SUBSTRING(t.text,(r.statement_start_offset/2)+1,
            CASE WHEN statement_end_offset=-1 OR statement_end_offset=0
            THEN (DATALENGTH(t.Text)-r.statement_start_offset/2)+1
            ELSE (r.statement_end_offset-r.statement_start_offset)/2+1
            END) [Executing SQL],
            Status,command,wait_type,wait_time,wait_resource,
            last_wait_type
FROM        sys.dm_exec_requests r
OUTER APPLY sys.dm_exec_sql_text(sql_handle) t
WHERE       session_id != @@SPID -- don't show this query
AND         session_id > 50 -- don't show system queries
ORDER BY    r.start_time desc

--Find Memory Usage by SQL Server
select
(physical_memory_in_use_kb/1024)Phy_Memory_usedby_Sqlserver_MB,
(locked_page_allocations_kb/1024 )Locked_pages_used_Sqlserver_MB,
(virtual_address_space_committed_kb/1024 )Total_Memory_UsedBySQLServer_MB,
process_physical_memory_low,
process_virtual_memory_low
from sys. dm_os_process_memory

--List all Indexes in the Database
select i.[name] as index_name,
    substring(column_names, 1, len(column_names)-1) as [columns],
    case when i.[type] = 1 then 'Clustered index'
        when i.[type] = 2 then 'Nonclustered unique index'
        when i.[type] = 3 then 'XML index'
        when i.[type] = 4 then 'Spatial index'
        when i.[type] = 5 then 'Clustered columnstore index'
        when i.[type] = 6 then 'Nonclustered columnstore index'
        when i.[type] = 7 then 'Nonclustered hash index'
        end as index_type,
    case when i.is_unique = 1 then 'Unique'
        else 'Not unique' end as [unique],
    schema_name(t.schema_id) + '.' + t.[name] as table_view, 
    case when t.[type] = 'U' then 'Table'
        when t.[type] = 'V' then 'View'
        end as [object_type]
from sys.objects t
    inner join sys.indexes i
        on t.object_id = i.object_id
    cross apply (select col.[name] + ', ' from sys.index_columns ic
                        inner join sys.columns col
                        on ic.object_id = col.object_id and ic.column_id = col.column_id
                    where ic.object_id = t.object_id and ic.index_id = i.index_id
                            order by key_ordinal
                            for xml path ('') ) D (column_names)
where t.is_ms_shipped <> 1
and index_id > 0
order by i.[name]

--Find indexes that are not used at all or used rarely
SELECT 
OBJECT_NAME(IUS.[OBJECT_ID]) AS [OBJECT NAME],
DB_NAME(IUS.database_id) AS [DATABASE NAME],
I.[NAME] AS [INDEX NAME],
USER_SEEKS,
USER_SCANS,
USER_LOOKUPS,
USER_UPDATES
FROM sys.dm_db_index_usage_stats AS IUS
INNER JOIN sys.indexes  AS I
ON I.[OBJECT_ID] = IUS.[OBJECT_ID]
AND I.INDEX_ID = IUS.INDEX_ID
--Explanation:
--USER_SEEKS: the number of times the index has been used to seek to a specific row
--USER_SCANS: the number of times the index has been scanned from start to finish
--USER_LOOKUPS: the number of times the index has been used to look up a row based on its index key
--USER_UPDATES: the number of times the index has been updated (e.g. when a row is inserted, updated, or deleted)

--Show Open Ports for Sql Server
select distinct LOCAL_TCP_PORT from 
sys.dm_exec_connections
where local_tcp_port is not null

--worst instantly performing queries
SELECT TOP 20
total_worker_time/execution_count AS Avg_CPU_Time
,Execution_count
,total_elapsed_time/execution_count as AVG_Run_Time
,total_elapsed_time
,(SELECT
SUBSTRING(text,statement_start_offset/2+1,statement_end_offset
) FROM sys.dm_exec_sql_text(sql_handle)
) AS Query_Text
FROM sys.dm_exec_query_stats
ORDER BY Avg_CPU_Time DESC

--Check whether Full text Search is Installed or not
SELECT  
  SERVERPROPERTY('Edition') AS [Edition],
  SERVERPROPERTY('ProductVersion') AS [Product Version],  
  SERVERPROPERTY('IsFullTextInstalled') AS [Full Text Search Installed]; 

--List of all the Jobs
SELECT
     job.job_id,
     notify_level_email,
     name,
     enabled,
     description,
     step_name,
     command,
     server,
     database_name
FROM msdb.dbo.sysjobs job
INNER JOIN   msdb.dbo.sysjobsteps steps        
ON job.job_id = steps.job_id
WHERE  job.enabled = 1 -- remove this if you wish to return all jobs

--to which database you have access
SELECT name AS DatabaseName,
HAS_DBACCESS(name) as HasDBAccess
FROM sys.databases
WHERE HAS_DBACCESS(name)=1