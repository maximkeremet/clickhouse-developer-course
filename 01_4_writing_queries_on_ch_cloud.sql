-- Lab 1.4: Writing Ad-hoc Queries

SHOW TABLES;

CREATE DATABASE training;

-- 1. Get all data from s3 source
SELECT * 
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet') 
LIMIT 10;

SELECT * 
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet') 
LIMIT 1 
FORMAT Vertical;

-- 2/3. Count rows and format readability
SELECT formatReadableQuantity(count()) 
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet');


-- 4. Get average volume of Bitcoin trades
SELECT formatReadableQuantity(avg(volume)) 
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet') 
WHERE crypto_name = 'Bitcoin';
-- [KEY] 10.41 billion


-- 5. Get number of trades for each cryptocurrency 
SELECT crypto_name, count() AS trades_cnt 
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet') 
WHERE crypto_name != ''
GROUP BY crypto_name
ORDER BY crypto_name DESC;
-- [KEY] zzz.finance	75


-- 6. Use trim to clean up
SELECT DISTINCT crypto_name
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet') 
WHERE startsWith(crypto_name, ' ');
-- -- These start from space character
-- Token
-- Maxcoin
-- HBZ coin
-- Governance

SELECT trimLeft(crypto_name) AS crypto_name, count() AS trades_cnt 
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet') 
WHERE crypto_name != ''
GROUP BY crypto_name
ORDER BY trades_cnt DESC;01