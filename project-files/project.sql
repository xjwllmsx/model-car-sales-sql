/*
Tables in the database:
    Customers: all customer data
        Connects to:
            - employees: customers.salesRepEmployeeNumber = employees.employeeNumber
            - orders: customers.customerNumber = orders.customerNumber
            - payments: customers.customerNumber = payments.customerNumber
    Employees: all employee information
        Connects to:
            - offices: employees.officeCode = offices.officeCode
            - customers: employees.employeeNumber = customers.customerRepEmployeeNumber
            - employees: employees.employeeNumber = employee.reportsTo
    Offices: sales office information
        Connects to:
            - employees: offices.officeCode = employees.officeCode
    Orders: customers' sales orders
        Connects to:
            - orderdetails: orders.orderNumber = orderdetails.orderNumber
            - customers: orders.customerNumber = customers.customerNumber
    OrderDetails: sales order line for each sales order
        Connects to:
            - products: orderdetails.productCode = products.productCode
            - orders: orderdetails.orderNumber = orderdetails.orderNumber
    Payments: customers' payment records
        Connects to:
            - customers: payments.customerNumber = customers.customerNumber
    Products: a list of scale model cars
        Connects to:
            - productlines: products.productLine = productlines.productLine
            - orderdetails: products.productCode = orderdetails.productCode
    ProductLines: a list of product line categories
        Connects to:
            - products: productlines.productLine = products.productLine
*/

-- Question 0
-- Selects all table names from the database
SELECT 'Customers' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('customers')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM customers
  
 UNION ALL

SELECT 'Products' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('products')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM products
 
 UNION ALL

SELECT 'ProductLines' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('productlines')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM productlines
  
 UNION ALL
 
SELECT 'Orders' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('orders')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM orders
 
 UNION ALL
 
SELECT 'OrderDetails' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('orderdetails')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM orderdetails
 
 UNION ALL
 
SELECT 'Payments' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('payments')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM payments
 
 UNION ALL
 
SELECT 'Employees' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('employees')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM employees
 
 UNION ALL
 
SELECT 'Offices' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info('offices')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
  FROM offices;


-- Question 1
-- Write a query to compute the low stock for each product using a correlated subquery
SELECT p.productCode, 
       p.productName, 
       ROUND(SUM(o.quantityOrdered) * 1.0 / p.quantityInStock, 2) AS low_stock
  FROM products p
  JOIN orderdetails o 
    ON p.productCode = o.productCode 
 GROUP BY p.productCode, p.productName
 ORDER BY low_stock DESC
 LIMIT 10;

-- Write a query to compute the product performance for each product
SELECT o.productCode,
	   p.productName,
	   SUM(o.quantityOrdered * o.priceEach) AS product_performance
  FROM orderdetails AS o
  JOIN products AS p
    ON p.productCode = o.productCode
 GROUP BY o.productCode
 ORDER BY product_performance DESC
 LIMIT 10;

-- Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using the IN operator.
WITH
low_stock AS (
	SELECT p.productCode, 
		   p.productName, 
		   ROUND(SUM(o.quantityOrdered) * 1.0 / p.quantityInStock, 2) AS low_stock
	  FROM products p
	  JOIN orderdetails o 
		ON p.productCode = o.productCode 
	 GROUP BY p.productCode, p.productName
),
product_performance AS (
	SELECT o.productCode,
		   p.productName,
		   SUM(o.quantityOrdered * o.priceEach) AS product_performance
	  FROM orderdetails AS o
	  JOIN products AS p
		ON p.productCode = o.productCode
	 GROUP BY o.productCode
),
priority_products AS (
	SELECT productCode
	  FROM low_stock
	 WHERE low_stock < 0.5
	 UNION ALL
	SELECT productCode
	  FROM product_performance
)

SELECT p.productCode,
	   p.productName,
	   p.productLine,
	   l.low_stock
  FROM low_stock AS l
  JOIN products AS p
    ON p.productCode = l.productCode
 WHERE l.productCode IN (SELECT productCode
						   FROM priority_products)
 ORDER BY l.low_stock DESC, p.productName
 LIMIT 10;

-- Question 2
-- Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place.
SELECT o.customerNumber,
	   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orderdetails AS od
  JOIN orders AS o
    ON od.orderNumber = o.orderNumber
  JOIN products AS p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber
 ORDER BY profit DESC
 LIMIT 10;

-- Write a query to find the top five VIP customers
WITH 
vip_customers AS (
	SELECT o.customerNumber,
		   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
	  FROM orderdetails AS od
	  JOIN orders AS o
		ON od.orderNumber = o.orderNumber
	  JOIN products AS p
		ON od.productCode = p.productCode
	 GROUP BY o.customerNumber
)

SELECT c.contactLastName,
	   c.contactFirstName,
	   c.city,
	   c.country,
	   v.profit
  FROM customers AS c
  JOIN vip_customers AS v
    ON c.customerNumber = v.customerNumber
 ORDER BY profit DESC
 LIMIT 5;

-- Write a query to find the top five least-engaged customers
WITH 
vip_customers AS (
	SELECT o.customerNumber,
		   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
	  FROM orderdetails AS od
	  JOIN orders AS o
		ON od.orderNumber = o.orderNumber
	  JOIN products AS p
		ON od.productCode = p.productCode
	 GROUP BY o.customerNumber
)

SELECT c.contactLastName,
	   c.contactFirstName,
	   c.city,
	   c.country,
	   v.profit
  FROM customers AS c
  JOIN vip_customers AS v
    ON c.customerNumber = v.customerNumber
 ORDER BY profit ASC
 LIMIT 5;

-- Question 3
-- Write a query to compute the average of customer profits using the CTE on the previous screen.

WITH 
vip_customers AS (
	SELECT o.customerNumber,
		   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
	  FROM orderdetails AS od
	  JOIN orders AS o
		ON od.orderNumber = o.orderNumber
	  JOIN products AS p
		ON od.productCode = p.productCode
	 GROUP BY o.customerNumber
)

SELECT ROUND(AVG(profit), 2) AS ltv
  FROM vip_customers;