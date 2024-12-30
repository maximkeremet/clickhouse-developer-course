-- Lab 5.1: Writing ad-hoc queries

-- 1. All properties that sold for more than 100,000,000 pounds, sorted by descending price
SELECT arrayDistinct(array(addr1, addr2, street)) as property, formatReadableQuantity(max(price)) as p
FROM uk_price_paid 
WHERE price > 100_000_000 
GROUP BY 1 
ORDER BY 2 DESC;

-- 2. Properties were sold for over 1 million pounds in 2022
SELECT formatReadableQuantity(count(arrayDistinct(array(addr1, addr2, street)))) as property_cnt
FROM uk_price_paid 
WHERE toYear(date) = '2022' AND price > 1_000_000;

-- 3. Unique towns in the dataset
SELECT uniqExact(town) as towns FROM uk_price_paid;

-- 4. Town with the highest number of properties sold 
SELECT town, count() as qty_sold
FROM uk_price_paid 
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;

-- 5. Top 10 towns that are not London with the most properties sold
SELECT topK(10)(town), count() as qty_sold
FROM uk_price_paid 
WHERE town != 'LONDON';
-- A top N based on approximate frequency of values 
-- Returns: ["MANCHESTER","BIRMINGHAM","LEEDS","BRISTOL","NOTTINGHAM","SHEFFIELD","LIVERPOOL","YORK","SOUTHAMPTON","COVENTRY"]

SELECT town, count() as qty_sold
FROM uk_price_paid 
WHERE town != 'LONDON'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10;

-- Actual top 10, based on agg values
-- Returns: MANCHESTER, BRISTOL, BIRMINGHAM, NOTTINGHAM, LEEDS, LIVERPOOL, SHEFFIELD, LEICESTER, SOUTHAMPTON, NORWICH

-- 6. Top 10 most expensive towns to buy property in the UK
SELECT town, avg(price) as avg_price
FROM uk_price_paid 
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10;

-- 7. The most expensive property in the dataset
SELECT argMax(arrayDistinct(array(addr1, addr2, street, town)), price) as most_expensive_property
FROM uk_price_paid;

-- 8. Avg price by prpperty type
SELECT type, avg(price) as avg_price
FROM uk_price_paid 
GROUP BY 1 
ORDER BY 2 DESC;

-- 9. Sum sold in several counties
SELECT formatReadableQuantity(sum(price)) as sum_sold
FROM uk_price_paid 
WHERE county IN ('AVON', 'ESSEX', 'DEVON', 'KENT', 'CORNWALL');
 
-- 10. Average price of properties sold per month from 2005 to 2010
SELECT toYYYYMM(date) as year_month, formatReadableQuantity(avg(price)) as avg_price_sold
FROM uk_price_paid 
WHERE toYear(date) IN ('2005', '2006', '2007', '2008', '2009', '2010')
GROUP BY 1
ORDER BY 1;

-- 11. Properties sold in Liverpool each day in 2020
SELECT date, count() as qty_sold
FROM uk_price_paid 
WHERE toYear(date) = '2020' AND town = 'LIVERPOOL'
GROUP BY 1
ORDER BY 1;

-- 12. Avg sales stats

WITH most_expensive_property AS (
    SELECT argMax(arrayDistinct(array(addr1, addr2, street, town)), price) as property, max(price) as highest_price
    FROM uk_price_paid
)
select * from most_expensive_property

SELECT town, 
       max(price) as most_expensive_property_in_town
FROM uk_price_paid;
GROUP BY 1;

