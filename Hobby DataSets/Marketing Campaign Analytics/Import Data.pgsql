-- ============================================================
-- DATABASE: MarketData
-- PURPOSE : Create and load marketing campaign and event data
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Create the database
-- ------------------------------------------------------------

CREATE DATABASE MarketData;


-- ============================================================
-- CAMPAIGNS TABLE (DIMENSION TABLE)
-- Stores details about each marketing campaign.
-- One campaign can have multiple associated event records.
-- ============================================================

CREATE TABLE public.campaigns (

    -- Unique identifier for each campaign
    campaign_id INT PRIMARY KEY,

    -- Name of the marketing campaign
    campaign_name VARCHAR(50),

    -- Marketing channel (e.g., Email, Social Media, Search)
    channel VARCHAR(100),

    -- Type/category of the marketing campaign
    campaign_type VARCHAR(100),

    -- Total budget allocated to the campaign
    campaign_budget DECIMAL(10, 2)
);


-- ------------------------------------------------------------
-- Load campaign data from CSV file
-- CSV HEADER skips the first row containing column names
-- ------------------------------------------------------------

COPY public.campaigns
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/4. Market Analytics/campaigns.csv'
DELIMITER ','
CSV HEADER;


-- ------------------------------------------------------------
-- Verify the campaign data
-- ------------------------------------------------------------

SELECT *
FROM public.campaigns;


-- ============================================================
-- EVENTS TABLE (FACT TABLE)
-- Stores daily/customer-level marketing performance data.
-- Each record is linked to a campaign using campaign_id.
-- ============================================================


-- Remove the table if it already exists
-- This allows the script to be run again without table conflicts
DROP TABLE IF EXISTS public.events;


CREATE TABLE public.events (

    -- Unique identifier for each event record
    event_id INT PRIMARY KEY,

    -- Date when the marketing activity/event occurred
    event_date DATE,

    -- Unique identifier for the customer
    customer_id VARCHAR(8),

    -- Foreign key linking the event to the campaigns table
    campaign_id INT REFERENCES public.campaigns(campaign_id),

    -- Number of times the campaign/ad was displayed
    impressions INT,

    -- Number of customer clicks
    clicks INT,

    -- Number of successful conversions/purchases
    conversions INT,

    -- Revenue generated from conversions
    revenue DECIMAL(10, 2),

    -- Marketing cost/spend associated with the event
    spend DECIMAL(10, 2)
);


-- ------------------------------------------------------------
-- Load marketing event data from CSV file
-- ------------------------------------------------------------

COPY public.events
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/4. Market Analytics/Events.csv'
DELIMITER ','
CSV HEADER;


-- ------------------------------------------------------------
-- Verify the event data
-- ------------------------------------------------------------

SELECT *
FROM public.events;