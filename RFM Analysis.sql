
-- -- -- -- -- -- -- RFM Calculate -- -- -- -- -- -- -- 
WITH RFM_Base 
AS
(
  SELECT b.Customer_Name AS CustomerName,
    DATEDIFF(DAY, MAX(a.Order_Date), CONVERT(DATE, GETDATE())) AS Recency_Value,
    COUNT(DISTINCT a.Order_Date) AS Frequency_Value,
    ROUND(SUM(a.Sales), 2) AS Monetary_Value
  FROM Projects.dbo.sales AS a
  INNER JOIN Projects.dbo.customer AS b ON a.Customer_ID = b.Customer_ID
  GROUP BY b.Customer_Name
), 

RFM_Score 
AS
(
  SELECT *,
    NTILE(5) OVER (ORDER BY Recency_Value DESC) as R_Score,
    NTILE(5) OVER (ORDER BY Frequency_Value ASC) as F_Score,
    NTILE(5) OVER (ORDER BY Monetary_Value ASC) as M_Score
  FROM RFM_Base
), 

RFM_Final
AS
(
SELECT *,
  CONCAT(R_Score, F_Score, M_Score) as RFM_Overall

FROM RFM_Score
)

SELECT f.*, s.Segment
FROM RFM_Final f
JOIN Projects.dbo.[segment scores] s ON f.RFM_Overall = s.Scores
;
