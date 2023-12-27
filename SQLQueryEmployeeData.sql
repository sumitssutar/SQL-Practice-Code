CREATE TABLE EmployeeDemographics
(EmployeeID int,
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
)

CREATE TABLE EmployeeSalary
(EmployeeID int,
JobTitle varchar(50),
Salary int)




INSERT INTO EmployeeDemographics VALUES
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male')


INSERT INTO EmployeeSalary VALUES
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 48000),
(1009, 'Accountant', 42000)


SELECT *
FROM [SQL Tutorial].dbo.EmployeeSalary


SELECT *
FROM EmployeeDemographics
WHERE FirstName IN ('Jim', 'Michael')


SELECT Gender, COUNT(Gender) Gender_Count
From EmployeeDemographics
WHERE Age > 31
GROUP BY Gender
ORDER BY Gender DESC


SELECT * 
FROM EmployeeDemographics
ORDER BY AgeID


CREATE TABLE WareHouseEmployeeDemographics
(EmployeeID int,
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
)


INSERT INTO WareHouseEmployeeDemographics Values
(1013, 'Darryl', 'Philbin', NULL, 'Male'),
(1050, 'Roy', 'Anderson', 31, 'Male'),
(1051, 'Hidetoshi', 'Hasagawa', 40, 'Male'),
(1052, 'Val', 'Johnson', 31, 'Female')


SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
FULL OUTER JOIN [SQL Tutorial].dbo.WareHouseEmployeeDemographics
    ON EmployeeDemographics.EmployeeID = WareHouseEmployeeDemographics.EmployeeID


SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
UNION ALL
SELECT *
FROM [SQL Tutorial].DBO.WareHouseEmployeeDemographics
ORDER BY EmployeeID


SELECT FirstName, LastName, Age,
CASE 
    WHEN Age > 30 THEN 'OLD'
	WHEN Age BETWEEN 27 AND 30 THEN 'YOUNG'
	ELSE 'BABY'
END
FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE Age IS NOT NULL
ORDER BY Age


SELECT FirstName, LastName, JobTitle, Salary,
CASE
    WHEN JobTitle = 'Salesman' THEN Salary + (Salary * .10)
	WHEN JobTitle = 'Accountant' THEN Salary + (Salary * .05)
	WHEN JobTitle = 'HR' THEN Salary + (Salary * .00001)
	ELSE Salary + (Salary * .03)
END AS SalaryAfterRaise
FROM [SQL Tutorial].dbo.EmployeeDemographics
JOIN [SQL Tutorial].dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


SELECT JobTitle, AVG(Salary)
FROM [SQL Tutorial].dbo.EmployeeDemographics
JOIN [SQL Tutorial].dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitle
HAVING AVG(Salary) > 45000
ORDER BY AVG(Salary)


SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics


UPDATE [SQL Tutorial].dbo.EmployeeDemographics
SET EmployeeID = 1012
WHERE FirstName = 'Kevin' AND LastName = 'Malone'


UPDATE [SQL Tutorial].dbo.EmployeeDemographics
SET Age = 31, Gender = 'Female'
WHERE FirstName = 'Kevin' AND LastName = 'Malone'


DELETE FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE EmployeeID = 1005


SELECT FirstName + ' ' + LastName AS FullName
FROM [SQL Tutorial].dbo.EmployeeDemographics

SELECT Demo.EmployeeID, Sal.Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics AS Demo
JOIN [SQL Tutorial].dbo.EmployeeSalary AS Sal
    ON Demo.EmployeeID = Sal.EmployeeID

SELECT FirstName, LastName, Gender, Salary,
    COUNT(Gender) OVER (PARTITION BY Gender) AS TotalGender
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
    ON Dem.EmployeeID = Sal.EmployeeID


WITH CTE_Employee as 
(SELECT FirstName, LastName, Gender, Salary,
    COUNT(Gender) OVER (PARTITION BY Gender) AS TotalGender,
	AVG(Salary) OVER (PARTITION BY Gender) as AvgSalary
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
    ON Dem.EmployeeID = Sal.EmployeeID
WHERE Salary > 45000
)


SELECT *
FROM CTE_Employee


CREATE TABLE #temp_Employee(
EmployeeID int,
JobTitle varchar(100),
Salary int
)


SELECT * 
FROM #temp_Employee


INSERT INTO #temp_Employee VALUES (
1001, 'HR', 45000
)
INSERT INTO #temp_Employee
SELECT *
FROM [SQL Tutorial]..EmployeeSalary



DROP TABLE IF EXISTS #temp_Employee2
CREATE TABLE #Temp_Employee2 (
JobTitle varchar(50),
EmployeePerJob int,
AvgAge int,
AvgSalary int)


INSERT INTO #Temp_Employee2
SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(Salary)
FROM [SQL Tutorial]..EmployeeDemographics Dem
JOIN [SQL Tutorial]..EmployeeSalary Sal
    ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY JobTitle


SELECT *
FROM #Temp_Employee2

CREATE TABLE EmployeeErrors (
EmployeeID varchar(50)
,FirstName varchar(50)
,LastName varchar(50)
)


Insert into EmployeeErrors Values 
('1001  ', 'Jimbo', 'Halbert')
,('  1002', 'Pamela', 'Beasely')
,('1005', 'TOby', 'Flenderson - Fired')


Select *
From EmployeeErrors


SELECT EmployeeID, TRIM(EmployeeID) as IDTRIM
FROM EmployeeErrors


SELECT EmployeeID, LTRIM(EmployeeID) as IDTRIM
FROM EmployeeErrors


SELECT EmployeeID, RTRIM(EmployeeID) as IDTRIM
FROM EmployeeErrors

Select *
From EmployeeErrors


SELECT LastName, REPLACE(LastName, '- Fired', '') as LastNameFixed
FROM EmployeeErrors


SELECT SUBSTRING(FirstName,1,3)
FROM EmployeeErrors


SELECT SUBSTRING(FirstName,3,3)
FROM EmployeeErrors


Select *
From EmployeeErrors


UPDATE EmployeeErrors
SET FirstName = 'Toby'
WHERE EmployeeID = '1005'


SELECT FirstName, UPPER(FirstName) CapitalsFN
FROM EmployeeErro


CREATE PROCEDURE TEST
AS 
SELECT *
FROM EmployeeDemographics

EXEC TEST


SELECT *
FROM EmployeeSalary

SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM EmployeeSalary) AS AllAvgSalary
FROM EmployeeSalary


SELECT EmployeeID, Salary, AVG(Salary) OVER () AS AllAvgSalary
FROM EmployeeSalary


SELECT EmployeeID, Salary, AVG(Salary) AS AllAvgSalary
FROM EmployeeSalary
GROUP BY EmployeeID, Salary
ORDER BY 1,2


SELECT a.EmployeeID, AllAvgSalary
FROM (SELECT EmployeeID, Salary, AVG(Salary) OVER () AS AllAvgSalary 
      FROM EmployeeSalary) a


SELECT EmployeeID, JobTitle, Salary
FROM EmployeeSalary
WHERE EmployeeID IN (
		SELECT EmployeeID
		FROM EmployeeDemographics
		WHERE Age > 30)


