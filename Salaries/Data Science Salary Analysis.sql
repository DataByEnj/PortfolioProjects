-- Exploratory Analysis
-- What does the dataset contain, and what are the preliminary insights we can gather from the data?
SELECT * FROM DataScienceSalaries..datasciencesalaries$

-- What is the average salary for each experience level in USD?
SELECT  experience_level,
		AVG(salary_in_usd) AS AvgSalary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY experience_level
ORDER BY AvgSalary

-- What is the salary distribution by job title in USD?
SELECT  job_title,
		MIN(salary_in_usd) AS min_salary,
		MAX(salary_in_usd) AS max_salary,
		AVG(salary_in_usd) AS avg_salary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY job_title
ORDER BY avg_salary DESC

-- How does salary vary by employment type (e.g., full-time, part-time, contract) in USD?
SELECT  employment_type,
		AVG(salary_in_usd) AS AvgSalary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY employment_type
ORDER BY AvgSalary DESC

-- What is the correlation between remote work ratio and salary for employees?
SELECT  remote_ratio,
		AVG(salary_in_usd) AS AvgSalary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY remote_ratio

-- What is the average salary for employees based on company size?
SELECT  company_size,
		AVG(salary_in_usd) AS AvgSalary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY company_size
ORDER BY AvgSalary DESC

-- How do salaries compare across different employee residences (locations)?
SELECT  employee_residence,
		AVG(salary_in_usd) AS AvgSalary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY employee_residence
ORDER BY AvgSalary DESC

-- What is the median salary for each job title in USD?
WITH SalaryRank AS (
	SELECT  job_title,
			salary_in_usd,
			ROW_NUMBER() OVER (PARTITION BY job_title ORDER BY salary_in_usd) AS RowAsc,
			ROW_NUMBER() OVER (PARTITION BY job_title ORDER BY salary_in_usd DESC) AS RowDesc
	FROM	DataScienceSalaries..datasciencesalaries$
)
	SELECT	job_title,
			AVG(salary_in_usd) AS median_salary
	FROM	SalaryRank
	WHERE	RowAsc = RowDesc
	GROUP BY job_title
	ORDER BY median_salary DESC

-- What is the salary range for each company location in USD?
SELECT  company_location,
		MIN(salary_in_usd) AS min_salary,
		MAX(salary_in_usd) AS max_salary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY company_location

-- How do the average salaries compare for employees in different company locations and their corresponding job titles?
SELECT  company_location,
		job_title,
		AVG(salary_in_usd) AS AvgSalary
FROM DataScienceSalaries..datasciencesalaries$
GROUP BY company_location,job_title
ORDER BY AvgSalary DESC

-- What is the average salary for each company location, and how does it compare to the overall average salary across all locations?
WITH AvgSalaryPerLocation AS (
    SELECT 
        company_location,
        AVG(salary_in_usd) AS avg_salary_usd
    FROM 
        DataScienceSalaries..datasciencesalaries$
    GROUP BY 
        company_location
),
OverallAvgSalary AS(
	SELECT
		AVG(salary_in_usd) AS OverallAverageSalary
	 FROM 
        DataScienceSalaries..datasciencesalaries$
)
	SELECT
		company_location,
		avg_salary_usd,
		OverallAverageSalary,
		(a.avg_salary_usd - o.OverallAverageSalary) AS salary_difference
	FROM AvgSalaryPerLocation a
	CROSS JOIN 
		OverallAvgSalary o
	ORDER BY a.avg_salary_usd DESC

-- What is the salary ranking by job title within each company location, and how does it compare to the highest salary in that location?
WITH SalaryRankings AS (
	SELECT  company_location,
			job_title,
			salary_in_usd,
			RANK() OVER (PARTITION BY company_location ORDER BY salary_in_USD DESC) AS Salary_Rank
	FROM DataScienceSalaries..datasciencesalaries$
),
MaxSalaryPerLocation AS (
	SELECT  
			company_location,
			MAX(salary_in_usd) AS max_salary_usd
	FROM DataScienceSalaries..datasciencesalaries$
	GROUP BY company_location
)
	SELECT	s.company_location,
			s.job_title,
			s.salary_in_usd,
			s.salary_rank,
			m.max_salary_usd,
		(s.salary_in_usd / m.max_salary_usd) * 100 AS salary_percentage_of_max
FROM 
    SalaryRankings s
JOIN 
    MaxSalaryPerLocation m ON s.company_location = m.company_location
ORDER BY 
    s.company_location, s.salary_rank;


--SELECT * FROM DataScienceSalaries..datasciencesalaries$