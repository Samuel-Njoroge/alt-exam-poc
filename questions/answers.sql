-- Part 2a --
--1. What is the most ordered item based on the number of times it appears in an order cart that checked out successfully? you are expected to return the product_id, and product_name and num_times_in_successful_orders where:

-- product_id: the uuid string uniquely representing the product
-- product_name: the name of the product as provided in the product table
-- the number of times the product appeared in a a users cart that was successfully checked out. if ten customers added the item to their carts and only 8 of them successfully checked out and paid, then the answer should be 8 not 10.

WITH most_ordered_items AS (
    SELECT 
        p.id AS product_id,
        p.name AS product_name,
        SUM(li.quantity) AS num_times_in_successful_orders
    FROM 
        alt_school.orders o
        JOIN alt_school.line_items li ON o.order_id = li.order_id
        JOIN alt_school.products p ON li.item_id = p.id
    WHERE 
        o.status = 'success'
    GROUP BY 
        p.id, p.name
)
SELECT 
    product_id,
    product_name,
    num_times_in_successful_orders
FROM 
    most_ordered_items
ORDER BY 
    num_times_in_successful_orders DESC
LIMIT 1;

-- 2. Without considering currency, and without using the line_item table, find the top 5 spenders you are expected to return the customer_id, location, total_spend where:
-- customer_id: uuid string that uniquely identifies a customer
-- location - the customer's location
-- total_spend - the total amount of money spent on orders

WITH customer_order_spend AS (
    SELECT 
        o.customer_id,
        c.location,
        COALESCE(SUM(p.price), 0) AS total_spend
    FROM 
         alt_school.orders o
        JOIN alt_school.customers c ON o.customer_id = c.customer_id
        JOIN alt_school.products p ON o.order_id = p.id
    WHERE 
        o.status = 'success'
    GROUP BY 
        o.customer_id, c.location
)
SELECT 
    customer_id,
    location,
    total_spend
FROM 
    customer_order_spend
ORDER BY 
    total_spend DESC
LIMIT 5;


-- Part 2b
-- 1. Using the events table, Determine the most common location (country) where successful checkouts occurred. return location and checkout_count where:
-- location: the name of the location
-- checkout_count: the number of checkouts that occured in the location

SELECT 
    c.location AS location,
    COUNT(o.order_id) AS checkout_count
FROM 
     alt_school.orders o
    JOIN  alt_school.customers c ON o.customer_id = c.customer_id
WHERE 
    o.status = 'success'
GROUP BY 
    c.location
ORDER BY 
    checkout_count DESC
LIMIT 1;



-- 2. Using the events table, identify the customers who abandoned their carts and count the number of events (excluding visits) that occurred before the abandonment. return the customer_id and num_events where:
-- customer_id: id uniquely identifying the customers
-- num_events: the number of events excluding visits that occured before abandonment

WITH checkout_customers AS (
    SELECT DISTINCT
        customer_id
    FROM 
        alt_school.orders
    WHERE 
        status = 'success'
)
SELECT 
    e.customer_id,
    COUNT(e.event_id) AS num_events
FROM 
    alt_school.events e
    LEFT JOIN checkout_customers cc ON e.customer_id = cc.customer_id
WHERE 
    cc.customer_id IS NULL 
    AND e.event_data != 'visit' 
GROUP BY 
    e.customer_id;

-- 3. Find the average number of visits per customer, considering only customers who completed a checkout! return average_visits to 2 decimal place
-- average_visits: this number is a metric that suggests the avearge number of times a customer visits the website before they make a successful transaction!

WITH successful_customers AS (
    SELECT DISTINCT
        o.customer_id
    FROM 
        alt_school.orders o
    WHERE 
        o.status = 'success'
),
customer_visits AS (
    SELECT 
        e.customer_id,
        COUNT(e.event_id) AS visit_count
    FROM 
        alt_school.events e
    WHERE 
        e.event_data = 'visit' -- consider only visit events
    GROUP BY 
        e.customer_id
)
SELECT 
    ROUND(AVG(cv.visit_count), 2) AS average_visits
FROM 
    customer_visits cv
WHERE 
    cv.customer_id IN (SELECT customer_id FROM successful_customers);
