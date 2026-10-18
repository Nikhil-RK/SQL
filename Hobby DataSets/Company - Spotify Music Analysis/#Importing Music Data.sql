
--I. 'Look-up Tables' --
--- 1. genre: Creating table
CREATE TABLE genre(
	genre_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);

--- genre: Copying the data
COPY genre
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\genre.csv'
CSV HEADER;

--- genre: Data Check
SELECT * 
FROM genre;

--In Case: DROP TABLE genre;
------    -----    -----    -----    -----


--- 2. media_type: Creating table
CREATE TABLE media_type(
	media_type_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);

--- media_type: Copying the data
COPY media_type 
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\media_type.csv'
CSV HEADER;

--- media_type: Data Check
SELECT * 
FROM media_type;

--In Case: DROP TABLE media_type;
------    -----    -----    -----    -----









--II. 'Master Tables' --
--- 1. artist: Creating table
CREATE TABLE artist(
	artist_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);

--- media_type: Copying the data
COPY artist 
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\artist.csv'
CSV HEADER;

--- media_type: Data Check
SELECT * FROM artist;

--In Case: DROP TABLE artist;
------    -----    -----    -----    -----



--- 2. album: Creating table
CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    last_name     VARCHAR(50) NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    title         VARCHAR(100),
    reports_to    INTEGER,
    levels        VARCHAR(5),
    birthdate     DATE,
    hire_date     DATE,
    address       VARCHAR(255),
    city          VARCHAR(50),
    state         VARCHAR(50),
    country       VARCHAR(50),
    postal_code   VARCHAR(15),
    phone         VARCHAR(25),
    fax           VARCHAR(25),
    email         VARCHAR(100) UNIQUE,

	CONSTRAINT fk_employee_manager FOREIGN KEY (reports_to) REFERENCES employees(employee_id)
);

--- media_type: Copying the data
COPY employees
FROM 'C:/Users/Nikhil RK/Desktop/SQL/Music Analysis/DataSets/employee.csv'
HEADER CSV;


--- media_type: Data Check
SELECT COUNT(*) 
FROM employees;

--In Case: DROP TABLE employees;
------    -----    -----    -----    -----











--III. 'Child Tables' --
--- 1. album: Creating table
CREATE TABLE album(
	album_id SERIAL PRIMARY KEY,
	title VARCHAR(100) NOT NULL,
	artist_id INTEGER NOT NULL,
	
	CONSTRAINT fk_album_artist FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

--- media_type: Copying the data
COPY album 
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\album.csv'
DELIMITER ',' CSV HEADER;

--- media_type: Data Check
SELECT COUNT(*) 
FROM album;

--In Case: DROP TABLE album;
------    -----    -----    -----    -----




--- 2. track: Creating table
CREATE TABLE track(
	track_id SERIAL PRIMARY KEY,
	name VARCHAR(500) NOT NULL,
	album_id INTEGER NOT NULL,
	media_type_id INTEGER NOT NULL,
	genre_id INTEGER NOT NULL,
	composer VARCHAR(250),
	milliseconds INTEGER NOT NULL,
	bytes INTEGER NOT NULL,
	unit_price NUMERIC(4,2) NOT NULL,

	CONSTRAINT fk_track_album FOREIGN KEY (album_id) REFERENCES album(album_id),
	CONSTRAINT fk_track_media FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
	CONSTRAINT fk_track_genre FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

--- media_type: Copying the data
COPY track 
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\track.csv'
CSV HEADER;

--- media_type: Data Check
SELECT COUNT(*) 
FROM track;

--In Case: DROP TABLE track;
------    -----    -----    -----    -----























--IV. 'Customer Tables' --
--- 1. customer : Creating table
CREATE TABLE customer (
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(250) NOT NULL,
	last_name VARCHAR(250) NOT NULL,
	company VARCHAR(150),
	address VARCHAR(550),
	city VARCHAR(50),
	state VARCHAR(50),
	country VARCHAR(100) NOT NULL,
	postal_code VARCHAR(100),
	phone VARCHAR(100),
	fax VARCHAR(100),
	email VARCHAR(100),
	support_rep_id INTEGER NOT NULL,

	
	CONSTRAINT fk_customer_employee FOREIGN KEY (support_rep_id) REFERENCES employees(employee_id)
);

--- media_type: Copying the data
COPY customer  
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\customer.csv'
CSV HEADER;

--- media_type: Data Check
SELECT COUNT(*) 
FROM customer ;

--In Case: DROP TABLE customer ;
------    -----    -----    -----    -----

























--V. 'Transaction Tables' --
--- 1. invoice : Creating table
CREATE TABLE invoice (
	invoice_id SERIAL PRIMARY KEY,
	customer_id INTEGER NOT NULL,
	invoice_date DATE,
	billing_address VARCHAR(500) NOT NULL,
	billing_city VARCHAR(50) NOT NULL,
	billing_state VARCHAR(50) NOT NULL,
	billing_country VARCHAR(50) NOT NULL,
	billing_postal_code VARCHAR(50) NOT NULL,
	total NUMERIC(8,5) NOT NULL,

	CONSTRAINT fk_invoice_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

--- media_type: Copying the data
COPY invoice  
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\invoice.csv'
CSV HEADER ENCODING 'LATIN1';

--- media_type: Data Check
SELECT COUNT(*) 
FROM invoice ;

--In Case: DROP TABLE invoice ;
------    -----    -----    -----    -----




--- 2. invoice_line : Creating table
CREATE TABLE invoice_line (
	invoice_line_id SERIAL PRIMARY KEY,
	invoice_id INTEGER NOT NULL,
	track_id INTEGER NOT NULL,
	unit_price NUMERIC(5,2) NOT NULL,
	quantity INTEGER NOT NULL,

	CONSTRAINT fk_invoiceline_invoice FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
	CONSTRAINT fk_invoiceline_ FOREIGN KEY (track_id) REFERENCES track(track_id)
);

--- media_type: Copying the data
COPY invoice_line  
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\invoice_line.csv'
CSV HEADER ;

--- media_type: Data Check
SELECT COUNT(*) 
FROM invoice_line ;

--In Case: DROP TABLE invoice_line ;
------    -----    -----    -----    -----















--VI. 'Bridge Tables' --
--- 1. playlist : Creating table
CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(120) NOT NULL
);


--- media_type: Copying the data
COPY playlist  
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\playlist.csv'
CSV HEADER;

--- media_type: Data Check
SELECT COUNT(*) 
FROM playlist ;

--In Case: DROP TABLE playlist ;
------    -----    -----    -----    -----




--- 2. playlist_track : Creating table
CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INTEGER NOT NULL,

	CONSTRAINT fk_playlisttrack_track FOREIGN KEY (track_id) REFERENCES track(track_id)
);


--- media_type: Copying the data
COPY playlist_track  
FROM 'C:\Users\Nikhil RK\Desktop\SQL\Music Analysis\DataSets\playlist_track.csv'
CSV HEADER;

--- media_type: Data Check
SELECT COUNT(*) 
FROM playlist_track ;

--In Case: DROP TABLE playlist_track ;
------    -----    -----    -----    -----

