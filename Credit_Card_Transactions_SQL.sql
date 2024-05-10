use sql_portfolio_project;
show tables;
select * from credit_card_transactions;

																						-- COMPLEX QUERIES --
                                                                                        

-- Q1  write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends --
WITH CTE AS (
SELECT CITY, SUM(AMOUNT) AS TOTAL_SPEND, ROW_NUMBER() OVER (ORDER BY SUM(AMOUNT) DESC) AS RNK
FROM CREDIT_CARD_TRANSACTIONS
GROUP BY CITY)
SELECT CITY, TOTAL_SPEND, ROUND(TOTAL_SPEND/(SELECT SUM(AMOUNT) FROM CREDIT_CARD_TRANSACTIONS)*100,2) AS CONTRIBUTION_IN_PERCENT FROM CTE WHERE RNK <=5;

-- Q2 write a query to print highest spend month and amount spent in that month for each card type --
select month(date) as month_, card_type, sum(amount)
from credit_card_transactions
group by month(date), card_type
having month_ = (with cte as (
select month(date) as month_, sum(amount) as total_sum, row_number() over (order by sum(amount) desc) as rnk
from credit_card_transactions
group by month(date)
)
select month_ from cte where rnk = 1);


-- Q3 write a query to find city which had lowest percentage spend for gold card type --
WITH CTE AS (
SELECT CITY, SUM(AMOUNT) AS TOTAL_SPEND, ROW_NUMBER() OVER (ORDER BY SUM(AMOUNT)) AS RNK FROM CREDIT_CARD_TRANSACTIONS WHERE CARD_TYPE = 'GOLD' 
GROUP BY CITY
)
SELECT CITY, TOTAL_SPEND/(SELECT SUM(AMOUNT) FROM CREDIT_CARD_TRANSACTIONS WHERE CARD_TYPE = 'GOLD')*100 AS TOTAL_CONTRIBUTION_IN_PERCENT FROM CTE WHERE RNK = 1;

-- Q4 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel) --
WITH CTE AS (
SELECT CITY, EXP_TYPE, SUM(AMOUNT) AS TOTAL_SPEND
FROM CREDIT_CARD_TRANSACTIONS
GROUP BY CITY, EXP_TYPE
ORDER BY CITY
),
CTE2 AS (
SELECT *, RANK() OVER (PARTITION BY CITY ORDER BY TOTAL_SPEND DESC) AS RNK, RANK() OVER (PARTITION BY CITY ORDER BY TOTAL_SPEND) AS RNK2 FROM CTE
),
CTE3 AS (
SELECT CITY, CASE WHEN RNK2 = 1 THEN EXP_TYPE END AS LOWEST_EXP_TYPE, CASE WHEN RNK = 1 THEN EXP_TYPE END AS HIGH
FROM CTE2),
CTE4 AS (
SELECT *, LEAD(HIGH,1) OVER(PARTITION BY CITY) AS HIGHEST_EXP_TYPE FROM CTE3 WHERE HIGH IS NOT NULL OR LOWEST_EXP_TYPE IS NOT NULL
)
SELECT CITY, HIGHEST_EXP_TYPE, LOWEST_EXP_TYPE
FROM CTE4
WHERE HIGHEST_EXP_TYPE IS NOT NULL AND LOWEST_EXP_TYPE IS NOT NULL;

-- Q5 write a query to find percentage contribution of spends by females for each expense type --
WITH CTE AS (
SELECT * FROM CREDIT_CARD_TRANSACTIONS
),
CTE2 AS (
SELECT EXP_TYPE, SUM(AMOUNT) AS TOTAL_SPEND
FROM CTE
GROUP BY EXP_TYPE
),
CTE3 AS (
SELECT EXP_TYPE, SUM(AMOUNT) AS TOTAL_SPEND_F
FROM CREDIT_CARD_TRANSACTIONS
WHERE GENDER = 'F'
GROUP BY EXP_TYPE
)
SELECT CTE2.EXP_TYPE, ROUND((CTE3.TOTAL_SPEND_F/CTE2.TOTAL_SPEND)*100,2) AS SPEND_BY_F_PERCENT
FROM CTE2
JOIN CTE3 
ON CTE2.EXP_TYPE = CTE3.EXP_TYPE;

-- Q6 during weekends which city has highest total spend to total no of transcations ratio --
WITH 
CTE AS (
select CITY,DATE,AMOUNT, weekday(DATE) AS DAY
FROM CREDIT_CARD_TRANSACTIONS
),
CTE2 AS (
SELECT * FROM CTE WHERE DAY = 0 OR DAY = 6
),
CTE3 AS (
SELECT CITY, COUNT(DAY) AS TOTAL_TRANSACTIONS, SUM(AMOUNT) AS TOTAL_SPEND
FROM CTE2
GROUP BY CITY
),
CTE4 AS (
SELECT CITY, ROUND(TOTAL_SPEND/TOTAL_TRANSACTIONS,2) AS RATIO, ROW_NUMBER() OVER (ORDER BY TOTAL_SPEND/TOTAL_TRANSACTIONS DESC) AS RNK
FROM CTE3
)
SELECT * FROM CTE4 WHERE RNK = 1;

-- Q7 which city took least number of days to reach its 500th transaction after the first transaction in that city
WITH
CTE AS (
SELECT CITY, DATE, ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY DATE) AS RNK
FROM CREDIT_CARD_TRANSACTIONS
),
CTE2 AS (
SELECT *, LEAD(RNK,1) OVER (PARTITION BY CITY) AS RNK2, LEAD(DATE,1) OVER (PARTITION BY CITY) AS DATE2 FROM CTE WHERE RNK = 1 OR RNK = 500
ORDER BY CITY
),
CTE3 AS (
SELECT CITY, DATE, DATE2 FROM CTE2
WHERE RNK = 1 AND RNK2 = 500 AND DATE2 IS NOT NULL
),
CTE4 AS (
SELECT CITY, TIMESTAMPDIFF(DAY,DATE,DATE2) AS DAYS_TAKEN,
 ROW_NUMBER() OVER (ORDER BY TIMESTAMPDIFF(DAY,DATE,DATE2)) AS RNK  
 FROM CTE3
)
SELECT CITY, DAYS_TAKEN FROM CTE4 WHERE RNK = 1;

                                                                                          -- THANK YOU --
