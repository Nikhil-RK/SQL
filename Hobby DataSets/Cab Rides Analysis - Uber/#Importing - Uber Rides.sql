/* =========================================================
   DRIVERS TABLE
   Stores master data about drivers registered on platform
   ========================================================= */

-- Drop table first (if re-running script)
-- CASCADE removes dependent foreign keys automatically
DROP TABLE IF EXISTS drivers CASCADE;

-- Create drivers master table
CREATE TABLE drivers (
    driver_id VARCHAR(5) PRIMARY KEY,      -- Unique driver identifier
    signup_date DATE NOT NULL,             -- Driver registration date
    city_id VARCHAR(5) NOT NULL,           -- City where driver operates
    vehicle_type VARCHAR(20) NOT NULL,     -- Car/Bike/Auto etc.
    rating DECIMAL(3,1) NOT NULL,          -- Driver rating (e.g. 4.8)
    is_active BOOLEAN NOT NULL             -- Whether driver is active
);

-- Load CSV data into drivers table
-- COPY reads file from server filesystem
COPY drivers
FROM 'C:\Users\Nikhil RK\Desktop\Data Analysis\PRAC DBs\Uber\drivers.csv'
DELIMITER ','
CSV HEADER;



/* =========================================================
   RIDERS TABLE
   Stores customer/rider master information
   ========================================================= */

DROP TABLE IF EXISTS riders CASCADE;

CREATE TABLE riders (
    rider_id VARCHAR(5) PRIMARY KEY,       -- Unique rider ID
    signup_date DATE NOT NULL,             -- Rider registration date
    city_id VARCHAR(5) NOT NULL,           -- Rider's primary city
    acquisition_channel VARCHAR(10) NOT NULL, -- Ads / Referral / Organic
    device_type VARCHAR(15) NOT NULL       -- Android / iOS / Web
);

COPY riders
FROM 'C:\Users\Nikhil RK\Desktop\Data Analysis\PRAC DBs\Uber\riders.csv'
DELIMITER ','
CSV HEADER;



/* =========================================================
   RIDE REQUESTS TABLE
   Stores ride request events before a trip happens
   Linked to riders + drivers via foreign keys
   ========================================================= */

DROP TABLE IF EXISTS ride_requests CASCADE;

CREATE TABLE ride_requests (
    request_id VARCHAR(10) PRIMARY KEY,       -- Unique request ID
    rider_id VARCHAR(5) REFERENCES riders(rider_id), -- FK → riders
    request_time TIMESTAMP NOT NULL,          -- When ride was requested
    city_id VARCHAR(10) NOT NULL,			  -- City ID
    estimated_eta_minutes INT NOT NULL,       -- Estimated pickup time
    surge_multiplier DECIMAL(3,1) NOT NULL,   -- Surge pricing factor
    assigned_driver_id VARCHAR(5) REFERENCES drivers(driver_id), -- FK
    request_status VARCHAR(20) NOT NULL       -- Completed / Cancelled / No Driver
);

COPY ride_requests
FROM 'C:\Users\Nikhil RK\Desktop\Data Analysis\PRAC DBs\Uber\ride_requests.csv'
DELIMITER ','
CSV HEADER;



/* =========================================================
   TRIPS TABLE
   Stores completed trips after request is fulfilled
   Linked to requests + riders + drivers
   ========================================================= */

DROP TABLE IF EXISTS trips CASCADE;


CREATE TABLE trips (
    trip_id VARCHAR(10) PRIMARY KEY,      -- Unique trip ID
    request_id VARCHAR(10) REFERENCES ride_requests(request_id), -- FK
    rider_id VARCHAR(10) REFERENCES riders(rider_id),            -- FK
    driver_id VARCHAR(10) REFERENCES drivers(driver_id),         -- FK
    pickup_time TIMESTAMP NOT NULL,       -- Trip start time
    dropoff_time TIMESTAMP NOT NULL,      -- Trip end time
    trip_distance_km DECIMAL(5,2) NOT NULL, -- Distance traveled
    trip_duration_minutes INT NOT NULL,   -- Duration in minutes
    final_fare DECIMAL(8,2) NOT NULL,     -- Final charged amount
    trip_status VARCHAR(20) NOT NULL      -- Completed / Cancelled
);

COPY trips
FROM 'C:\Users\Nikhil RK\Desktop\Data Analysis\PRAC DBs\Uber\trips.csv'
DELIMITER ','
CSV HEADER;
