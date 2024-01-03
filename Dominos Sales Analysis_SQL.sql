-- 1. How many customers do we have each day? Are there any peak hours?
SELECT
    DATE(date) AS order_date,
    COUNT(DISTINCT order_id) AS total_customers,
    EXTRACT(HOUR FROM time) AS hour_of_day
FROM Orders
GROUP BY order_date, hour_of_day
ORDER BY total_customers DESC;

-- 2. How many pizzas are typically in an order? Do we have any bestsellers?
-- Average number of pizzas per order
SELECT AVG(quantity) AS avg_pizzas_per_order
FROM Order_Details;

-- Bestselling pizzas
SELECT pizza_id, SUM(quantity) AS total_sold
FROM Order_Details
GROUP BY pizza_id
ORDER BY total_sold DESC
LIMIT 5;  -- Change the limit as needed to see more top sellers

-- 3. How much money did we make this year in each month? Can we identify any seasonality in the sales?
SELECT
    MONTHNAME(date) AS month,
    SUM(Price * quantity) AS revenue
FROM Orders
JOIN Order_Details ON Orders.order_id = Order_Details.order_id
JOIN Pizzas ON Order_Details.pizza_id = Pizzas.pizza_id
-- WHERE YEAR(date) = YEAR(CURDATE())  -- Replace with the desired year
GROUP BY month
ORDER BY revenue DESC;

-- 4. Are there any pizzas we should take off the menu, or any promotions we could leverage?
SELECT od.pizza_id, SUM(od.quantity) AS totalunitssold, (p.Price * SUM(od.quantity)) AS totalrevenue
FROM order_details od 
INNER JOIN pizzas p 
        ON od.pizza_id = p.pizza_id
GROUP BY od.pizza_id
ORDER BY totalunitssold
;


-- 5. What is the average order value for each pizza category (e.g., Vegetarian, Non-Vegetarian, etc.)?
WITH table1 AS (
SELECT o.order_id, o.date, od.pizza_id, od.quantity, CASE
  WHEN od.quantity = 4 THEN 4*p.price
  WHEN od.quantity = 3 THEN 3*p.price
  WHEN od.quantity = 2 THEN 2*p.price
ELSE p.price
END AS tprice, p.pizza_type_id, pt.Category
FROM orders o 
INNER JOIN order_details od
        ON o.order_id = od.order_id
INNER JOIN pizzas p
        ON od.pizza_id = p.pizza_id
INNER JOIN pizza_types pt
        ON p.pizza_type_id = pt.pizza_type_id
)

SELECT Category, AVG(tprice) AS Average_Order_Value
FROM table1
GROUP BY Category
ORDER BY Average_Order_Value desc;

-- 6. Are there any trends in sales based on the day of the week?

SELECT
    DAYNAME(date) AS day_of_week,
    SUM(Price * quantity) AS total_sales
FROM Orders
JOIN Order_Details ON Orders.order_id = Order_Details.order_id
JOIN Pizzas ON Order_Details.pizza_id = Pizzas.pizza_id
GROUP BY day_of_week
ORDER BY total_sales DESC;
