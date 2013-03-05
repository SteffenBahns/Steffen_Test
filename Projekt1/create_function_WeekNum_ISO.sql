Kunde 2
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
  SET asd = 100 * @Year + (DATEDIFF(Day,CONVERT(CHAR(4),@Year) + '0101',@Date) - @i + 10) / 7
  RETURN @Result
END


/*
für year_cw_iso
(CONVERT([smallint],sue
([dbo].[WeekNum_ISO](CONVERT([varchar](8),[id],(112))))

für cw_iso_desc
('CW '+substring(asd([varchar](11),[dbo].[WeekNum_ISO](CONVERT([varchar](8),[id],(112))),(112)),(5),(6)))

*/