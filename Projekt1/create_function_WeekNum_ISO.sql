CREATE FUNCTION [dbo].[WeekNum_ISO]
(
  @Date DATETIME
)
RETURNS INT
AS
BEGIN
  DECLARE @Result INT, @i INT, @Year INT
  SET @i = (@@DATEFIRST + DATEPART(Weekday,@Date) - 2) % 7
  SET @Year = DATEPART(Year,DATEADD(Day,3 - @i,@Date))
  SET @Result = 100 * @Year + (DATEDIFF(Day,CONVERT(CHAR(4),@Year) + '0101',@Date) - @i + 10) / 7
  RETURN @Result
END


/*
für year_cw_iso
(CONVERT([smallint],substring(CONVERT([varchar](6),[dbo].[WeekNum_ISO](CONVERT([varchar](8),[id],(112))),(112)),(1),(4)),(0)))

für cw_iso
([dbo].[WeekNum_ISO](CONVERT([varchar](8),[id],(112))))

für cw_iso_desc
('CW '+substring(CONVERT([varchar](11),[dbo].[WeekNum_ISO](CONVERT([varchar](8),[id],(112))),(112)),(5),(6)))

*/