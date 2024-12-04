-- Exploratory Analysis
-- What does the dataset contain, and what are the preliminary insights we can gather from the data?
SELECT * FROM PortfolioProject..HRDataset$

-- What is the average salary for each department?
SELECT  AVG(Salary) AS AVGSalary,
		Department
FROM PortfolioProject..HRDataset$
GROUP BY Department
ORDER BY AVGSalary

-- What is the average engagement survey score and employee satisfaction score for each performance score category?
SELECT  AVG(EngagementSurvey) AS AVGengsurvey,
		AVG(EmpSatisfaction)  AS AVGempsurvey,
		PerformanceScore
FROM PortfolioProject..HRDataset$
GROUP BY PerformanceScore
ORDER BY	AVGempsurvey,AVGengsurvey

-- How many employees have been terminated in each department, and what are the top 3 reasons for termination?
SELECT  department,
		TermReason,
		COUNT(*) AS TerminationCount
FROM PortfolioProject..HRDataset$
WHERE Termd = 1
GROUP BY Department,TermReason
ORDER BY TerminationCount DESC

-- How many employees were hired through diversity job fairs, and what is their percentage across all recruitments?
SELECT  COUNT(CASE WHEN FromDiversityJobFairID = 1 THEN 1 END) AS DiversityHires,
		COUNT (*) AS TotalHires,(
		COUNT(CASE WHEN FromDiversityJobFairID = 1 THEN 1 END) * 100.0/COUNT(*)) AS DiversityHirePercentage
FROM PortfolioProject..HRDataset$

-- What is the average age of employees in each performance score category?
SELECT  PerformanceScore,
		AVG(YEAR(GETDATE()) - YEAR(DOB)) AS AvgAge
FROM PortfolioProject..HRDataset$
GROUP BY PerformanceScore

-- Is there a correlation between days late in the last 30 days and the number of absences?
SELECT  DaysLateLast30,
		AVG(Absences) AS AvgAbsences
FROM PortfolioProject..HRDataset$
GROUP BY DaysLateLast30

-- What is the average performance score of employees under each manager?
SELECT  ManagerName,
		AVG(PerfScoreID) AS AvgPerfScore
FROM PortfolioProject..HRDataset$
GROUP BY ManagerName

-- What is the retention rate (employees still employed) for each recruitment source?
SELECT  RecruitmentSource,
		COUNT(CASE WHEN Termd = 0 THEN 1 END) * 100.0/COUNT(*) AS RetentionRate
FROM PortfolioProject..HRDataset$
GROUP BY RecruitmentSource

-- What is the total number of special projects completed per department, and which department contributed the most?
SELECT  Department,
		SUM(SpecialProjectsCount) AS TotalProjects
FROM PortfolioProject..HRDataset$
GROUP BY Department
ORDER BY TotalProjects DESC

-- What is the average number of absences based on gender and marital status?
SELECT  GenderID,
		MaritalStatusID,
		AVG(Absences) AS AvgAbsences
FROM PortfolioProject..HRDataset$
GROUP BY GenderID,MaritalStatusID

-- How many employees have been hired in each state, and which state has the highest hiring rate?
SELECT  State,
		COUNT(*) AS Hires
FROM PortfolioProject..HRDataset$
GROUP BY State
ORDER BY Hires DESC

-- What is the average tenure of employees (in years) for each department?
SELECT  Department,
		AVG(DATEDIFF(DAY,DateofHire, ISNULL(DateofTermination,GETDATE())) / 365.0) AS AvgTenure
FROM PortfolioProject..HRDataset$
GROUP BY Department

-- What is the average engagement survey score for employees who have been late more than 5 days in the last 30 days?
SELECT AVG(EngagementSurvey) AS AvgEngagement
FROM PortfolioProject..HRDataset$
WHERE DaysLateLast30 > 5

-- What is the average number of absences for each performance score category?
SELECT  AVG(Absences) AS AvgAbsences,
		PerformanceScore
FROM PortfolioProject..HRDataset$
GROUP BY PerformanceScore

-- What is the gender distribution in each department?
SELECT  Sex,
		Department,
		COUNT(*) AS Count
FROM PortfolioProject..HRDataset$
GROUP BY Sex,Department
ORDER BY Count DESC

-- Identify employees with a performance score above the average performance score and their respective departments.
WITH AvgPerformance AS (
	SELECT AVG(PerfScoreID) AS AvgPerfScore 
FROM PortfolioProject..HRDataset$
)
SELECT  Employee_Name,
		Department,
		PerfScoreID 
FROM PortfolioProject..HRDataset$,AvgPerformance
WHERE PerfScoreID > AvgPerfScore

-- Calculate the tenure (in years) of all employees and find the average tenure per department.
WITH EmployeeTenure AS (
SELECT  Department, 
		Employee_Name,
		DATEDIFF(DAY, DateofHire, ISNULL(DateofTermination,GETDATE())) / 365 AS TenureYears
FROM PortfolioProject..HRDataset$
)
SELECT  Department,
		Employee_Name,
		TenureYears
FROM EmployeeTenure

--SELECT * FROM PortfolioProject..HRDataset$