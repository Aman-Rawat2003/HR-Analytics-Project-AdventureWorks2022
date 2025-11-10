---------------------------------- HR Analysis Project 25+ insights ------------------------------------------
Use AdventureWorks2022;

-- 1. Total Employees by Gender
Select Gender , COUNT(*) As TotalEmployees
From HumanResources.Employee
Group by Gender;

-- 2. Employees Count by Marital Status
Select MaritalStatus, COUNT(*) As EmployeeCount
from HumanResources.Employee
Group by MaritalStatus;

-- 3. Employee Age Distribution
Select DATEPART(YEAR, GETDATE()) - Year(BirthDate) As Age, Count(*) As Count
From HumanResources.Employee
Group by DATEPART(YEAR, GETDATE())- Year(BirthDate)
Order by Age;

-- 4. Headcount by Year of Hire
Select Year(HireDate) as HireYear, Count(*) AS NumberHired
From HumanResources.Employee
Group by Year(HireDate)
Order by HireYear;

-- 5. Salaried vs Hourly Employees
Select 
	Case
		When SalariedFlag = 1 Then 'Salaried' Else 'Hourly'
		End As EmployeeType 
	, Count(*) AS Count
From HumanResources.Employee e
Group by e.SalariedFlag;

-- 6. Active vs Inactive Employees
Select 
	Case 
		When CurrentFlag = 1 Then 'Active' Else 'Inactive'
		End As Status, 
		Count(*) as Count
from HumanResources.Employee e
Group by e.CurrentFlag;
---------------------------------- Alternate ---------------------------------
SELECT 
    SUM(CASE WHEN CurrentFlag = 1 THEN 1 ELSE 0 END) AS Active_Employee,
    SUM(CASE WHEN CurrentFlag = 0 THEN 1 ELSE 0 END) AS Inactive_Employee
FROM HumanResources.Employee e;

-- 7. Employee Count by Job Title
Select JobTitle, Count(*) as NumberOfEmployee
From HumanResources.Employee e
Join HumanResources.EmployeeDepartmentHistory edh 
		On e.BusinessEntityID = edh.BusinessEntityID
Group by JobTitle
Order by NumberOfEmployee desc;

-- 8. Employee Distribution by Department
Select d.Name As Department_Name , Count(*) As EmployeeCount
from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Department d
	On edh.DepartmentID = d.DepartmentID
Group by d.Name
Order by EmployeeCount desc;

-- 9. Employee Tenure Buckets
Select
	Case 
		When DATEDIFF(YEAR, HireDate, '2013-05-30') < 1 Then '< 1 year'
		When DATEDIFF(Year, HireDate, '2013-05-30') Between 1 And 3 Then '1-3 years'
		When DATEDIFF(Year, HireDate, '2013-05-30') Between 4 And 6 Then '4-6 years'
		Else '7+ years'
	End As TenureBucket,
	Count(*) As NumberOfEmployees
from HumanResources.Employee
Group by 
	Case 
		When DATEDIFF(YEAR, HireDate, '2013-05-30') < 1 Then '< 1 year'
		When DATEDIFF(Year, HireDate, '2013-05-30') Between 1 And 3 Then '1-3 years'
		When DATEDIFF(Year, HireDate, '2013-05-30') Between 4 And 6 Then '4-6 years'
		Else '7+ years'
	End
Order by TenureBucket;

-- 10. Monthly Hiring Trend And Quarter Also
Select FORMAT(HireDate, 'yyyy-MM') as HireMonth, COUNT(*) as HIres 
from HumanResources.Employee
Group by FORMAT(HireDate, 'yyyy-MM')
order by HireMonth;

Select CAST(YEAR(HireDate) as varchar(4))+' -Q'+
		Cast(DATEPART(QUARTER,HireDate) as varchar(1)) as HireQuarter,
		Count(*) as Hires
from HumanResources.Employee
Group by YEAR(HireDate), DATEPART(QUARTER,HireDate)
Order by YEAR(HireDate), DATEPART(QUARTER,HireDate);


--11. Gender Diversity by Department
Select d.Name As DepartmentName, e.Gender , Count(*) As HeadCount
From HumanResources.Employee e
JOin HumanResources.EmployeeDepartmentHistory edh 
		On e.BusinessEntityID = edh.BusinessEntityID
Join HumanResources.Department d
		On edh.DepartmentID = d.DepartmentID
Group by d.Name, e.Gender
Order by DepartmentName, e.Gender;

-- 12. Total Employees by Job Title and Department
Select d.Name As DepartmentName, e.JobTitle , Count(*) As HeadCount
From HumanResources.Employee e
JOin HumanResources.EmployeeDepartmentHistory edh 
		On e.BusinessEntityID = edh.BusinessEntityID
Join HumanResources.Department d
		On edh.DepartmentID = d.DepartmentID
Group by d.Name, e.JobTitle
Order by DepartmentName, HeadCount desc;

-- 13. Employee Count by Shift
Select s.Name as Shift, COUNT(distinct edh.BusinessEntityID) as EmployeeCount
From HumanResources.EmployeeDepartmentHistory edh
JOin HumanResources.Shift s
		On edh.ShiftID = s.ShiftID
Group by s.Name;

--14. Department-wise Average Tenure (Years)
SELECT 
    d.Name AS Department, 
    AVG(DATEDIFF(YEAR, e.HireDate, '2013-05-30')) AS AvgTenureYears
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory edh 
    ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d 
    ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL   -- sirf active employees ke liye
GROUP BY d.Name
ORDER BY AvgTenureYears DESC;

-- 15. Monthly Attrition Trend (Terminated Employees Per Month)
SELECT FORMAT(eh.EndDate, 'yyyy-MM') AS TerminationMonth, COUNT(*) AS EmployeesTerminated
FROM HumanResources.EmployeeDepartmentHistory eh
WHERE eh.EndDate IS NOT NULL
GROUP BY FORMAT(eh.EndDate, 'yyyy-MM')
ORDER BY TerminationMonth;

-- 16. Employees by Pay Frequency
Select PayFrequency, Count(*) as HeadCount
From HumanResources.EmployeePayHistory
Group by PayFrequency;

-- 17. Highest Paid Employee By Department
Select d.Name As Department, e.BusinessEntityID, MAX(eph.Rate) as HighstPay
from HumanResources.EmployeePayHistory eph
Join HumanResources.Employee e			On eph.BusinessEntityID = e.BusinessEntityID
Join HumanResources.EmployeeDepartmentHistory edh On e.BusinessEntityID = edh.BusinessEntityID
Join HumanResources.Department d		On edh.DepartmentID = d.DepartmentID
Group by d.Name, e.BusinessEntityID;

-- 18. Employees Promoted More Than Once
Select BusinessEntityID, COUNT(Distinct ShiftID) as Promotion
from HumanResources.EmployeeDepartmentHistory
group by BusinessEntityID
Having COUNT(Distinct ShiftID) > 1;

-- 19. Employees With Most Job Title Changes
Select edh.BusinessEntityID, COUNT(Distinct e.JObtitle) as JobtitleChange 
from HumanResources.EmployeeDepartmentHistory edh
Join HumanResources.Employee e
		On edh.BusinessEntityID = e.BusinessEntityID
Group by edh.BusinessEntityID
order by JobtitleChange desc;

-- 20. Employees Earning More Than Department Average
SELECT eph.BusinessEntityID, d.Name AS Department, eph.Rate AS Salary
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.EmployeeDepartmentHistory edh ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE eph.Rate > (
    SELECT AVG(eph2.Rate)
    FROM HumanResources.EmployeePayHistory eph2
    JOIN HumanResources.EmployeeDepartmentHistory edh2 ON eph2.BusinessEntityID = edh2.BusinessEntityID
    WHERE edh2.DepartmentID = edh.DepartmentID
);

-- 21. Employees jinhe ek se zyada promotions mile
SELECT BusinessEntityID, COUNT(DISTINCT ShiftID) AS PromotionCount
FROM HumanResources.EmployeeDepartmentHistory
GROUP BY BusinessEntityID
HAVING COUNT(DISTINCT ShiftID) > 1;

-- 22. Employees with no salary hike/raise
SELECT BusinessEntityID
FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID
HAVING COUNT(*) = 1;

-- 23. Department-wise average pay
SELECT d.Name AS Department, AVG(eph.Rate) AS AvgPay
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.EmployeeDepartmentHistory edh ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
GROUP BY d.Name;

-- 24. Highest Tenure Employee(s) in Company
SELECT TOP 1 BusinessEntityID, DATEDIFF(year, HireDate, '2013-05-30') AS Tenure
FROM HumanResources.Employee
ORDER BY Tenure DESC;

-- 25.  Employee Rank by Salary Within Department 
Select
	e.BusinessEntityID,
	d.Name As Department,
	eph.Rate as Salary,
	RANK() Over (Partition by d.Name Order by eph.Rate Desc) as SalaryRankInDept
from HumanResources.Employee e
Join HumanResources.EmployeeDepartmentHistory edh		On e.BusinessEntityID = edh.BusinessEntityID
Join HumanResources.EmployeePayHistory eph				On edh.BusinessEntityID = eph.BusinessEntityID
Join HumanResources.Department d						On edh.DepartmentID = d.DepartmentID
Where eph.Rate Is Not Null;

-- 26. Average, Min, Max Tenure by Department

WITH EmpTenure AS (
  SELECT 
    e.BusinessEntityID,
    d.Name AS Department,
    DATEDIFF(YEAR, e.HireDate, '2013-05-30') AS Tenure
  FROM HumanResources.Employee e
  JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
  JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
)
SELECT 
  Department,
  Tenure,
  AVG(Tenure) OVER (PARTITION BY Department) AS AvgTenure,
  MIN(Tenure) OVER (PARTITION BY Department) AS MinTenure,
  MAX(Tenure) OVER (PARTITION BY Department) AS MaxTenure
FROM EmpTenure
GROUP BY Department, Tenure;

-- 27. New Hires with Running Total by Month
WITH MonthlyHires AS (
  SELECT
    FORMAT(HireDate, 'yyyy-MM') AS HireMonth,
    COUNT(*) AS Hires
  FROM HumanResources.Employee
  WHERE HireDate >= DATEADD(YEAR, -4, '2013-05-30')
  GROUP BY FORMAT(HireDate, 'yyyy-MM')
)
SELECT 
  HireMonth,
  Hires,
  SUM(Hires) OVER (ORDER BY HireMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM MonthlyHires
ORDER BY HireMonth

-- 28. Previous and Next Job Title Change Per Employee (LEAD/LAG)
WITH EmpJobHistory AS (
  SELECT 
    e.BusinessEntityID,
    e.JobTitle,
    edh.StartDate
  FROM HumanResources.Employee e
  JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
)
SELECT
  BusinessEntityID,
  JobTitle,
  StartDate,
  LAG(JobTitle,1) OVER (PARTITION BY BusinessEntityID ORDER BY StartDate) AS PrevJobTitle,
  LEAD(JobTitle,1) OVER (PARTITION BY BusinessEntityID ORDER BY StartDate) AS NextJobTitle
FROM EmpJobHistory
ORDER BY BusinessEntityID, StartDate;

-- 29. Find Second Highest Salary by Department (DENSE_RANK)
SELECT Distinct Department, Salary
FROM (
  SELECT d.Name AS Department, eph.Rate AS Salary,
         DENSE_RANK() OVER (PARTITION BY d.Name ORDER BY eph.Rate DESC) AS SalaryRank
  FROM HumanResources.EmployeePayHistory eph
  JOIN HumanResources.EmployeeDepartmentHistory edh ON eph.BusinessEntityID = edh.BusinessEntityID
  JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
) AS RankedSalaries
WHERE SalaryRank = 2;

-- 30
WITH MonthlyHires AS (
  SELECT
    FORMAT(HireDate, 'yyyy-MM') AS HireMonth,
    COUNT(*) AS Hires
  FROM HumanResources.Employee
  GROUP BY FORMAT(HireDate, 'yyyy-MM')
)
SELECT
  HireMonth,
  Hires,
  Convert(decimal,AVG(Hires) OVER (ORDER BY HireMonth ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)) AS Rolling12MoAvgHires
FROM MonthlyHires
ORDER BY HireMonth;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


