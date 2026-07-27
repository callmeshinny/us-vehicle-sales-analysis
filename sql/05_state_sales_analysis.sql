-- State-level vehicle sales analysis

-- 1. Sales volume and average price by state
SELECT
    UPPER(TRIM(state)) AS state,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(mmr), 2) AS average_mmr,
    ROUND(AVG(odometer), 2) AS average_odometer,
    ROUND(AVG(condition), 2) AS average_condition
FROM vehicle_sales
WHERE state IS NOT NULL
  AND TRIM(state) <> ''
  AND sellingprice IS NOT NULL
GROUP BY UPPER(TRIM(state))
ORDER BY vehicles_sold DESC;

-- 2. States with the highest average selling prices
SELECT
    UPPER(TRIM(state)) AS state,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(sellingprice - mmr), 2) AS average_price_vs_mmr
FROM vehicle_sales
WHERE state IS NOT NULL
  AND TRIM(state) <> ''
  AND sellingprice IS NOT NULL
  AND mmr IS NOT NULL
GROUP BY UPPER(TRIM(state))
HAVING COUNT(*) >= 500
ORDER BY average_selling_price DESC;

-- 3. States where vehicles most often sell above MMR
SELECT
    UPPER(TRIM(state)) AS state,
    COUNT(*) AS vehicles_sold,
    SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) AS sold_above_mmr,
    ROUND(
        100.0 * SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS percent_sold_above_mmr,
    ROUND(AVG(sellingprice - mmr), 2) AS average_price_vs_mmr
FROM vehicle_sales
WHERE state IS NOT NULL
  AND TRIM(state) <> ''
  AND sellingprice IS NOT NULL
  AND mmr IS NOT NULL
GROUP BY UPPER(TRIM(state))
HAVING COUNT(*) >= 500
ORDER BY percent_sold_above_mmr DESC, vehicles_sold DESC;

-- 4. Most common vehicle makes in each state
WITH make_sales AS (
    SELECT
        UPPER(TRIM(state)) AS state,
        TRIM(make) AS make,
        COUNT(*) AS vehicles_sold,
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(state))
            ORDER BY COUNT(*) DESC
        ) AS make_rank
    FROM vehicle_sales
    WHERE state IS NOT NULL
      AND TRIM(state) <> ''
      AND make IS NOT NULL
      AND TRIM(make) <> ''
    GROUP BY UPPER(TRIM(state)), TRIM(make)
)
SELECT
    state,
    make,
    vehicles_sold
FROM make_sales
WHERE make_rank <= 3
ORDER BY state, make_rank;

-- 5. State and body-type combinations with the highest sales volume
SELECT
    UPPER(TRIM(state)) AS state,
    COALESCE(NULLIF(TRIM(body), ''), 'Unknown') AS body_type,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price
FROM vehicle_sales
WHERE state IS NOT NULL
  AND TRIM(state) <> ''
  AND sellingprice IS NOT NULL
GROUP BY
    UPPER(TRIM(state)),
    COALESCE(NULLIF(TRIM(body), ''), 'Unknown')
HAVING COUNT(*) >= 100
ORDER BY vehicles_sold DESC
LIMIT 50;
