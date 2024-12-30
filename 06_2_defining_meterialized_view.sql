-- Lab 6.2: Materialized Views

-- 1. Stats by property in 2020
SELECT concat(street, addr1, addr2) as property, 
       count() as cnt, 
       avg(price) as avg_price
FROM uk_price_paid
WHERE toYear(date) = '2020'
GROUP BY property;

-- 2. Stats by year

SELECT toYear(date) as _year, 
       count() as cnt, 
       avg(price) as avg_price
FROM uk_price_paid
GROUP BY _year;

describe uk_price_paid
-- 3. Create TABLE
CREATE OR REPLACE TABLE prices_by_year_dest (
    date Date, 
    price UInt32, 
    addr1 LowCardinality(String),
    addr2 LowCardinality(String),
    street LowCardinality(String),
    town LowCardinality(String),
    district LowCardinality(String), 
    country LowCardinality(String)
)
ENGINE = MergeTree
PARTITION BY toYear(date)
PRIMARY KEY (town, date)


-- 4. Create MatView
-- DROP VIEW prices_by_year_view

CREATE MATERIALIZED VIEW prices_by_year_view TO prices_by_year_dest AS 
    SELECT date, price, addr1, addr2, street, town, district, county 
    FROM uk_price_paid

-- 5. Insert data
INSERT INTO prices_by_year_dest
    SELECT date, price, addr1, addr2, street, town, district, county 
    FROM uk_price_paid

-- 6. Verify
SELECT formatReadableQuantity(count()) FROM prices_by_year_dest
-- 28.63 million

-- 7. Check parts of `prices_by_year_dest`
SELECT * FROM system.parts
WHERE table='prices_by_year_dest';

-- 8. Check parts of `uk_price_paid`
SELECT * FROM system.parts
WHERE table='uk_price_paid';

-- 9. Partitining is hell
-- At a minimum, you need at least one part for each year from 1995 to 2023, 
-- but it is possible that some of those years have multiple part folders. 
-- This is a cautionary tale about partitioning! Be careful with it - especially when you only have 28M rows.

-- 10.
-- Running query over uk_price_paid gives:
-- Memory usage: 294.72 MiB Read: 28.63 million rows (322.73 MiB)

SELECT concat(street, addr1, addr2) as property, 
       count() as cnt, 
       avg(price) as avg_price
FROM prices_by_year_dest
WHERE toYear(date) = '2020'
GROUP BY property;

-- Using table with a view gives: Memory usage: 128.47 MiB Read: 886.64 thousand rows (10.15 MiB)

-- 11.

SELECT concat(street, addr1, addr2) as property, 
       count() as cnt, 
       avg(price) as avg_price, 
       quantiles(0.9)(price) as p90_price, 
       max(price) as max_price
FROM prices_by_year_dest
WHERE toYYYYMM(date) = '200506'
GROUP BY property;

-- Using table with a view gives: Elapsed: 0.161s Read: 1,012,145 rows (12.15 MB)

-- 12. Verify that matView works

INSERT INTO uk_price_paid VALUES
    (125000, '2024-03-07', 'B77', '4JT', 'semi-detached', 0, 'freehold', 10,'',	'CRIGDON','WILNECOTE','TAMWORTH','TAMWORTH','STAFFORDSHIRE'),
    (440000000, '2024-07-29', 'WC1B', '4JB', 'other', 0, 'freehold', 'VICTORIA HOUSE', '', 'SOUTHAMPTON ROW', '','LONDON','CAMDEN', 'GREATER LONDON'),
    (2000000, '2024-01-22','BS40', '5QL', 'detached', 0, 'freehold', 'WEBBSBROOK HOUSE','', 'SILVER STREET', 'WRINGTON', 'BRISTOL', 'NORTH SOMERSET', 'NORTH SOMERSET');

-- 13/14. Very that three rows appear in `prices_by_year_dest`
SELECT * FROM system.parts
WHERE table='prices_by_year_dest';

-- a new part with 3 rows in parts table:
-- 2024	2024_0_0_0	00000000-0000-0000-0000-000000000000	Compact	Packed	1	2	3	863	565	362	55