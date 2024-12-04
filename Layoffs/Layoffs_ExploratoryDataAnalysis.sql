-- Exploratory Analysis
-- What does the dataset contain, and what are the preliminary insights we can gather from the data?
SELECT * FROM layoffs$

-- What is the range of dates present in the dataset, considering only the date values?
SELECT  CAST(MIN(date) AS DATE) AS EarliestDate, 
		CAST(MAX(date) AS DATE) AS LatestDate
FROM layoffs$

-- Which companies had the highest total layoffs?
SELECT * 
FROM layoffs$
ORDER BY total_laid_off DESC

-- Which companies experienced a 100% layoff, and how do they rank by the total number of people laid off?
SELECT * 
FROM layoffs$
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC

-- Which companies with 100% layoffs had raised the most funds?
SELECT * 
FROM layoffs$
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC

-- What information can we find about a specific company (e.g., Humble Games)?
SELECT * 
FROM layoffs$
WHERE company LIKE '%Humble Games%'

-- What are the total layoffs for each company, and which companies had the highest numbers?
SELECT  company,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
GROUP BY company
ORDER BY 2 DESC

-- What are the layoff details for a specific industry (e.g., Media), and which companies had the highest layoffs in this industry?
SELECT * 
FROM layoffs$
WHERE industry LIKE '%Media%'
ORDER BY total_laid_off DESC

-- How many layoffs occurred in each industry, and which industries were most affected?
SELECT  industry,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
GROUP BY industry
ORDER BY 2 DESC

-- What are the layoff details for a specific country (e.g., United States), and which companies had the highest layoffs?
SELECT * 
FROM layoffs$
WHERE country LIKE '%United States%'
ORDER BY total_laid_off DESC

-- What are the total layoffs for each country, and which countries experienced the most layoffs?
SELECT  country,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
GROUP BY country
ORDER BY 2 DESC

-- How many layoffs occurred in each year?
SELECT  YEAR(date) AS Year,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
GROUP BY YEAR(date)
ORDER BY 1 DESC

-- What is the monthly trend of layoffs across all years?
SELECT  FORMAT(date,'yyyy-MM') AS Month,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
WHERE date IS NOT NULL
GROUP BY FORMAT(date,'yyyy-MM')
ORDER BY Month

-- How do the monthly layoffs accumulate over time on a rolling basis?
WITH Rolling_Total AS (
	SELECT  YEAR(date) AS Year,
			MONTH(date) AS Month,
			SUM(total_laid_off) AS TotalLaidOff
 FROM layoffs$
 WHERE date IS NOT NULL
 GROUP BY YEAR(date),MONTH(date)
)
SELECT  CONCAT(Year,'-', RIGHT('00' + CAST(Month AS VARCHAR),2)) AS Year_Month,
		TotalLaidOff,
		SUM (TotalLaidOff) OVER (ORDER BY Year,Month) AS Rolling_Total
FROM Rolling_Total
ORDER BY Year,Month

-- How do layoffs vary by year/month and industry?
SELECT  FORMAT(date,'yyyy-MM') AS Year_Month,
		SUM(total_laid_off) AS TotalLaidOff,
		industry
FROM layoffs$
WHERE date IS NOT NULL
GROUP BY industry,FORMAT(date,'yyyy-MM')
ORDER BY TotalLaidOff DESC

-- What is the annual trend of layoffs within each industry?
SELECT  FORMAT(date,'yyyy') AS Year,
		SUM(total_laid_off) AS TotalLaidOff,
		industry
FROM layoffs$
GROUP BY FORMAT(date,'yyyy'),industry
ORDER BY 1

-- What is the total number of layoffs within the given date range?
SELECT  FORMAT(MIN(date), 'yyyy-MM') AS EarliestDate,
		FORMAT(MAX(date), 'yyyy-MM') AS LatestDate,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
ORDER BY EarliestDate

-- How many layoffs occurred at different stages of company development?
SELECT  stage,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
GROUP BY stage
ORDER BY 2 DESC

-- What is the trend of layoffs over time in a specific industry (e.g., Recruiting)?
SELECT  FORMAT(date,'yyyy-MM') AS Year_Month,
		industry,
		SUM(total_laid_off) AS TotalLaidOff
FROM layoffs$
WHERE industry LIKE '%Recruiting%'
GROUP BY FORMAT(date,'yyyy-MM'),industry
ORDER BY 1

-- How have layoffs for a specific company (e.g., Chegg) changed annually?
SELECT  FORMAT(date,'yyyy') AS Year,
		SUM(total_laid_off) AS TotalLaidOff,
		company
FROM layoffs$
WHERE	company LIKE '%Chegg%'
GROUP BY FORMAT(date,'yyyy'),company
ORDER BY 1

-- What is the rolling monthly total of layoffs for a specific company (e.g., iRobot)?
WITH Rolling_Total AS (
	SELECT  YEAR(date) AS Year,
			MONTH(date) AS Month,
			SUM(total_laid_off) AS TotalLaidOff
 FROM layoffs$
 WHERE date IS NOT NULL
 AND company LIKE '%iRobot%'
 GROUP BY YEAR(date),MONTH(date)
)
SELECT  CONCAT(Year,'-', RIGHT('00' + CAST(Month AS VARCHAR),2)) AS Year_Month,
		TotalLaidOff,
		SUM (TotalLaidOff) OVER (ORDER BY Year,Month) AS Rolling_Total
FROM Rolling_Total
ORDER BY Year,Month

-- How do the annual layoffs accumulate for a specific company (e.g., iRobot)?
WITH Rolling_Total AS (
	SELECT  YEAR(date) AS Year,
			company,
			SUM(total_laid_off) AS TotalLaidOff
 FROM layoffs$
 WHERE date IS NOT NULL
 AND company LIKE '%iRobot%'
 GROUP BY YEAR(date),company
)
SELECT  Year,
		company,
		TotalLaidOff,
		SUM (TotalLaidOff) OVER (ORDER BY Year) AS Rolling_Total
FROM Rolling_Total
ORDER BY Year

-- Which companies ranked in the top 5 for layoffs in each year?
WITH  Company_Year AS (
SELECT  company,
		YEAR(date) AS Year,
		SUM(total_laid_off) AS TotalLaidOff
 FROM layoffs$
 WHERE date IS NOT NULL
 GROUP BY company, YEAR(date)
),
Ranked_Company AS (
SELECT  company,
		Year,
		TotalLaidOff,
		DENSE_RANK() OVER(PARTITION BY Year ORDER BY TotalLaidOff DESC) AS Ranking
FROM Company_Year
)
SELECT  company,
		Year,
		TotalLaidOff,
		Ranking
FROM Ranked_Company
WHERE Ranking <= 5
ORDER BY Year,Ranking

-- Which industries ranked in the top 5 for layoffs in each year?
WITH  Industry_Year AS (
SELECT  industry,
		YEAR(date) AS Year,
		SUM(total_laid_off) AS TotalLaidOff
 FROM layoffs$
 WHERE date IS NOT NULL
 GROUP BY industry, YEAR(date)
),
Industry_Ranked AS (
SELECT  industry,
		Year,
		TotalLaidOff,
		DENSE_RANK() OVER(PARTITION BY Year ORDER BY TotalLaidOff DESC) AS Ranking
FROM Industry_Year
)
SELECT  industry,
		Year,
		TotalLaidOff,
		Ranking
FROM Industry_Ranked
WHERE Ranking <= 5
ORDER BY Year,Ranking

