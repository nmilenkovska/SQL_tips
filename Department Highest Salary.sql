USE [Test]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[department](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_department] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 1/26/2023 5:04:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[salary] [money] NOT NULL,
	[departmentId] [int] NOT NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[department] ON 
GO
INSERT [dbo].[department] ([id], [name]) VALUES (1, N'IT')
GO
INSERT [dbo].[department] ([id], [name]) VALUES (2, N'Sales')
GO
SET IDENTITY_INSERT [dbo].[department] OFF
GO
SET IDENTITY_INSERT [dbo].[Employee] ON 
GO
INSERT [dbo].[Employee] ([id], [name], [salary], [departmentId]) VALUES (1, N'Natasha', 50000.0000, 1)
GO
INSERT [dbo].[Employee] ([id], [name], [salary], [departmentId]) VALUES (2, N'Renata', 60000.0000, 2)
GO
INSERT [dbo].[Employee] ([id], [name], [salary], [departmentId]) VALUES (3, N'Marija', 65000.0000, 1)
GO
INSERT [dbo].[Employee] ([id], [name], [salary], [departmentId]) VALUES (4, N'Goran', 55000.0000, 1)
GO
INSERT [dbo].[Employee] ([id], [name], [salary], [departmentId]) VALUES (5, N'Ivana', 60000.0000, 2)
GO
SET IDENTITY_INSERT [dbo].[Employee] OFF
GO


Select d.name as deparment, e.name as employee, e.salary, RANK() Over (Partition By d.name Order by e.salary Desc) as rank
From [dbo].[Employee] e
Inner Join [dbo].[department] d On e.departmentId = d.Id;


--I approach
With ranked_salary as (
	Select d.name as deparment, e.name as employee, e.salary, RANK() Over (Partition By d.name Order by e.salary Desc) as rank
	From [dbo].[Employee] e
	Inner Join [dbo].[department] d On e.departmentId = d.Id
)
Select deparment, employee, salary
From ranked_salary
Where rank = 1;

--II approach
With max_salary as (
	Select d.name as deparment, d.id, Max(e.salary) as salary
	From [dbo].[Employee] e
	Inner Join [dbo].[department] d On e.departmentId = d.Id
	Group By d.name, d.id
)
Select ms.deparment, e.name as employee, ms.salary
From max_salary ms
Inner join [dbo].[Employee] e On e.departmentId = ms.Id and e.salary = ms.salary
