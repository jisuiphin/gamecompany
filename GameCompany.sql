
USE GameCompany

--1
SELECT 'C.CompanyID' = REPLACE(C.CompanyID,'C','Company '),
CompanyName ,
'CompanyAddress' = CompanyAddress + 'No.' + RIGHT(C.CompanyID,1),
HT.StartDate,
HT.EndDate
FROM Company C,
HeaderTransaction HT
WHERE C.CompanyID = HT.CompanyID
AND CompanyName LIKE '%Ironworks%'

--2
SELECT 'Transaction Code' = 'TR-' + RIGHT(HT.TransactionID,1),
P.ProjectID,
ProjectName,
Revenue,
ProjectBudget,
'Profit' = Revenue - ProjectBudget
FROM HeaderTransaction HT
JOIN DetailTransaction DT ON DT.TransactionID = HT.TransactionID
JOIN Project P ON P.ProjectID = DT.ProjectID
WHERE Revenue BETWEEN 100000000 AND 200000000

--3
SELECT C.CompanyID,
D.DeveloperID,
'Tax Revenue' = CAST(0.1 * AVG(Revenue) AS INT)
FROM Developer D
JOIN HeaderTransaction HT ON HT.DeveloperID = D.DeveloperID
JOIN Company C ON HT.CompanyID = C.CompanyID
JOIN DetailTransaction DT ON DT.TransactionID = HT.TransactionID
WHERE DAY(StartDate) BETWEEN 1 AND 4
GROUP BY C.CompanyID, D.DeveloperID

--4
SELECT 'Developer Lastname' = REVERSE(SUBSTRING(REVERSE(DeveloperName),1,CHARINDEX(' ',REVERSE(DeveloperName)))),
DeveloperGender,
ProjectName,
'Budget' = ProjectBudget,
'Total Budget' = SUM(ProjectBudget),
'Developer Count For Specific Project' = COUNT(HT.TransactionID)
FROM Developer D
JOIN HeaderTransaction HT ON D.DeveloperID = HT.DeveloperID
JOIN DetailTransaction DT ON DT.TransactionID = HT.TransactionID
JOIN Project P ON P.ProjectID = DT.ProjectID
WHERE DeveloperGender = 'Male'
AND ProjectName LIKE 'Swift Eagle'
GROUP BY DeveloperName, ProjectName, DeveloperGender, ProjectBudget
UNION
SELECT 'Developer Lastname' = REVERSE(SUBSTRING(REVERSE(DeveloperName),1,CHARINDEX(' ',REVERSE(DeveloperName)))),
DeveloperGender,
ProjectName,
'Budget' = ProjectBudget,
'Total Budget' = SUM(ProjectBudget),
'Developer Count For Specific Project' = COUNT(HT.TransactionID)
FROM Developer D
JOIN HeaderTransaction HT ON D.DeveloperID = HT.DeveloperID
JOIN DetailTransaction DT ON DT.TransactionID = HT.TransactionID
JOIN Project P ON P.ProjectID = DT.ProjectID
WHERE DeveloperGender = 'Female'
AND ProjectName LIKE 'Eastern Windshield'
GROUP BY DeveloperName, ProjectName, DeveloperGender, ProjectBudget

--5
SELECT P.ProjectID,
'ProjectName' = UPPER(ProjectName),
'EndDate' = CONVERT(varchar,EndDate,107)
FROM Project P
JOIN DetailTransaction DT ON P.ProjectID = DT.ProjectID
JOIN HeaderTransaction HT ON HT.TransactionID = DT.TransactionID
WHERE Revenue < 600000000
AND EXISTS(
		  SELECT CompanyID
		  FROM Company
		  WHERE CompanyAddress LIKE 'Nullam%'
		  AND HT.CompanyID = CompanyID
		  )

--6
SELECT DeveloperName,
	   Revenue,
	   'Day of Year' = DATENAME(DAYOFYEAR,StartDate),
	   'Development Year' = CONVERT(VARCHAR, DATEDIFF(YEAR, StartDate, EndDate)) + ' Year(s)'
FROM Developer D
JOIN HeaderTransaction HT ON D.DeveloperID = HT.DeveloperID
JOIN DetailTransaction DT ON DT.TransactionID = HT.TransactionID
JOIN Project P ON P.ProjectID = DT.ProjectID,
(
	SELECT 'AVGBUDGET' = AVG(ProjectBudget)
	FROM Project
) AS AverageProjectBudget
WHERE ProjectBudget > AverageProjectBudget.AVGBUDGET
AND DATEDIFF(YEAR, StartDate, EndDate) > 0
AND Revenue < 500000000

--7

CREATE VIEW [View Developer] AS

SELECT D.DeveloperID,
DeveloperName,
DeveloperAddress
FROM Developer D
JOIN HeaderTransaction HT ON HT.DeveloperID = D.DeveloperID
WHERE MONTH(StartDate) BETWEEN 4 AND 7

SELECT * FROM [View Developer]

--8
CREATE VIEW [Revenue per Month] AS

SELECT DeveloperName,
DeveloperGender,
'Revenue per Month' = 'Rp. ' + CAST(SUM(Revenue)/12 AS VARCHAR)
FROM Developer D
JOIN HeaderTransaction HT ON D.DeveloperID = HT.DeveloperID
JOIN DetailTransaction DT ON DT.TransactionID = HT.TransactionID
WHERE YEAR(EndDate) = 2015
AND DeveloperAddress LIKE 'Colonial Street'
GROUP BY  DeveloperName, DeveloperGender

SELECT * FROM [Revenue per Month]

--9

BEGIN TRAN

SELECT * FROM Developer

ALTER TABLE DEVELOPER
ADD DeveloperEmail VARCHAR(20)

ALTER TABLE DEVELOPER
ADD CONSTRAINT DEVELOPEREMAIL CHECK(LEN(DEVELOPEREMAIL) BETWEEN 5 AND 30)

SELECT * FROM Developer

ROLLBACK

--10

BEGIN TRAN

SELECT * FROM Developer

DELETE Developer
FROM Developer D 
JOIN HeaderTransaction HT ON HT.DeveloperID = D.DeveloperID
JOIN DetailTransaction DT ON DT.TransactionID = HT.TransactionID
WHERE Revenue < 200000000 
AND YEAR(EndDate) = 2015

SELECT * FROM Developer

ROLLBACK
