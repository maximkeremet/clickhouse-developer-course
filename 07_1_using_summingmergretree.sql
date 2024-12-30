-- Lab 7.1: Using SummingMergeTree

-- 1. Get stats by town
SELECT 
    town,
    sum(price) AS sum_price,
    formatReadableQuantity(sum_price)
FROM uk_price_paid
GROUP BY town
ORDER BY sum_price DESC;
-- Elapsed: 1.392s Read: 28,634,236 rows (143.37 MB)

-- 2.Creating a target table with SummingMergeTree engine

-- Create MV
CREATE MATERIALIZED VIEW prices_sum_view TO prices_sum_dest AS
(
    SELECT town, sum(price) AS sum_price 
    FROM uk_price_paid 
    GROUP BY town
);

-- Create table
CREATE OR REPLACE TABLE prices_sum_dest (
    town LowCardinality(String),
    sum_price UInt64
)
ENGINE = SummingMergeTree
PRIMARY KEY town;

-- Populate table
INSERT INTO prices_sum_dest
    SELECT town, sum(price) AS sum_price 
    FROM uk_price_paid 
    GROUP BY town

-- 3. Verify
SELECT count() as cnt from prices_sum_dest;
-- 1172

-- 4. Verify that MV works faster
SELECT 
    town,
    sum(price) AS sum_price,
    formatReadableQuantity(sum_price)
FROM uk_price_paid
WHERE town = 'LONDON'
GROUP BY town;
-- Elapsed: 0.068s Read: 28,634,240 rows (39.22 MB)
-- | town   | sum_price     | formatReadableQuantity(sum_price) |
-- | LONDON	| 1072797334445 |         1.07 trillion             |

SELECT
    town,
    sum_price AS sum,
    formatReadableQuantity(sum)
FROM prices_sum_dest
WHERE town = 'LONDON';
-- Elapsed: 0.003s Read: 1,172 rows (7.03 KB)
-- | town   | sum_price     | formatReadableQuantity(sum_price) |
-- | LONDON	| 1072797334445 |         1.07 trillion             |

-- If we insert the date in `uk_price_paid` the data in the 2nd query will not be aggregated.
INSERT INTO uk_price_paid (price, date, town, street)
VALUES
    (4294967295, toDate('2024-01-01'), 'LONDON', 'My Street2');
-- Gives
-- Elapsed: 0.068s Read: 28,634,240 rows (39.22 MB)
-- | town   | sum_price     | formatReadableQuantity(sum_price) |
-- | LONDON	| 4294967295    |         4.29 billion              |
-- | LONDON	| 1072797334445 |         1.07 trillion             |

-- We can either add GROUP BY clause 
SELECT
    town,
    sum(sum_price) AS _sum,
    formatReadableQuantity(_sum)
FROM prices_sum_dest
WHERE town = 'LONDON'
GROUP BY town;

-- Or use OPTIMIZE
OPTIMIZE TABLE prices_sum_dest FINAL;

-- 5. Top 10 towns in terms of total price spent on property query
SELECT town, SUM(sum_price) AS total_price
FROM prices_sum_dest
GROUP BY town
ORDER BY total_price DESC
LIMIT 10;


