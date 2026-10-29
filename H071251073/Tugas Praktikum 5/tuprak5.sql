SET search_path TO classicmodels;

---1
SELECT c.contactFirstName, c.customerName, o.city AS office_city,
    CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name
FROM customers c
INNER JOIN employees e
    ON c.salesRepEmployeeNumber = e.employeeNumber
INNER JOIN offices o
    ON e.officeCode = o.officeCode
WHERE (c.contactFirstName) ILIKE 'A%'
    AND o.city != 'NYC'
ORDER BY c.customerName ASC;

---2
SELECT c.customerName,
    SUM(p.amount) AS total_payment,
    MAX(p.amount) AS max_single_payment
FROM customers c
INNER JOIN payments p
    ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName
HAVING SUM(p.amount) > 50000
ORDER BY total_payment DESC;

---3
SELECT c.customerName,
    COUNT( o.orderNumber) AS total_order,
    ROUND(AVG(od.quantityOrdered), 2) AS avg_quantity_per_order
FROM customers c
INNER JOIN orders o
    ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName
HAVING COUNT(o.orderNumber) > 3
    AND AVG(od.quantityOrdered) > 35
ORDER BY total_order DESC, avg_quantity_per_order DESC;

---4
SELECT p.productLine,
    SUM(od.quantityOrdered) AS total_terjual,
    ROUND(AVG(od.priceEach), 2) AS rata_rata_harga,
    ROUND(AVG(((p.MSRP - od.priceEach) / p.MSRP) * 100), 2) AS avg_discount_percentage
FROM products p
INNER JOIN orderdetails od
    ON p.productCode = od.productCode
GROUP BY p.productLine
HAVING SUM(od.quantityOrdered) > 3000
    AND AVG(od.priceEach) > 80
ORDER BY total_terjual DESC;

---5
SELECT c.customerName, 
    SUM(od.quantityOrdered * od.priceEach) AS total_transaksi,
(SELECT COUNT(*)
   FROM orders o
   WHERE o.customerNumber = c.customerNumber
   AND o.status = 'Shipped') AS total_shipped_orders,
   ROUND(SUM(od.quantityOrdered * od.priceEach)/ COUNT(o.orderNumber), 2) AS avg_transaction_per_order
FROM customers c
INNER JOIN orders o
    ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM o.orderDate)) > 2
ORDER BY total_transaksi DESC
LIMIT 5;

---6
SELECT c.customerName, c.city AS customer_city, ofc.city AS office_city,
    SUM(od.quantityOrdered) AS total_unit_terjual,
    ROUND(SUM(od.quantityOrdered * od.priceEach)/ COUNT(DISTINCT o.orderNumber), 2) AS avg_nilai_per_order
FROM customers c
INNER JOIN employees e
    ON c.salesRepEmployeeNumber = e.employeeNumber
INNER JOIN offices ofc
    ON e.officeCode = ofc.officeCode
INNER JOIN orders o
    ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
WHERE ofc.territory = 'EMEA'
GROUP BY c.customerNumber, c.customerName, c.city, ofc.city
HAVING COUNT(EXTRACT(YEAR FROM o.orderDate)) > 2
   AND SUM(od.quantityOrdered) > 1000
   AND (SUM(od.quantityOrdered * od.priceEach) / COUNT(o.orderNumber)) > 10000
ORDER BY avg_nilai_per_order DESC;

