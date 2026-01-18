CREATE DATABASE walmart_db;
use walmart_db;

SELECT COUNT(*) FROM walmart;
SELECT * from walmart LIMIT 10;

-- Count of distinct branches
SELECT COUNT(DISTINCT branch) FROM walmart;

-- Minimum quantity sold
SELECT min(quantity) FROM walmart;


-- Business Problems


-- 1: Find different payment method and number of transactions, number of quantity sold
SELECT 
	payment_method,
    COUNT(*) as no_of_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;


-- 2: Identify the highest-rated category in each branch, displaying the branch, category, and avg_rating

SELECT branch, category, avg_rating
FROM (
	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rating_rank
	FROM walmart
	GROUP BY branch, category
) AS ranked	
WHERE rating_rank = 1;


-- 3: Identify the busiest day for each branch based on the number of transactions

SELECT branch, day_name, no_of_transactions
from (
	SELECT
		branch,
		DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
		COUNT(*) AS no_of_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) desc) AS transaction_rank
    FROM walmart
	GROUP BY branch, day_name
) AS ranked
WHERE transaction_rank = 1;


-- 4: Calculate the total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) as no_of_qty_sold
FROM walmart
GROUP BY payment_method;


-- 5: Determine the average, minimum, and maximum rating of categories for each city.
-- List the city, category, min_rating, avg_rating, and max_rating.

SELECT 
	city,
    category,
	MIN(rating) AS min_rating,
    AVG(rating) AS avg_rating,
	MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category;


-- 6: Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest.

SELECT
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) as total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
    
    
-- 7: Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte AS (
	SELECT
		branch,
		payment_method,
		COUNT(*) AS total_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM walmart
	GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE ranking = 1;


-- 8: Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- FIND out each of the shift and number of invoices

SELECT
	branch,
    CASE
		WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC; 


-- 9: Identify the 5 branches with the highest revenue decrease ratio 
-- from last year to current year (e.g., 2022 to 2023)
-- revenue_decrease_ratio = last_year_revenue - current_year_revenue / last_year_revenue * 100

WITH revenue_2022 AS (
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
	GROUP BY branch
),
revenue_2023 AS (
	SELECT 
		branch,
        SUM(total) as revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT
	r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;