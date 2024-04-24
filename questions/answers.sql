-- Part 2a --
--1. What is the most ordered item based on the number of times it appears in an order cart that checked out successfully? you are expected to return the product_id, and product_name and num_times_in_successful_orders where:

-- product_id: the uuid string uniquely representing the product
-- product_name: the name of the product as provided in the product table
-- the number of times the product appeared in a a users cart that was successfully checked out. if ten customers added the item to their carts and only 8 of them successfully checked out and paid, then the answer should be 8 not 10.

/*
Steps taken
Calculate Total Quantity: The CTE, most_ordered_items, computes the total quantity of each product across all successful orders.
Rank Products by Popularity: The CTE, rank_most_ordered_items, assigns a rank to each product based on the total quantity in descending order.
Select Most Ordered Product: Retrieves the product with the highest rank, i.e., the product with the most orders in successful transactions, and displays its Id, name, and total quantity.
*/
WITH
	most_ordered_items AS (
		SELECT
			id AS product_id,
			name AS product_name,
			sum(quantity) AS num_times_in_successful_orders
		FROM
			alt_school.orders o
			JOIN alt_school.line_items li USING (order_id)
			JOIN alt_school.products p ON li.item_id = p.id
		WHERE
			status = 'success'
		GROUP BY
			id,
			name,
			status
	),
	rank_most_ordered_items AS (
		SELECT
			RANK() OVER (
				ORDER BY
					num_times_in_successful_orders DESC
			) rank_row
		FROM
			most_ordered_items
	)
SELECT
	product_id,
	product_name,
	num_times_in_successful_orders
FROM
	rank_most_ordered_items
WHERE
	rank_row = 1;


-- 2. Without considering currency, and without using the line_item table, find the top 5 spenders you are expected to return the customer_id, location, total_spend where:
-- customer_id: uuid string that uniquely identifies a customer
-- location - the customer's location
-- total_spend - the total amount of money spent on orders


-- Part 2b
-- 1. Using the events table, Determine the most common location (country) where successful checkouts occurred. return location and checkout_count where:
-- location: the name of the location
-- checkout_count: the number of checkouts that occured in the location



-- 2. Using the events table, identify the customers who abandoned their carts and count the number of events (excluding visits) that occurred before the abandonment. return the customer_id and num_events where:
-- customer_id: id uniquely identifying the customers
-- num_events: the number of events excluding visits that occured before abandonment


-- 3. Find the average number of visits per customer, considering only customers who completed a checkout! return average_visits to 2 decimal place
-- average_visits: this number is a metric that suggests the avearge number of times a customer visits the website before they make a successful transaction!

