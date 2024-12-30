-- Lab 3 Modelling data 

-- Lab 3.1: Using Appropriate Data Types

-- 1. Look at prev table
DESCRIBE pypi;

-- 2. Check cardinality of COUNTRY_CODE
SELECT uniqExact(COUNTRY_CODE) FROM pypi;
--186

-- 3. Check cardinality of PROJECT
SELECT uniqExact(PROJECT) FROM pypi;
-- 24266

-- 4. Create optimized PK
CREATE OR REPLACE TABLE pypi4 (
    TIMESTAMP DateTime,
    COUNTRY_CODE LowCardinality(String),
    URL String,
    PROJECT LowCardinality(String) 
)
ENGINE = MergeTree
PRIMARY KEY (PROJECT, TIMESTAMP);

INSERT INTO pypi4
    SELECT *
    FROM pypi;

-- here miight be error in the assignment description...

CREATE OR REPLACE TABLE pypi5 (
    TIMESTAMP DateTime,
    COUNTRY_CODE LowCardinality(String),
    URL String,
    PROJECT LowCardinality(String) 
)
ENGINE = MergeTree
PRIMARY KEY (COUNTRY_CODE, PROJECT, TIMESTAMP);

INSERT INTO pypi5
    SELECT *
    FROM pypi;

-- 5. Access disk storage statistics
SELECT
    table,
    formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size,
    count() AS num_of_active_parts
FROM system.parts
WHERE (active = 1) AND (table LIKE 'pypi%')
GROUP BY 1
ORDER BY 1;
-- Making columns as LowCardinality maked tables more optimized, but adding COUNTRY_CODE doesn't help


-- 6. Compare query performance

SELECT
    toStartOfMonth(TIMESTAMP) AS month,
    count() AS count
FROM pypi2
WHERE COUNTRY_CODE = 'US'
GROUP BY
    month
ORDER BY
    month ASC,
    count DESC;
-- Elapsed: 0.274s Read: 1,692,671 rows (25.39 MB)

SELECT
    toStartOfMonth(TIMESTAMP) AS month,
    count() AS count
FROM pypi3
WHERE COUNTRY_CODE = 'US'
GROUP BY
    month
ORDER BY
    month ASC,
    count DESC;
-- Queries on pypi{3-5} tables are faster:
-- pypi3 Elapsed: 0.027s Read: 1,692,671 rows (25.39 MB)
-- pypi4 Elapsed: Elapsed: 0.021s Read: 1,692,671 rows (8.46 MB)
-- pypi5 Elapsed: 0.021s Read: 1,209,343 rows (6.05 MB)
