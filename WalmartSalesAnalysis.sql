create database if not exists Walmart;
use walmart;

create table if not exists Sales (
invoice_id	VARCHAR(30) not null primary key,
branch VARCHAR(5) not null,
city VARCHAR(30) not null,
customer_type VARCHAR(30) not null,
gender VARCHAR(10) not null,
product_line VARCHAR(100) not null,
unit_price	DECIMAL(10, 2) not null,
quantity INT not null,
VAT	 FLOAT(6, 4) not null,
total DECIMAL(10, 2) not null,
date DATETIME not null,
time TIME not null,
payment_method VARCHAR(15) not null,
cogs DECIMAL(10, 2) not null,
gross_margin_percentage	FLOAT(11, 9),
gross_income DECIMAL(10, 2),
rating FLOAT(2, 1)
);
-- drop table sales;
 
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(10);
UPDATE sales SET time_of_day =
(CASE WHEN time between '00:00:01' and '11:59:59' THEN "Morning"
WHEN time between '12:00:00' and '15:59:59' THEN "Afternoon"
ELSE  "Evening"
END);

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales SET day_name = dayname(date);
 
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales SET month_name = monthname(date);
 
-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------

SELECT *
FROM sales;

-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- In which city is each branch?
 SELECT 
	DISTINCT city,
    branch
FROM sales;

-- --------------------------------------------------------------------
-- --------------------- Product Analysis -----------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT
	count(DISTINCT product_line) no_of_product_line
FROM sales;

-- What is the most selling product line?
SELECT
	product_line,
	count(*) as frequency
FROM sales
GROUP BY product_line
ORDER BY 2 DESC;

-- What is the most comman payment method?
SELECT
	payment_method,
    count(*) frequency
FROM sales
GROUP BY payment_method
ORDER BY 2 DESC;

-- What is the total revenue by month?
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales 
GROUP BY month_name 
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY  city
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT
	product_line,
	SUM(vat) as total_VAT
FROM sales
GROUP BY product_line
ORDER BY 2 DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". (Good if its greater than average sales)
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > (select AVG(quantity) from sales) THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY 3 DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
	ROUND(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- -------------------- Customers Analysis -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	branch,
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender_cnt  DESC;
-- Gender per branch is more or less the same hence, I don't think has an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its more or less the same rating each time of the day alter

-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	branch,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY  branch, time_of_day
ORDER BY 3 DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a little more to get better ratings.

-- Which day of the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings

-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	avg(rating) avg_rating
FROM sales
WHERE branch = "A"
GROUP BY day_name
ORDER BY 2 DESC;

-- -------------- ------------------------------------------------------
-- --------------------- Sales Analysis --------------------------------
-- ---------------------------------------------------------------------

-- Number of sales per month
SELECT
	month_name,
	COUNT(*) AS no_of_sales
FROM sales
GROUP BY 1
ORDER BY 2 DESC;

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience a huge sales, the stores are filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	branch,
    ROUND(AVG(VAT), 2) AS avg_vat
FROM sales
GROUP BY 1 
ORDER BY avg_VAT DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(VAT)
FROM sales
GROUP BY customer_type
ORDER BY 2 DESC;

-- Which product_line has the most in VAT?
SELECT
	product_line,
	sum(VAT)
FROM sales
GROUP BY 1
ORDER BY 2 DESC;

-- --------------------------------------------------------------------
-- --------------------- Revenue & Profit -----------------------------
-- --------------------------------------------------------------------


SELECT 
	ROUND(SUM(VAT + cogs), 2) AS total_gross_sales
FROM sales;

SELECT 
	branch,
	ROUND(SUM(VAT + cogs), 2) AS gross_sales
FROM sales
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
	product_line,
	ROUND(SUM(VAT + cogs), 2) AS gross_sales
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


SELECT
	SUM(VAT + cogs) - SUM(cogs) AS total_gross_profit
FROM sales;

SELECT
	day_name, 
	ROUND((SUM(VAT + cogs) - SUM(cogs)), 2) AS gross_profit
FROM sales
GROUP BY 1
ORDER BY 2 DESC;

SELECT
	branch, 
	ROUND((SUM(VAT + cogs) - SUM(cogs)), 2) AS gross_profit
FROM sales 
GROUP BY 1
ORDER BY 2 DESC;
