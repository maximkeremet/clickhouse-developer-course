-- Lab 4.2: Insert the UK Property Dataset


-- 4.1
-- Inserted `hackernews` dataset (https://datasets-documentation.s3.eu-west-3.amazonaws.com/hackernews/clickhouse_hacker_news.csv)

USE training;
SELECT 
   count() AS count,
   by
FROM clickhouse_hacker_news
GROUP BY by
ORDER BY count DESC;


-- 4.2
-- Creating a table and inserting data with S3 function
DESCRIBE s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/uk_property_prices.snappy.parquet');

CREATE TABLE uk_price_paid (
   price UInt32,
   date Date,
   postcode1 String,
   postcode2 String,
   type Enum('terraced' = 1, 'semi-detached' = 2, 'detached' = 3, 'flat' = 4, 'other' = 0),
   is_new UInt8,
   duration Enum('freehold' = 1, 'leasehold' = 2, 'unknown' = 0),
   addr1 LowCardinality(String),
   addr2 LowCardinality(String),
   street LowCardinality(String),
   locality LowCardinality(String),
   town LowCardinality(String),
   district LowCardinality(String),
   county LowCardinality(String)
)
ENGINE=MergeTree
PRIMARY KEY (postcode1, postcode2, date);

INSERT INTO uk_price_paid
SELECT * FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/uk_property_prices.snappy.parquet');

-- DROP TABLE uk_price_paid;
DESCRIBE TABLE uk_price_paid;

SELECT formatReadableQuantity(count()) FROM uk_price_paid;

-- scanning ~7 granules, because using 2 cols from the PK, so the table is designed for this kind of queries
SELECT formatReadableQuantity(avg(price)) FROM uk_price_paid WHERE postcode1='LU1' AND postcode2='5FT';

-- fullscan since `town` not in primary key
SELECT formatReadableQuantity(avg(price)) FROM uk_price_paid WHERE town='York';

