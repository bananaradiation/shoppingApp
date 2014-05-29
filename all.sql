--create indices
CREATE INDEX sales_user_idx ON sales (uid);
CREATE INDEX sales_product_idx ON sales (pid);

--customer only
CREATE TEMPORARY TABLE users_temp AS (
SELECT *
FROM users
LIMIT 20);

SELECT     users_temp.name, SUM(quantity * price) AS AMOUNT
FROM     users_temp
LEFT OUTER JOIN sales
ON     sales.uid = users_temp.id
GROUP BY users_temp.id, users_temp.name
ORDER BY name;

--products only
CREATE TEMPORARY TABLE products_temp AS (
SELECT *
FROM products
LIMIT 10);

SELECT     products_temp.name, SUM(sales.quantity * sales.price) AS AMOUNT
FROM     products_temp
LEFT OUTER JOIN sales
ON     sales.pid = products_temp.id
GROUP BY products_temp.id, products_temp.name
ORDER BY products_temp.name;

--users x products
SELECT     sales.uid, sales.pid, SUM(quantity * price) AS amount 
FROM     sales
WHERE     
    sales.pid IN (
        SELECT products.id
        FROM products
        LIMIT 500    
    ) 
    AND
    sales.uid IN (
        SELECT users.id
        FROM users
        LIMIT 20    
    )
GROUP BY sales.uid,sales.pid;
