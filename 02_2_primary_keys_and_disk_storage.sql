-- Lab 2.2: Primary Keys and Disk Storage

-- 1. Access `pypi` table storage usage
SELECT
    formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size,
    count() AS num_of_active_parts
FROM system.parts
WHERE (active = 1) AND (table = 'pypi');

 -- 2. Access uncompressed size
 -- Compressed sie 59.12 MiB 
 -- Uncompressed size is 223.10 MiB
 -- Because TIMESTAMP is the PK -> very granular


 -- 3. Compare `pypi` and `pypi2` tables
 SELECT
    table,
    formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size,
    count() AS num_of_active_parts
FROM system.parts
WHERE (active = 1) AND (table LIKE '%pypi%')
GROUP BY table;

-- table  compressed_size  uncompressed_size
-- pypi	    59.12 MiB	       223.10 MiB
-- pypi2	14.95 MiB	       219.83 MiB
-- pypi2 is better compressed, because has (project, timestamp) PK, where project is less granular

-- 4. Optimize even more
CREATE OR REPLACE TABLE pypi3 (
    TIMESTAMP DateTime,
    COUNTRY_CODE String,
    URL String,
    PROJECT String 
)
ENGINE = MergeTree
PRIMARY KEY (PROJECT, COUNTRY_CODE, TIMESTAMP);

INSERT INTO pypi3
    SELECT *
    FROM pypi2;

-- 5. Compare all `pypi`-like tables
SELECT
    table,
    formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size,
    count() AS num_of_active_parts
FROM system.parts
WHERE (active = 1) AND (table LIKE '%pypi%')
GROUP BY table;

-- table  compressed_size  uncompressed_size
-- pypi	    59.12 MiB	      223.10 MiB
-- pypi2	14.95 MiB	      219.83 MiB
-- pypi3	13.73 MiB	      219.83 MiB
-- pypi3 has even more optimized PK, thus more optimized

