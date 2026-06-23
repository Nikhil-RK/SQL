
-- Easy75
-- 1. List all customers with first name, last name, and country.
SELECT first_name, last_name, country FROM customer;

-- 2. Count total number of customers.
SELECT COUNT(*) AS totalCustomers FROM customer;

-- 3. Find customers from Brazil.
SELECT * FROM customer
WHERE country = 'Brazil';

-- 4. Display customers ordered by last name.
SELECT last_name
FROM customer
ORDER BY last_name;

-- 5. Count customers per country.
SELECT COUNT(*), country
FROM customer
GROUP BY country;

-- 6. Display countries having more than 5 customers.
SELECT country, COUNT(*) 
FROM customer
GROUP BY country
HAVING COUNT(*) > 5;

-- 7. Count customers per city.
SELECT city, COUNT(*) 
FROM customer
GROUP BY city
ORDER BY COUNT(*) DESC;

-- 8. Display cities having more than 3 customers.
SELECT city, COUNT(*) 
FROM customer
GROUP BY city
HAVING COUNT(*) > 3;

-- 9. Find customers whose company is NULL.
SELECT first_name, last_name
FROM customer
WHERE company IS NULL;

-- 10. Find customers whose email contains 'gmail'.
-- Just to know about CONCATINATION IN pgadmin4
SELECT first_name || ' ' || last_name AS full_name
FROM customer
WHERE email LIKE '%gmail%';

-- 11. Display customers ordered by first name.
SELECT first_name FROM customer
ORDER BY first_name;

-- 12. Find customers from Germany.
SELECT first_name || ' ' || last_name AS full_name, country
FROM customer
WHERE country = 'Germany';

-- 13. Count customers per support representative.
SELECT support_rep_id, COUNT(*) AS customers
FROM customer
GROUP BY support_rep_id;

-- 14. Display customers with their support representative ID.
SELECT first_name, support_rep_id 
FROM customer;

-- 15. Find customers who do not have a support representative.
SELECT first_name, support_rep_id 
FROM customer
WHERE support_rep_id IS NULL;

-- 16. List invoice id, customer id, and total.
SELECT invoice_id, customer_id, total
FROM invoice;

-- 17. Count total number of invoices.
SELECT COUNT(*) FROM invoice;

-- 18. Find invoices with total greater than 10.
SELECT *
FROM invoice
WHERE total > 10;

-- 19. Display invoices ordered by total (highest first).
SELECT *
FROM invoice
ORDER BY total DESC;

-- 20. Display invoices ordered by total (lowest first).
SELECT *
FROM invoice
ORDER BY total ASC;

-- 21. Find the highest invoice total.
SELECT *
FROM invoice
ORDER BY total DESC
LIMIT 1;

-- 22. Find the lowest invoice total.
SELECT *
FROM invoice
ORDER BY total ASC
LIMIT 1;

-- 23. Count invoices per billing country.
SELECT billing_country, COUNT(*) AS invoiceCount
FROM invoice
GROUP BY billing_country
ORDER BY invoiceCount DESC;

-- 24. Display billing countries having more than 10 invoices.
SELECT billing_country, COUNT(*) AS invoiceCount
FROM invoice
GROUP BY billing_country
HAVING COUNT(*) > 10
ORDER BY invoiceCount DESC;

-- 25. Count invoices per billing city.
SELECT billing_city, COUNT(*) AS invoiceCount
FROM invoice
GROUP BY billing_city
ORDER BY invoiceCount DESC;

-- 26. Display billing cities having more than 5 invoices.
SELECT billing_country, COUNT(*) AS invoiceCount
FROM invoice
GROUP BY billing_country
HAVING COUNT(*) > 10
ORDER BY invoiceCount DESC;

-- 27. Count invoices per customer.
SELECT customer_id, COUNT(*) AS invoiceCount
FROM invoice
GROUP BY customer_id
ORDER BY invoiceCount DESC;

-- 28. Display customers having more than 3 invoices.
SELECT customer_id, COUNT(*) AS invCount
FROM invoice
GROUP BY 

-- 29. Display invoices created after the year 2018.
SELECT * FROM invoice
WHERE EXTRACT (year FROM invoice_date) > '2018'
ORDER BY invoice_date;

-- 30. Display total sales per billing country.
SELECT billing_country, SUM(total) AS countrywiseSales
FROM invoice
GROUP BY billing_country
ORDER BY countrywiseSales DESC;

-- 31. Count total number of invoice line records.
SELECT COUNT(*) FROM public.invoice_line

-- 32. Display invoice lines with quantity greater than 1.
SELECT * FROM public.invoice_line
WHERE quantity > 1;

-- 33. Count invoice lines per invoice.
SELECT invoice_id, COUNT(*) AS invoiceLines
FROM invoice_line
GROUP BY invoice_id
ORDER BY invoiceLines DESC;

-- 34. Display invoices having more than 5 line items.
SELECT invoice_id, COUNT(*) AS invoiceLines
FROM invoice_line
GROUP BY invoice_id
HAVING COUNT(*) > 5
ORDER BY invoiceLines DESC;

SELECT * FROM public.invoice_line

-- 35. Count total quantity sold across all invoices.
SELECT SUM(quantity) AS totalSales
FROM invoice_line;

-- 36. Find quantity per invoice.
SELECT invoice_id, ROUND(SUM(quantity),2) AS Qty
FROM invoice_line
GROUP BY invoice_id
ORDER BY invoice_id;

-- 37. Count invoice lines per track.
SELECT invoice_id, COUNT(*) AS invoiceLines
FROM invoice_line
GROUP BY invoice_id
ORDER BY invoice_id;

-- 38. Find tracks sold more than 10 times.
SELECT track_id, COUNT(*) AS soldMorethan10
FROM invoice_line
GROUP BY track_id
HAVING COUNT(*) > 10
ORDER BY soldMorethan10 DESC;

-- 39. Display total sales value per invoice.
SELECT invoice_id, SUM(unit_price) AS totalSales
FROM invoice_line
GROUP BY invoice_id
ORDER BY totalSales DESC;

-- 40. Display invoice lines ordered by quantity.
SELECT invoice_line_id, quantity
FROM invoice_line
ORDER BY quantity;

-- 41. Count invoice lines grouped by quantity.
SELECT quantity, COUNT(*) as invoiceLines
FROM invoice_line
GROUP BY quantity;

-- 42. Find maximum quantity purchased in a single invoice line.
SELECT invoice_line_id, MAX(quantity) AS maxQty
FROM invoice_line
GROUP BY invoice_line_id
ORDER BY maxQty DESC;

-- 43. Find minimum quantity purchased in a single invoice line.
SELECT invoice_line_id, MIN(quantity) AS minQty
FROM invoice_line
GROUP BY invoice_line_id
ORDER BY maxQty DESC;

-- 44. Count distinct tracks sold.
SELECT DISTINCT COUNT(track_id)
FROM invoice_line;

-- 45. Display total revenue from invoice_line table.
SELECT SUM(unit_price * quantity) AS revenue
FROM invoice_line; 

-- 46. Count total number of tracks.
SELECT COUNT(track_id)
FROM invoice_line;

-- 47. Display tracks with unit price greater than 0.99.
SELECT track_id 
FROM invoice_line
WHERE unit_price > 0.99;

-- 48. Display tracks ordered by milliseconds (longest first).
SELECT track_id, milliseconds
FROM track
ORDER BY milliseconds DESC;

-- 49. Find tracks longer than 300000 milliseconds.
SELECT track_id, milliseconds
FROM track
WHERE milliseconds > '300000';

-- 50. Find tracks with NULL composer.
SELECT track_id, composer
FROM track
WHERE composer IS NULL;

-- 51. Display tracks ordered by unit price (lowest first).
SELECT track_id, unit_price
FROM track
ORDER BY unit_price;

-- 52. Count tracks per album.
SELECT album_id, COUNT(*) AS trackCount
FROM track
GROUP BY album_id
ORDER BY trackCount DESC;

-- 53. Display albums having more than 10 tracks.
SELECT album_id, COUNT(*) AS trackCount
FROM track
GROUP BY album_id
HAVING COUNT(*) > 10
ORDER BY trackCount DESC;

-- Basic Joins for FUN
-- 54. Count tracks per genre using join.
SELECT g.name, COUNT(*) AS tracks
FROM track AS t
LEFT JOIN genre AS g
USING (genre_id) 
GROUP BY g.name
ORDER BY tracks DESC;

-- 55. Display genres having more than 20 tracks.
SELECT g.name, COUNT(*) AS moreThan20
FROM track AS t
LEFT JOIN genre AS g
USING (genre_id) 
GROUP BY g.name
HAVING COUNT(*) >20
ORDER BY moreThan20 DESC;

-- 56. Count tracks per media type.
SELECT m.name, COUNT(*) AS trackCount
FROM track AS t
LEFT JOIN media_type AS m
USING (media_type_id)
GROUP BY m.name
ORDER BY trackCount DESC;

-- 57. Display media types having more than 10 tracks.
SELECT m.name, COUNT(*) AS trackCount
FROM track AS t
LEFT JOIN media_type AS m
USING (media_type_id)
GROUP BY m.name
HAVING COUNT(*) > 10
ORDER BY trackCount DESC;

-- 58. Find tracks with bytes greater than 5,000,000.
SELECT track_id, bytes
FROM track
WHERE bytes > '5000000';

-- 59. Count tracks grouped by unit price.
SELECT unit_price, COUNT(*) AS trackCount
FROM track
GROUP BY unit_price
ORDER BY trackCount DESC;

-- 60. Display unit prices having more than 20 tracks.
SELECT unit_price, COUNT(*) AS trackCount
FROM track
GROUP BY unit_price
HAVING COUNT(*) > 20
ORDER BY trackCount DESC;

-- 61. List all artist names.
SELECT name FROM atrist;

-- 62. Count total number of artists.
SELECT COUNT(*) AS totalNoofArtist
FROM artist;

-- 63. Display artists ordered alphabetically.
SELECT name FROM atrist ORDER BY name;

-- 64. Count albums per artist.
SELECT ar.name, COUNT(*) AS albumsPERartist
FROM album AS a
LEFT JOIN artist AS ar
USING (artist_id)
GROUP BY ar.name
ORDER BY albumsPERartist DESC;


-- 65. Display artists having more than 2 albums.
SELECT ar.name, COUNT(*) AS albumsPERartist
FROM album AS a
LEFT JOIN artist AS ar
USING (artist_id)
GROUP BY ar.name
HAVING COUNT(*) > 2
ORDER BY albumsPERartist DESC;

-- 66. List all album titles.
SELECT DISTINCT title FROM album;

-- 67. Display albums ordered by title.
SELECT DISTINCT title FROM album
ORDER BY title;

-- 68. Find albums whose title starts with 'A'.
SELECT title 
FROM album
WHERE title LIKE 'A%';

-- 69. Display album titles in reverse alphabetical order.
SELECT DISTINCT title FROM album
ORDER BY title DESC;

-- 70. Count total number of albums.
SELECT COUNT(*) FROM album;

-- 71. List employee first name and last name.
SELECT first_name, last_name
FROM employees;

-- 72. Count total number of employees.
SELECT DISTINCT COUNT(*) FROM employees; 

-- 73. Display employees ordered by hire date.
SELECT * FROM employees
ORDER BY hire_date;

-- 74. Count employees per job title.
SELECT title, COUNT(*) AS employeeCount
FROM employees
GROUP by title
ORDER BY employeeCount DESC;

-- 75. Count total number of playlist-track relationships.
SELECT COUNT(*) FROM playlist_track;



-- -- -- 
/*BONUS 5*/
-- -- --
-- Q1: Who is the senior most employee based on job title? 
-- Understand the data
SELECT * FROM employees;

-- Querying out for the = "senior most employee" 
SELECT title, first_name, last_name, levels
FROM employees
ORDER BY levels DESC
LIMIT 1;
-----    -----    -----    -----    -----



-- Q2: Which countries have the most Invoices? 
-- Understand the data
SELECT * FROM Invoice;

-- Querying out for the = "countries with most Invoices" 
SELECT COUNT(*) AS InvoiceCount, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY InvoiceCount DESC
LIMIT 1;
-----    -----    -----    -----    -----



-- Q3: What are top 3 values of total invoice?
-- Understand the data
SELECT * FROM Invoice;

-- Querying out for the = "top 3 values of total invoice" 
SELECT invoice_id, customer_id, total
FROM invoice
ORDER BY total DESC
LIMIT 3;
-----    -----    -----    -----    -----


-- Q4: Which city has the best customers?
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Understand the data
SELECT * FROM Invoice;

-- Querying out for the = "highest sum of invoice totals" 
SELECT SUM(total) AS higestTotal, billing_city
FROM invoice
GROUP BY billing_city						-- Boxing the Cities
ORDER BY higestTotal DESC					-- Summed Total are getting arranged into each box
LIMIT 1;									-- Top 1
-----    -----    -----    -----    -----



-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
SELECT * FROM Invoice;

-- Querying out for the = "spent the most money" 
SELECT customer_id, SUM(total) AS totalSpend
FROM invoice
GROUP BY customer_id
ORDER BY SUM(total) DESC
LIMIT 1
-----    -----    -----    -----    -----






