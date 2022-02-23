/* PROJECT DESCRIPTION
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money
they have spent and also which menu items are their favourites. Having this deeper connection with his customers will help him deliver
a better and more personalized experience for his loyal customers. */

-- CREATING A DATABASE FOR THE TABLES
CREATE DATABASE AnomaProject

-- CREATING A SCHEMA FOR THE TABLES
CREATE SCHEMA Danny

-- CREATING TABLES 
CREATE TABLE Danny.sales(customer_id VARCHAR(1),
						 order_date DATE,
						 product_id INT)

CREATE TABLE Danny.menu(product_id INT,
						product_name VARCHAR(10),
						price INT)

CREATE TABLE Danny.members(customer_id VARCHAR(1),
						   join_date TIMESTAMP)

-- INSERTING INTO TABLES
INSERT INTO Danny.sales
VALUES ('A', '2021-01-01',1),
	   ('A','2021-01-01',2),
	   ('A','2021-01-07',2),
	   ('A','2021-01-10',3),
	   ('A','2021-01-11',3),
	   ('A','2021-01-11',3),
	   ('B','2021-01-01',2),
	   ('B','2021-01-02',2),
	   ('B','2021-01-04',1),
	   ('B','2021-01-11',1),
	   ('B','2021-01-16',3),
	   ('B','2021-02-01',3),
	   ('C','2021-01-01',3),
	   ('C','2021-01-01',3),
	   ('C','2021-01-07',3)

INSERT INTO Danny.menu
VALUES (1,'sushi',10),
	   (2,'curry',15),
	   (3,'ramen',12)

-- Deleting Danny.menu because of error in inputting datatype
DROP TABLE Danny.members

-- CREATING Danny.members table
CREATE TABLE Danny.members(customer_id VARCHAR(1),
						   join_date DATE) 

INSERT INTO Danny.members
VALUES ('A','2021-01-07'),
	   ('B','2021-01-09')

SELECT *
FROM Danny.sales
SELECT *
FROM Danny.menu
SELECT *
FROM Danny.members

-- Showing the total amount each customer spent at the restaurant
SELECT sales.customer_id, SUM(menu.price) AS total_amount_spent
FROM Danny.sales AS sales
JOIN Danny.menu AS menu
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id

-- Showing how many days each customer visited the restaurant
SELECT customer_id, COUNT(DISTINCT(order_date)) AS total_visits
FROM Danny.sales
GROUP BY customer_id

-- Showing the first item from the menu purchased by each customer
WITH purchases_first_cte AS (
							 SELECT customer_id, order_date, product_name,
							 DENSE_RANK() OVER(PARTITION BY sales.customer_id
							 ORDER BY sales.order_date) AS rank
					     FROM AnomaProject.Danny.sales AS sales
						 JOIN AnomaProject.Danny.menu AS menu
						 ON sales.product_id = menu.product_id
						    )
SELECT customer_id, product_name
FROM purchases_first_cte
WHERE RANK = 1
GROUP BY customer_id,product_name

-- Showing the most purchased item on the menu and how many times it was purchased by all customers
SELECT product_name, (COUNT(sales.product_id)) AS highest_purchased
FROM AnomaProject.Danny.sales AS sales
JOIN AnomaProject.Danny.menu AS menu
ON sales.product_id = menu.product_id
GROUP BY sales.product_id, product_name
ORDER BY highest_purchased DESC;

-- Showing what item is the most popular for each customer
WITH most_popular_cte AS(SELECT sales.customer_id, menu.product_name,
						 COUNT(menu.product_id) AS orders_count,
						 DENSE_RANK() OVER(PARTITION BY sales.customer_id
						 ORDER BY COUNT(sales.customer_id) DESC) AS RANK
					  FROM AnomaProject.Danny.menu AS menu
					  JOIN AnomaProject.Danny.sales AS sales
					  ON menu.product_id = sales.product_id
					  GROUP BY sales.customer_id, menu.product_name)
SELECT customer_id, product_name, orders_count
FROM most_popular_cte
WHERE RANK = 1

-- Showing which item the customer purchased after they became a member
WITH member_purchased AS(SELECT sales.customer_id, members.join_date, sales.order_date, sales.product_id,
						 DENSE_RANK() OVER(PARTITION BY sales.customer_id
						 ORDER BY sales.order_date) AS RANK
						 FROM AnomaProject.Danny.sales AS sales
						 JOIN AnomaProject.Danny.members AS members
						 ON sales.customer_id = members.customer_id
						 WHERE sales.order_date >= members.join_date)
SELECT member_purchased.customer_id, member_purchased.order_date, menuu.product_name
FROM member_purchased 
JOIN AnomaProject.Danny.menu AS menuu
ON member_purchased.product_id = menuu.product_id
WHERE RANK = 1;

-- Showing Which item the customer purchased before they became a member
WITH customer_purchased AS(SELECT sales.customer_id, members.join_date, sales.order_date, sales.product_id,
						   DENSE_RANK() OVER(PARTITION BY sales.customer_id
						   ORDER BY sales.order_date DESC) AS RANK
						   FROM AnomaProject.Danny.sales AS sales
						   JOIN AnomaProject.Danny.members AS members
						   ON sales.customer_id = members.customer_id
						   WHERE sales.order_date <= members.join_date)
SELECT customer_purchased.customer_id, customer_purchased.order_date, menuu.product_name
FROM customer_purchased
JOIN AnomaProject.Danny.menu AS menuu
ON customer_purchased.product_id = menuu.product_id
WHERE RANK = 1;

-- Showing the total items and amount spent by each member before they became a member
SELECT sales.customer_id, COUNT(DISTINCT sales.product_id) AS item_count, SUM(menu.price) AS total
FROM AnomaProject.Danny.sales AS sales
JOIN AnomaProject.Danny.members AS members
ON sales.customer_id = members.customer_id
JOIN AnomaProject.Danny.menu AS menu
ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id

-- Showing how many points each customer would get if each $1 spent equates to 10 points and sushi has a 2x points multiplier
WITH spent_points_cte AS(SELECT *, CASE 
									WHEN product_id = 1
									THEN price * 20
									ELSE price * 10
									END AS sushi_points
					   FROM AnomaProject.Danny.menu)
SELECT sales.customer_id, SUM(sp.sushi_points) AS total_pointss
FROM spent_points_cte AS sp
JOIN AnomaProject.Danny.sales
ON sp.product_id = sales.product_id
GROUP BY sales.customer_id