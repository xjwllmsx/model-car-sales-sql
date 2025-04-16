---
Date Created: 2025-02-25  13:35
Last Modified: 2025-03-20  12:38
---

# Customer and Product Insights for Model Car Sales

---

## Project Goal

The goal of this project is to analyze data from a sales records database for scale model cars and extract information for decision-making.

### Questions to answer

- Question 1: Which products require increased or decreased order quantities?
- Question 2: How can marketing and communication strategies be tailored to customer behaviors?
- Question 3: What is an appropriate budget for acquiring new customers?

## Project Files

- [Scale Model Cars Database](./project-files/stores.db)
- [SQL Queries](./project-files/project.sql)

### Database Schema

![[./project-files/images/db-schema.png]]

 The database contains eight tables:

- `Customers`: customer data
- `Employees`: all employee information
- `Offices`: sales office information
- `Orders`: customers' sales orders
- `OrderDetails`: sales order line for each sales order
- `Payments`: customers' payment records
- `Products`: a list of scale model cars
- `ProductLines`: a list of product line categories

## Questions

### Question 0

#### Prompt

Write a query that displays each table's name as a string, the number of attributes per table as an integer, and the number of rows in each table.

#### Solution

The following query dynamically adds the desired information from each table into each row (except the table's name)

```sql
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
```

On line 1, I am selecting the table name (which is manually entered for each table), the number of attributes 

Results in : 

| table_name   | number_of_attributes | number_of_rows |
| ------------ | -------------------- | -------------- |
| Customers    | 13                   | 122            |
| Products     | 9                    | 110            |
| ProductLines | 4                    | 7              |
| Orders       | 7                    | 326            |
| OrderDetails | 5                    | 2996           |
| Payments     | 4                    | 273            |
| Employees    | 8                    | 23             |
| Offices      | 9                    | 7              |

### Question 1: Which products require increased or decreased order quantities?

To answer this question, the restocking priority for each product needs to be determined. Determining the restocking priority requires knowing if a product has low stock and its performance.

Low stock represents the quotient of the total quantity of each product ordered divided by the quantity of that product currently in stock.

Product performance represents the total sales for each product.

Calculating the low stock and product performance necessitates the following computations:

$low stock = \frac{SUM(quantityOrdered)}{quantityInStock}$ and $product performance = SUM(quantityOrdered \times priceEach)$

#### Solution

##### Step 1: Write a query to compute the low stock for each product using a correlated subquery

```sql
SELECT p.productCode,
       p.productName,
	   ROUND(SUM(o.quantityOrdered) * 1.0 / p.quantityInStock, 2) AS low_stock
  FROM products p
  JOIN orderdetails o
    ON p.productCode = o.productCode
 GROUP BY p.productCode, p.productName
 ORDER BY low_stock DESC
 LIMIT 10;
```

##### Step 2: Write a query to compute the product performance for each product

```sql
SELECT o.productCode,
	   p.productName,
	   SUM(o.quantityOrdered * o.priceEach) AS product_performance
  FROM orderdetails AS o
  JOIN products AS p
    ON p.productCode = o.productCode
 GROUP BY o.productCode
 ORDER BY product_performance DESC
 LIMIT 10;
```

##### Step 3: Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using the `IN` operator

```sql
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
```

| productCode | productName              | productLine  | low_stock |
| ----------- | ------------------------ | ------------ | --------- |
| S24_2000    | 1960 BSA Gold Star DBD34 | Motorcycles  | 67.67     |
| S12_1099    | 1968 Ford Mustang        | Classic Cars | 13.72     |
| S32_4289    | 1928 Ford Phaeton Deluxe | Vintage Cars | 7.15      |
| S32_1374    | 1997 BMW F650 ST         | Motorcycles  | 5.7       |
| S72_3212    | Pont Yacht               | Ships        | 2.31      |
| S700_3167   | F/A 18 Hornet 1/72       | Planes       | 1.9       |
| S50_4713    | 2002 Yamaha YZR M1       | Motorcycles  | 1.65      |
| S18_2795    | 1928 Mercedes-Benz SSK   | Vintage Cars | 1.61      |
| S18_2248    | 1911 Ford Town Car       | Vintage Cars | 1.54      |
| S700_1938   | The Mayflower            | Ships        | 1.22      |

### Question 2: How can marketing and communication strategies be tailored to customer behaviors?

The initial phase of this project explored products. The subsequent phase will examine customer information by addressing the second question: how can marketing and communication strategies be matched to customer behaviors? This involves customer categorization, specifically identifying VIP (very important person) customers and those exhibiting lower engagement.

- VIP customers generate the most profit for the store.

- Less-engaged customers generate less profit.

For example, events could be organized to foster loyalty among VIPs, and a campaign could be launched to engage less active customers.

Before proceeding, the profit generated by each customer will be computed.

#### Solution

##### Step 1: Write a query to join the `products`, `orders`, and `orderdetails` tables to have `customers` and `products` information in the same place

```sql
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
```

##### Step 2: Write a query to find the top five VIP customers

```sql
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
```

| contactLastName | contactFirstName | city       | country   | profit    |
| --------------- | ---------------- | ---------- | --------- | --------- |
| Freyre          | Diego            | Madrid     | Spain     | 326519.66 |
| Nelson          | Susan            | San Rafael | USA       | 236769.39 |
| Young           | Jeff             | NYC        | USA       | 72370.09  |
| Ferguson        | Peter            | Melbourne  | Australia | 70311.07  |
| Labrune         | Janine           | Nantes     | France    | 60875.3   |

##### Step 3: Write a query to find the top five least-engaged customers

```sql
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
```

| contactLastName | contactFirstName | city       | country | profit   |
| --------------- | ---------------- | ---------- | ------- | -------- |
| Young           | Mary             | Glendale   | USA     | 2610.87  |
| Taylor          | Leslie           | Brickhaven | USA     | 6586.02  |
| Ricotti         | Franco           | Milan      | Italy   | 9532.93  |
| Schmitt         | Carine           | Nantes     | France  | 10063.8  |
| Smith           | Thomas           | London     | UK      | 10868.04 |

### Question 3: What is an appropriate budget for acquiring new customers?

Before addressing this question, the number of new customers acquired each month should be determined. This allows for an assessment of whether investing in new customer acquisition is worthwhile. The following query facilitates the retrieval of these figures:

```sql
WITH 

payment_with_year_month_table AS (
SELECT *, 
       CAST(SUBSTR(paymentDate, 1,4) AS INTEGER)*100 + CAST(SUBSTR(paymentDate, 6,7) AS INTEGER) AS year_month
  FROM payments p
),

customers_by_month_table AS (
SELECT p1.year_month, COUNT(*) AS number_of_customers, SUM(p1.amount) AS total
  FROM payment_with_year_month_table p1
 GROUP BY p1.year_month
),

new_customers_by_month_table AS (
SELECT p1.year_month, 
       COUNT(DISTINCT customerNumber) AS number_of_new_customers,
       SUM(p1.amount) AS new_customer_total,
       (SELECT number_of_customers
          FROM customers_by_month_table c
        WHERE c.year_month = p1.year_month) AS number_of_customers,
       (SELECT total
          FROM customers_by_month_table c
         WHERE c.year_month = p1.year_month) AS total
  FROM payment_with_year_month_table p1
 WHERE p1.customerNumber NOT IN (SELECT customerNumber
                                   FROM payment_with_year_month_table p2
                                  WHERE p2.year_month < p1.year_month)
 GROUP BY p1.year_month
)

SELECT year_month, 
       ROUND(number_of_new_customers*100/number_of_customers,1) AS number_of_new_customers_props,
       ROUND(new_customer_total*100/total,1) AS new_customers_total_props
  FROM new_customers_by_month_table;
```

Yields the following table:

| year_month | number_of_new_customers_props | new_customers_total_props |
| ---------- | ----------------------------- | ------------------------- |
| 200301     | 100.0                         | 100.0                     |
| 200302     | 100.0                         | 100.0                     |
| 200303     | 100.0                         | 100.0                     |
| 200304     | 100.0                         | 100.0                     |
| 200305     | 100.0                         | 100.0                     |
| 200306     | 100.0                         | 100.0                     |
| 200307     | 75.0                          | 68.3                      |
| 200308     | 66.0                          | 54.2                      |
| 200309     | 80.0                          | 95.9                      |
| 200310     | 69.0                          | 69.3                      |
| 200311     | 57.0                          | 53.9                      |
| 200312     | 60.0                          | 54.9                      |
| 200401     | 33.0                          | 41.1                      |
| 200402     | 33.0                          | 26.5                      |
| 200403     | 54.0                          | 55.0                      |
| 200404     | 40.0                          | 40.3                      |
| 200405     | **12.0**                      | **17.3**                  |
| 200406     | 33.0                          | 43.9                      |
| 200407     | **10.0**                      | **6.5**                   |
| 200408     | **18.0**                      | **26.2**                  |
| 200409     | 35.7                          | 56.4                      |

The number of clients has been decreasing since 2003, with the lowest values observed in 2004. Notably, data from 2005, though present in the database, is absent from the preceding table, indicating no new customers since September 2004. This suggests that investing in customer acquisition is advisable.

To determine a suitable acquisition budget, the Customer Lifetime Value (LTV) can be computed. LTV represents the average revenue generated by a customer. This value can then inform the allocation of marketing expenditure.

#### Solution

##### Step 1: Write a query to compute the average of customer profits using the CTE on the previous screen

```sql
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
```

Yields:

| ltv      |
| -------- |
| 39039.59 |

LTV indicates the average profit a customer generates throughout their engagement with the store. This metric allows for the prediction of future profit. Therefore, acquiring ten new customers next month is projected to yield 390,395 dollars, and this prediction can inform decisions regarding the budget for new customer acquisition.

## Conclusion
In this project, analysis of the model car sales database provided insights into product restocking needs, customer behavior for tailored marketing, and a potential budget for acquiring new customers. To determine product restocking priorities, the project calculated a "low stock" metric and product performance, identifying products with high order demand relative to stock and top-selling items. Combining these metrics highlighted specific products, such as the "1960 BSA Gold Star DBD34," as requiring close attention for restocking.

To understand customer behavior, the project categorized customers based on their generated profit, identifying VIP and less-engaged segments. This analysis suggests targeted strategies, such as loyalty events for high-profit customers and engagement campaigns for those with lower activity. Finally, by examining new customer acquisition trends and calculating the Customer Lifetime Value (LTV), the project established a basis for determining a suitable budget for attracting new customers, projecting potential future revenue based on average customer profitability.
