USE [Test]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StartEndContinuosRanges](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[log_id] [int] NOT NULL,
 CONSTRAINT [PK_StartEndContinuosRanges] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[StartEndContinuosRanges] ON 
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (1, 2)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (2, 3)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (3, 4)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (4, 5)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (5, 10)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (6, 11)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (7, 15)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (8, 16)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (9, 17)
GO
INSERT [dbo].[StartEndContinuosRanges] ([id], [log_id]) VALUES (10, 18)
GO
SET IDENTITY_INSERT [dbo].[StartEndContinuosRanges] OFF
GO


SELECT log_id
, ROW_NUMBER() OVER (order by Log_id) as rn
, log_id - ROW_NUMBER() OVER (order by Log_id) as diff
From [dbo].[StartEndContinuosRanges];



With grouped_data As (
	SELECT log_id
	, log_id - ROW_NUMBER() OVER (order by Log_id) as diff
	From [dbo].[StartEndContinuosRanges]
)

SELECT MIN(log_id) as start_if
, MAX(log_id) as end_id
From grouped_data
Group By diff