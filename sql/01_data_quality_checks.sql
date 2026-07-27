-- Data quality checks for the vehicle_sales table
-- Update the table name if your imported table uses a different name.

-- 1. Total row count
SELECT COUNT(*) AS total_rows
FROM vehicle_sales;

-- 2. Missing values in important columns
SELECT
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS missing_year,
    SUM(CASE WHEN make IS NULL OR TRIM(make) = '' THEN 1 ELSE 0 END) AS missing_make,
    SUM(CASE WHEN model IS NULL OR TRIM(model) = '' THEN 1 ELSE 0 END) AS missing_model,
    SUM(CASE WHEN transmission IS NULL OR TRIM(transmission) = '' THEN 1 ELSE 0 END) AS missing_transmission,
    SUM(CASE WHEN condition IS NULL THEN 1 ELSE 0 END) AS missing_condition,
    SUM(CASE WHEN odometer IS NULL THEN 1 ELSE 0 END) AS missing_odometer,
    SUM(CASE WHEN mmr IS NULL THEN 1 ELSE 0 END) AS missing_mmr,
    SUM(CASE WHEN sellingprice IS NULL THEN 1 ELSE 0 END) AS missing_sellingprice,
    SUM(CASE WHEN saledate IS NULL OR TRIM(saledate) = '' THEN 1 ELSE 0 END) AS missing_saledate
FROM vehicle_sales;

-- 3. Duplicate VIN values
SELECT
    vin,
    COUNT(*) AS duplicate_count
FROM vehicle_sales
WHERE vin IS NOT NULL
  AND TRIM(vin) <> ''
GROUP BY vin
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, vin;

-- 4. Invalid or suspicious numeric values
SELECT
    SUM(CASE WHEN year < 1980 OR year > 2015 THEN 1 ELSE 0 END) AS unusual_years,
    SUM(CASE WHEN condition < 1 OR condition > 49 THEN 1 ELSE 0 END) AS invalid_condition,
    SUM(CASE WHEN odometer < 0 THEN 1 ELSE 0 END) AS negative_odometer,
    SUM(CASE WHEN odometer > 500000 THEN 1 ELSE 0 END) AS extreme_odometer,
    SUM(CASE WHEN mmr <= 0 THEN 1 ELSE 0 END) AS non_positive_mmr,
    SUM(CASE WHEN sellingprice <= 0 THEN 1 ELSE 0 END) AS non_positive_sellingprice
FROM vehicle_sales;

-- 5. Basic numeric ranges
SELECT
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    MIN(condition) AS min_condition,
    MAX(condition) AS max_condition,
    MIN(odometer) AS min_odometer,
    MAX(odometer) AS max_odometer,
    MIN(mmr) AS min_mmr,
    MAX(mmr) AS max_mmr,
    MIN(sellingprice) AS min_sellingprice,
    MAX(sellingprice) AS max_sellingprice
FROM vehicle_sales;

-- 6. Inconsistent categorical values caused by casing or spaces
SELECT
    LOWER(TRIM(make)) AS standardised_make,
    COUNT(DISTINCT make) AS original_variations,
    COUNT(*) AS vehicle_count
FROM vehicle_sales
WHERE make IS NOT NULL
  AND TRIM(make) <> ''
GROUP BY LOWER(TRIM(make))
HAVING COUNT(DISTINCT make) > 1
ORDER BY original_variations DESC, vehicle_count DESC;
