-- Analysis of the most common and highest-value vehicle makes and models

-- 1. Top makes by number of vehicles sold
SELECT
    COALESCE(NULLIF(TRIM(make), ''), 'Unknown') AS make,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(mmr), 2) AS average_mmr,
    ROUND(AVG(odometer), 2) AS average_odometer
FROM vehicle_sales
WHERE sellingprice IS NOT NULL
GROUP BY COALESCE(NULLIF(TRIM(make), ''), 'Unknown')
ORDER BY vehicles_sold DESC
LIMIT 20;

-- 2. Highest-value makes with a meaningful number of sales
SELECT
    TRIM(make) AS make,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(sellingprice - mmr), 2) AS average_price_vs_mmr
FROM vehicle_sales
WHERE make IS NOT NULL
  AND TRIM(make) <> ''
  AND sellingprice IS NOT NULL
  AND mmr IS NOT NULL
GROUP BY TRIM(make)
HAVING COUNT(*) >= 500
ORDER BY average_selling_price DESC
LIMIT 20;

-- 3. Top make-model combinations by sales volume
SELECT
    TRIM(make) AS make,
    TRIM(model) AS model,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(odometer), 2) AS average_odometer,
    ROUND(AVG(condition), 2) AS average_condition
FROM vehicle_sales
WHERE make IS NOT NULL
  AND model IS NOT NULL
  AND TRIM(make) <> ''
  AND TRIM(model) <> ''
  AND sellingprice IS NOT NULL
GROUP BY TRIM(make), TRIM(model)
ORDER BY vehicles_sold DESC
LIMIT 25;

-- 4. Highest-value make-model combinations
SELECT
    TRIM(make) AS make,
    TRIM(model) AS model,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(mmr), 2) AS average_mmr,
    ROUND(AVG(sellingprice - mmr), 2) AS average_price_vs_mmr
FROM vehicle_sales
WHERE make IS NOT NULL
  AND model IS NOT NULL
  AND TRIM(make) <> ''
  AND TRIM(model) <> ''
  AND sellingprice IS NOT NULL
  AND mmr IS NOT NULL
GROUP BY TRIM(make), TRIM(model)
HAVING COUNT(*) >= 100
ORDER BY average_selling_price DESC
LIMIT 25;

-- 5. Models that most often sell above MMR
SELECT
    TRIM(make) AS make,
    TRIM(model) AS model,
    COUNT(*) AS vehicles_sold,
    SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) AS sold_above_mmr,
    ROUND(
        100.0 * SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS percent_sold_above_mmr
FROM vehicle_sales
WHERE make IS NOT NULL
  AND model IS NOT NULL
  AND sellingprice IS NOT NULL
  AND mmr IS NOT NULL
GROUP BY TRIM(make), TRIM(model)
HAVING COUNT(*) >= 100
ORDER BY percent_sold_above_mmr DESC, vehicles_sold DESC
LIMIT 25;
