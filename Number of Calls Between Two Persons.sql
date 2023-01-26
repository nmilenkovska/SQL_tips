USE [Test]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[calls](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[from_id] [int] NOT NULL,
	[to_id] [int] NOT NULL,
	[duration] [int] NOT NULL,
 CONSTRAINT [PK_calls] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[calls] ON 
GO
INSERT [dbo].[calls] ([id], [from_id], [to_id], [duration]) VALUES (1, 1, 2, 59)
GO
INSERT [dbo].[calls] ([id], [from_id], [to_id], [duration]) VALUES (2, 2, 1, 11)
GO
INSERT [dbo].[calls] ([id], [from_id], [to_id], [duration]) VALUES (3, 1, 3, 20)
GO
INSERT [dbo].[calls] ([id], [from_id], [to_id], [duration]) VALUES (4, 3, 4, 100)
GO
INSERT [dbo].[calls] ([id], [from_id], [to_id], [duration]) VALUES (5, 3, 4, 200)
GO
INSERT [dbo].[calls] ([id], [from_id], [to_id], [duration]) VALUES (6, 3, 4, 200)
GO
INSERT [dbo].[calls] ([id], [from_id], [to_id], [duration]) VALUES (7, 4, 3, 450)
GO
SET IDENTITY_INSERT [dbo].[calls] OFF
GO


Select
	Case When from_id < to_id Then from_id Else to_id End as person1
	, Case When from_id > to_id Then from_id Else to_id End as person2
	, duration
From [dbo].[calls];

With cte as (
	Select
	Case When from_id < to_id Then from_id Else to_id End as person1
	, Case When from_id > to_id Then from_id Else to_id End as person2
	, duration
From [dbo].[calls]
)
Select person1, person2, Count(1) as call_count, Sum(duration) as total_duration
from cte
Group By person1, person2