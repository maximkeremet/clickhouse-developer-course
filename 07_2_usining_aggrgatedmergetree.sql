
-- Lab 7.2: Using AggregatingMergeTree

-- 1. Get monthly stats
-- a)
WITH
    toStartOfMonth(date) AS month
SELECT 
    month,
    min(price) AS min_price,
    max(price) AS max_price
FROM uk_price_paid
GROUP BY month 
ORDER BY month DESC;

-- b)
WITH
    toStartOfMonth(date) AS month
SELECT 
    month,
    avg(price)
FROM uk_price_paid
GROUP BY month 
ORDER BY month DESC;

-- c)
WITH
    toStartOfMonth(date) AS month
SELECT 
    month,
    count()
FROM uk_price_paid
GROUP BY month 
ORDER BY month DESC;

-- 2. Creating a MV to support queries above
-- creat MV -> create table -> insert
CREATE MATERIALIZED VIEW uk_prices_aggs_view TO uk_prices_aggs_dest AS
(
    SELECT toStartOfMonth(date) AS month, 
           avg(price) as avg_price,
           min(price) AS min_price,
           max(price) AS max_price,
           count() AS cnt
    FROM uk_price_paid 
    GROUP BY month
);

-- Create table
CREATE OR REPLACE TABLE uk_prices_aggs_dest (
    month Date,
    avg_price UInt32,
    min_price UInt32,
    max_price UInt32,
    cnt UInt32
)
ENGINE = AggregatingMergeTree
PRIMARY KEY month;

-- Insert 
INSERT INTO uk_prices_aggs_dest
    SELECT toStartOfMonth(date) AS month, 
            avg(price) as avg_price,
            min(price) AS min_price,
            max(price) AS max_price,
            count() AS cnt
        FROM uk_price_paid 
        WHERE toStartOfMonth(date) <= '2024-01-01'
        GROUP BY month;

-- 3. Verify
SELECT * FROM uk_prices_aggs_dest;

-- 4. Stats 2023
SELECT month, min_price, max_price 
FROM uk_prices_aggs_dest
WHERE toYear(month) = '2023';
-- Elapsed: 0.003s Read: 346 rows (3.46 KB)

-- 5. Stats last 2 years
SELECT month, avg_price 
FROM uk_prices_aggs_dest
WHERE month >= today() - INTERVAL 2 YEAR;
-- Elapsed: 0.003s Read: 346 rows (2.08 KB)

-- 6. Number of homes sold in 2020
SELECT month, cnt 
FROM uk_prices_aggs_dest
WHERE toYear(month) = '2020';
-- Elapsed: 0.002s Read: 346 rows (2.08 KB)

-- 7. Insert more rows 
INSERT INTO uk_price_paid (date, price, town) VALUES
    ('2024-08-01', 10000, 'Little Whinging'),
    ('2024-08-01', 1, 'Little Whinging');

-- 8. Verify
SELECT * 
FROM uk_prices_aggs_dest
WHERE toYear(month) = '2024';

-- Added an aggregated row in destination table 0.002s
-- |   month   |    avg_price   | min_price |    max_price  | cnt|
-- |2024-01-01 |	2863978196	|  2000000  |	4294967295  |  3 |
-- |2024-08-01 |	5000	    |    1	    | 