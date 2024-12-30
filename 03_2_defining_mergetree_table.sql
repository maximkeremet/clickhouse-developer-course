-- Lab 3.2: Defining a MergeTree Table

-- 1. Observe data
DESCRIBE s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet');

-- 2. Create `crypto_prices` table
CREATE TABLE crypto_prices (
    trade_date Date,
    crypto_name LowCardinality(String), 
    volume Float32,
    price Float32,
    market_cap Float32, 
    change_1_day Float32 
)
ENGINE=MergeTree
PRIMARY KEY (crypto_name, trade_date);

-- 3. Insert data
INSERT INTO crypto_prices
SELECT *
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet');

-- 4. Verify stuff
SELECT formatReadableQuantity(count()) FROM crypto_prices;
-- 2.38 million

-- 5. Find trades of sertain volume
SELECT * FROM crypto_prices WHERE volume >= 1000_000;
-- Elapsed: 0.846s Read: 2,382,643 rows (45.27 MB) -> fullscan, because volume not in PK, so not possibility to skip 

-- 6. Find avg bitcoin price
SELECT formatReadableQuantity(avg(price)) as avg_price FROM crypto_prices WHERE crypto_name = 'Bitcoin';
-- 5.63 thousand
-- Elapsed: 0.005s Read: 24,576 rows (57.34 KB) -> `crypto_name` is in PK, so we were able to skip a lot and read only 3 granules

-- 7. Find avg price of crypto_name LIKE 'B%'
SELECT formatReadableQuantity(avg(price)) as avg_price FROM crypto_prices WHERE crypto_name LIKE 'B%';
-- 72.05
-- Elapsed: 0.007s Read: 5.63 thousand rows (1.19 MB) -> needed include more crypto_name that started with `B`, so 29 granules

SELECT uniqExact(crypto_name) as avg_price FROM crypto_prices WHERE crypto_name LIKE 'B%';
-- 380

-- Needed include 380 currencies that started with `B`, so read 29 granules.