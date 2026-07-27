-- Overall sales summary for the vehicle_sales table

-- 1. High-level sales KPIs
SELECT
    COUNT(*) AS total_vehicles,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(MIN(sellingprice), 2) AS minimum_selling_price,
    ROUND(MAX(sellingprice), 2) AS maximum_selling_price,
    ROUND(AVG(mmr), 2) AS average_mmr,
    ROUND(AVG(odometer), 2) AS average_odometer,
    ROUND(AVG(condition), 2) AS average_condition
FROM vehicle_sales
WHERE sellingprice IS NOT NULL;

-- 2. Difference between selling price and MMR
SELECT
    ROUND(AVG(sellingprice - mmr), 2) AS average_price_difference,
    ROUND(AVG((sellingprice - mmr) / NULLIF(mmr, 0) * 100), 2) AS average_difference_percent,
    SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) AS sold_above_mmr,
    SUM(CASE WHEN sellingprice = mmr THEN 1 ELSE 0 END) AS sold_at_mmr,
    SUM(CASE WHEN sellingprice < mmr THEN 1 ELSE 0 END) AS sold_below_mmr
FROM vehicle_sales
WHERE sellingprice IS NOT NULL
  AND mmr IS NOT NULL;

-- 3. Sales summary by model year
SELECT
    year,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(mmr), 2) AS average_mmr,
    ROUND(AVG(odometer), 2) AS average_odometer,
    ROUND(AVG(condition), 2) AS average_condition
FROM vehicle_sales
WHERE sellingprice IS NOT NULL
GROUP BY year
ORDER BY year DESC;

-- 4. Sales summary by body type
SELECT
    COALESCE(NULLIF(TRIM(body), ''), 'Unknown') AS body_type,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(odometer), 2) AS average_odometer
FROM vehicle_sales
WHERE sellingprice IS NOT NULL
GROUP BY COALESCE(NULLIF(TRIM(body), ''), 'Unknown')
HAVING COUNT(*) >= 100
ORDER BY vehicles_sold DESC;

-- 5. Sales summary by transmission
SELECT
    COALESCE(NULLIF(TRIM(transmission), ''), 'Unknown') AS transmission_type,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(odometer), 2) AS average_odometer
FROM vehicle_sales
WHERE sellingprice IS NOT NULL
GROUP BY COALESCE(NULLIF(TRIM(transmission), ''), 'Unknown')
ORDER BY vehicles_sold DESC;
