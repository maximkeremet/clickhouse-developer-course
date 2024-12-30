-- Lab 6.1: Defining a regular view

-- 1. Create a basic view, just runs the query, not storing the data
CREATE OR REPLACE VIEW london_properties_view 
AS 
    SELECT date, price, addr1, addr2, street
    FROM uk_price_paid
    WHERE town = 'LONDON';

-- 2. Avg prices
SELECT formatReadableQuantity(avg(price)) 
FROM london_properties_view 
WHERE toStartOfYear(date) = '2022-01-01';

SELECT * FROM london_properties_view limit 10;

-- 3. Distinct properties
SELECT formatReadableQuantity(count()) FROM london_properties_view;
-- 2188031

SELECT count(arrayDistinct(array(addr1, addr2, street))) as property FROM london_properties_view;
-- 2188031

-- 4. Check
SELECT formatReadableQuantity(count())
FROM uk_price_paid
WHERE town = 'LONDON';
-- 2188031

-- 5. Compare
-- Counts are identical

-- 6. Explain
EXPLAIN SELECT count() 
FROM london_properties_view;

-- Expression ((Project names + Projection))
-- Aggregating
-- Expression ((Before GROUP BY + (Change column names to column identifiers + (Convert VIEW subquery result to VIEW table structure + (Materialize constants after VIEW subquery + (Project names + (Projection + (Change column names to column identifiers + (Project names + Projection)))))))))
-- Expression
-- ReadFromMergeTree (training.uk_price_paid)


EXPLAIN SELECT count() 
FROM uk_price_paid
WHERE town = 'LONDON';

-- Expression ((Project names + Projection))
-- Aggregating
-- Expression (Before GROUP BY)
-- Filter ((WHERE + Change column names to column identifiers))
-- ReadFromMergeTree (training.uk_price_paid)

-- View uses subquery anad changes column names to some col identifiers.

-- 7. Paramterized View
CREATE OR REPLACE VIEW properties_by_town_view
AS 
    SELECT date, price, addr1, addr2, street
    FROM uk_price_paid
    WHERE town = {town:LowCardinality(String)};

-- 8. Using parametrized query

CREATE OR REPLACE VIEW top_10_properties_in_town_view
AS 
    SELECT street, max(price) as highest_price
    FROM uk_price_paid
    WHERE town = upper({town:LowCardinality(String)})
    GROUP BY 1 
    ORDER BY 2 
    DESC LIMIT 10;

SELECT * FROM top_10_properties_in_town_view(town='LIVERPOOL');