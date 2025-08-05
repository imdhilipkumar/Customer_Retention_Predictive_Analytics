Select * from churn;


-- Data Cleaning
SELECT TOP 10 * FROM churn;


--1. Finding the total number of customers
SELECT COUNT(*) AS Total_Customers
FROM churn;

--2. Checking for duplicate rows


SELECT 
    customerID, COUNT(*) AS Duplicate_Count
FROM churn
GROUP BY customerID
HAVING COUNT(*) > 1;

--3. Checking for null values


SELECT 
    SUM(CASE WHEN customerID IS NULL THEN 1 ELSE 0 END) AS customerID_Nulls,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_Nulls,
    SUM(CASE WHEN SeniorCitizen IS NULL THEN 1 ELSE 0 END) AS SeniorCitizen_Nulls,
    SUM(CASE WHEN Partner IS NULL THEN 1 ELSE 0 END) AS Partner_Nulls,
    SUM(CASE WHEN Dependents IS NULL THEN 1 ELSE 0 END) AS Dependents_Nulls,
    SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS tenure_Nulls,
    SUM(CASE WHEN PhoneService IS NULL THEN 1 ELSE 0 END) AS PhoneService_Nulls,
    SUM(CASE WHEN MultipleLines IS NULL THEN 1 ELSE 0 END) AS MultipleLines_Nulls,
    SUM(CASE WHEN InternetService IS NULL THEN 1 ELSE 0 END) AS InternetService_Nulls,
    SUM(CASE WHEN OnlineSecurity IS NULL THEN 1 ELSE 0 END) AS OnlineSecurity_Nulls,
    SUM(CASE WHEN OnlineBackup IS NULL THEN 1 ELSE 0 END) AS OnlineBackup_Nulls,
    SUM(CASE WHEN DeviceProtection IS NULL THEN 1 ELSE 0 END) AS DeviceProtection_Nulls,
    SUM(CASE WHEN TechSupport IS NULL THEN 1 ELSE 0 END) AS TechSupport_Nulls,
    SUM(CASE WHEN StreamingTV IS NULL THEN 1 ELSE 0 END) AS StreamingTV_Nulls,
    SUM(CASE WHEN StreamingMovies IS NULL THEN 1 ELSE 0 END) AS StreamingMovies_Nulls,
    SUM(CASE WHEN Contract IS NULL THEN 1 ELSE 0 END) AS Contract_Nulls,
    SUM(CASE WHEN PaperlessBilling IS NULL THEN 1 ELSE 0 END) AS PaperlessBilling_Nulls,
    SUM(CASE WHEN PaymentMethod IS NULL THEN 1 ELSE 0 END) AS PaymentMethod_Nulls,
    SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END) AS MonthlyCharges_Nulls,
    SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) AS TotalCharges_Nulls,
    SUM(CASE WHEN Churn IS NULL THEN 1 ELSE 0 END) AS Churn_Nulls
FROM churn;


-- 3.1 Handling null values



-- Handle NULLs in bit columns
UPDATE churn SET MultipleLines = 0 WHERE MultipleLines IS NULL;
UPDATE churn SET OnlineSecurity = 0 WHERE OnlineSecurity IS NULL;
UPDATE churn SET OnlineBackup = 0 WHERE OnlineBackup IS NULL;
UPDATE churn SET DeviceProtection = 0 WHERE DeviceProtection IS NULL;
UPDATE churn SET TechSupport = 0 WHERE TechSupport IS NULL;
UPDATE churn SET StreamingTV = 0 WHERE StreamingTV IS NULL;
UPDATE churn SET StreamingMovies = 0 WHERE StreamingMovies IS NULL;

-- TotalCharges is float, set NULLs to 0
UPDATE churn SET TotalCharges = 0 WHERE TotalCharges IS NULL;


--4. Creating a new column from an already existing “churn” column

ALTER TABLE churn
ADD Churn_status NVARCHAR(10);

UPDATE churn
SET Churn_status = 
    CASE 
        WHEN Churn = 1 THEN 'Yes'
        WHEN Churn = 0 THEN 'No'
    END;

SELECT TOP 10 customerID, Churn, Churn_status
FROM churn;

--- Checking Before the Execution for Explore Data Analysis...
SELECT 
    SUM(CASE WHEN customerID IS NULL THEN 1 ELSE 0 END) AS customerID_Nulls,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_Nulls,
    SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS tenure_Nulls,
    SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END) AS MonthlyCharges_Nulls,
    SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) AS TotalCharges_Nulls,
    SUM(CASE WHEN Churn IS NULL THEN 1 ELSE 0 END) AS Churn_Nulls
FROM churn;

-- Exploratory Analysis

-- How much revenue was lost to churned customers?

SELECT 
    SUM(TotalCharges) AS Lost_Revenue
FROM churn
WHERE Churn = 1;

SELECT 
    COUNT(*) AS Churned_Customers,
    SUM(TotalCharges) AS Lost_Revenue
FROM churn
WHERE Churn = 1;


-- What’s the typical tenure for churned customers?

SELECT 
    COUNT(*) AS Churned_Customers,
    AVG(tenure * 1.0) AS Avg_Tenure,
    MIN(tenure) AS Min_Tenure,
    MAX(tenure) AS Max_Tenure
FROM churn
WHERE Churn = 1;

--  Churn rate by Contract type

SELECT 
    Contract,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Churn_Rate_Percent
FROM churn
GROUP BY Contract;




-- Average Monthly Charges: Churned vs Not

SELECT 
    Churn,
    AVG(MonthlyCharges) AS Avg_MonthlyCharges,
    AVG(tenure) AS Avg_Tenure
FROM churn
GROUP BY Churn;

-- What offers did churned customers have?

SELECT 
    Contract,
    InternetService,
    PaymentMethod,
    OnlineSecurity,
    TechSupport,
    StreamingTV,
    COUNT(*) AS Churned_Customers
FROM churn
WHERE Churn = 1
GROUP BY 
    Contract, InternetService, PaymentMethod, 
    OnlineSecurity, TechSupport, StreamingTV
ORDER BY Churned_Customers DESC;



-- Are high value customers at risk of churning?

SELECT 
    Churn,
    AVG(MonthlyCharges) AS AvgMonthlyCharges,
    AVG(TotalCharges) AS AvgTotalCharges
FROM churn
GROUP BY Churn;
