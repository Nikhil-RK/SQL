 -- SQL QUERIES 
-- Medium20:
-- 1. Find invoices whose total is greater than the average invoice total
SELECT invoice_id, total FROM invoice
WHERE total > (SELECT AVG(total) FROM invoice);


-- 2. Classify invoices as Small / Medium / Large
SELECT customer_id,
	CASE WHEN total <= 8 THEN 'Small'
		 WHEN total BETWEEN 9 AND 17 THEN 'Medium'
		 ELSE 'Large' END As InvoiceSize
FROM invoice;

-- 3. Tracks longer than average track length
SELECT name, ROUND((milliseconds/3600),3) AS minute
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS avgTrackLength FROM track);

-- 4. Tracks priced above average track price
SELECT name, unit_price
FROM track
WHERE unit_price > (SELECT AVG(unit_price) AS avgTrackPrice FROM track);

-- 5. Label tracks as Short / Medium / Long
SELECT name, milliseconds,
	CASE WHEN milliseconds < 110001 THEN 'Short'
		 WHEN milliseconds BETWEEN 110001 AND 230001 THEN 'Medium'
		 ELSE 'Long' END AS trackLengthDivision
FROM track;

-- 6. Genres with above-average track price
SELECT genre_id
FROM track
GROUP BY genre_id
HAVING AVG(unit_price)  > (SELECT AVG(unit_price) FROM track);

-- 7. Tracks that were never purchased
SELECT track_id
FROM track
WHERE track_id NOT IN (SELECT track_id FROM invoice_line)

-- 8. Invoices with at least one expensive track
SELECT i.invoice_id
FROM invoice AS i
INNER JOIN invoice_line AS il
ON i.invoice_id = il.invoice_id
INNER JOIN track AS t
ON il.track_id = t.track_id
WHERE t.unit_price > 0.99

-- 9. Customers spending above average customer spending
SELECT customer_id
FROM invoice
GROUP BY customer_id
HAVING SUM(total) > (
  SELECT AVG(total_spend)
  FROM (SELECT SUM(total) AS total_spend FROM Invoice GROUP BY customer_id)
)
ORDER BY customer_id;

-- 10. Customers buying more tracks than average
SELECT i.customer_id
FROM invoice AS i
INNER JOIN invoice_line AS il
ON i.invoice_id = il.invoice_id
GROUP BY i.customer_id
HAVING COUNT(*) > (SELECT AVG(countOfTracks) 
				FROM (
						SELECT COUNT(*) AS countOfTracks
						FROM invoice AS i
						INNER JOIN invoice_line AS il
						ON i.invoice_id = il.invoice_id
						GROUP BY i.customer_id
));


-- 11. Invoices with more tracks than average invoice
SELECT i.invoice_id, COUNT(*) AS ggCount
FROM invoice AS i
INNER JOIN invoice_line AS il
ON i.invoice_id = il.invoice_id
GROUP BY i.invoice_id
HAVING COUNT(*) > (
					SELECT AVG(totalItems) AS avgTrackcount
					FROM (
							SELECT COUNT(*) AS totalItems
							FROM invoice_line
							GROUP BY invoice_id
				)) AS t
ORDER BY ggCount DESC;


-- 12. Tracks purchased more than average
SELECT track_id
FROM invoice_line
GROUP BY track_id
HAVING COUNT(track_id) >	(
							SELECT AVG(totaltracks) AS avgTrackPurchase
							FROM (
									SELECT COUNT(*) AS totaltracks
									FROM invoice_line
									GROUP BY track_id
						));



-- 13. Genres with total sales above average genre
SELECT g.name, SUM(il.unit_price*il.quantity) AS totalSales
FROM invoice_line AS il
INNER JOIN track AS t
ON il.track_id = t.track_id
INNER JOIN genre AS g
ON t.genre_id = g.genre_id
GROUP BY g.name
HAVING SUM(il.unit_price * il.quantity) > (	SELECT AVG(price)
											FROM (SELECT SUM(il.unit_price * il.quantity) AS price
											FROM invoice_line AS il
											INNER JOIN track AS t
											ON il.track_id = t.track_id
											GROUP BY genre_id));


-- 14. Albums with revenue above average album
SELECT t.album_id, SUM(il.unit_price * il.quantity) AS Revenue
FROM invoice_line AS il
INNER JOIN track AS t
ON il.track_id = t.track_id
GROUP BY t.album_id
HAVING SUM(il.unit_price * il.quantity) > (SELECT AVG(price)
											FROM (SELECT SUM(il.unit_price * il.quantity) AS price
																						FROM invoice_line AS il
																						INNER JOIN track AS t
																						ON il.track_id = t.track_id
																						GROUP BY album_id))
ORDER BY Revenue DESC;



-- 15. Artists with sales above average artist
SELECT ar.artist_id,ar.name, SUM(il.unit_price * il.quantity) AS totalSale
FROM invoice_line AS il
INNER JOIN track AS t
ON il.track_id = t.track_id
INNER JOIN album AS a
ON t.album_id = a.album_id
INNER JOIN artist AS ar
ON a.artist_id = ar.artist_id
GROUP BY ar.artist_id,ar.name
HAVING SUM(il.unit_price * il.quantity) > (SELECT AVG(price) 
										   FROM (
												SELECT SUM(il2.unit_price * il2.quantity) AS price
												FROM invoice_line AS il2
												INNER JOIN track AS t2
												ON il2.track_id = t2.track_id
												INNER JOIN album AS a2
												ON t2.album_id = a2.album_id
												INNER JOIN artist AS ar2
												ON a2.artist_id = ar2.artist_id
												GROUP BY ar2.artist_id
											))
ORDER BY totalSale DESC;

-- 16. Artists with more tracks than average artist
SELECT a.artist_id
FROM track AS t
INNER JOIN album AS a
ON t.album_id = a.album_id
INNER JOIN artist AS ar
ON a.artist_id = ar.artist_id
GROUP BY a.artist_id
HAVING COUNT(a.artist_id) > (
			SELECT AVG(artistTrackCount)
			FROM (SELECT COUNT(*) AS artistTrackCount 
			FROM track AS t2
			INNER JOIN album AS a2
			ON t2.album_id = a2.album_id
			INNER JOIN artist AS ar2
			ON a2.artist_id = ar2.artist_id
			GROUP BY a2.artist_id
			ORDER BY a2.artist_id))
ORDER BY a.artist_id;


-- 17. Customer spending labels
SELECT i.customer_id, SUM(total),
	CASE WHEN SUM(i.total) < 40 THEN 'Small'
		 WHEN SUM(i.total) BETWEEN 40 AND 90 THEN 'Medium'
		 ELSE 'Large' END AS spendingLabel 
FROM invoice AS i
INNER JOIN customer AS c
ON i.customer_id = c.customer_id
GROUP BY i.customer_id
HAVING SUM(total) > 0
ORDER BY i.customer_id;


-- 18. Popular vs Less Popular genres
SELECT t.genre_id,
	CASE WHEN COUNT(*) > (	SELECT AVG(genreBought) AS avgPerGenre
							FROM (
								SELECT COUNT(*) AS genreBought
								FROM invoice_line AS il
								INNER JOIN track AS t
								ON il.track_id = t.track_id
								GROUP BY genre_id))
		THEN 'Popular' 
		ELSE 'Regular' END AS genreStatus
FROM invoice_line AS il
JOIN track AS t
  ON il.track_id = t.track_id
GROUP BY t.genre_id
ORDER BY t.genre_id;

-- 19. Customers with no purchases
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name
FROM customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM invoice AS i
    WHERE i.customer_id = c.customer_id
);

-- 20. Artists who never sold a track
SELECT 
	ar.artist_id
FROM 
	artist ar
WHERE NOT EXISTS (
    SELECT
		1
    FROM
		album AS a
    INNER JOIN
		track AS t
      ON
	  	a.album_id = t.album_id
    INNER JOIN
		invoice_line AS il
      ON
	  	t.track_id = il.track_id
    WHERE
		a.artist_id = ar.artist_id
);



























































