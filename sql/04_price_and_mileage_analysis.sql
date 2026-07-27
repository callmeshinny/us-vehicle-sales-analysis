-- Analysis of the relationship between mileage and selling price

-- 1. Create mileage bands and compare average selling prices
SELECT
    CASE
        WHEN odometer < 25000 THEN 'Under 25k miles'
        WHEN odometer < 50000 THEN '25k-49,999 miles'
        WHEN odometer < 75000 THEN '50k-74,999 miles'
        WHEN odometer < 100000 THEN '75k-99,999 miles'
        WHEN odometer < 150000 THEN '100k-149,999 miles'
        ELSE '150k+ miles'
    END AS mileage_band,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(mmr), 2) AS average_mmr,
    ROUND(AVG(condition), 2) AS average_condition
FROM vehicle_sales
WHERE odometer IS NOT NULL
  AND sellingprice IS NOT NULL
GROUP BY
    CASE
        WHEN odometer < 25000 THEN 'Under 25k miles'
        WHEN odometer < 50000 THEN '25k-49,999 miles'
        WHEN odometer < 75000 THEN '50k-74,999 miles'
        WHEN odometer < 100000 THEN '75k-99,999 miles'
        WHEN odometer < 150000 THEN '100k-149,999 miles'
        ELSE '150k+ miles'
    END
ORDER BY MIN(odometer);

-- 2. Compare price performance by both model year and mileage band
SELECT
    year,
    CASE
        WHEN odometer < 50000 THEN 'Under 50k miles'
        WHEN odometer < 100000 THEN '50k-99,999 miles'
        ELSE '100k+ miles'
    END AS mileage_band,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(sellingprice - mmr), 2) AS average_price_vs_mmr
FROM vehicle_sales
WHERE year IS NOT NULL
  AND odometer IS NOT NULL
  AND sellingprice IS NOT NULL
  AND mmr IS NOT NULL
GROUP BY
    year,
    CASE
        WHEN odometer < 50000 THEN 'Under 50k miles'
        WHEN odometer < 100000 THEN '50k-99,999 miles'
        ELSE '100k+ miles'
    END
HAVING COUNT(*) >= 50
ORDER BY year DESC, MIN(odometer);

-- 3. Compare condition bands
SELECT
    CASE
        WHEN condition < 20 THEN 'Poor'
        WHEN condition < 30 THEN 'Fair'
        WHEN condition < 40 THEN 'Good'
        ELSE 'Excellent'
    END AS condition_band,
    COUNT(*) AS vehicles_sold,
    ROUND(AVG(odometer), 2) AS average_odometer,
    ROUND(AVG(sellingprice), 2) AS average_selling_price,
    ROUND(AVG(mmr), 2) AS average_mmr
FROM vehicle_sales
WHERE condition IS NOT NULL
  AND sellingprice IS NOT NULL
GROUP BY
    CASE
        WHEN condition < 20 THEN 'Poor'
        WHEN condition < 30 THEN 'Fair'
        WHEN condition < 40 THEN 'Good'
        ELSE 'Excellent'
    END
ORDER BY MIN(condition);

-- 4. Vehicles with the largest positive difference above MMR
SELECT
    year,
    make,
    model,
    trim,
    odometer,
    condition,
    mmr,
    sellingprice,
    sellingprice - mmr AS amount_above_mmr,
    ROUND((sellingprice - mmr) / NULLIF(mmr, 0) * 100, 2) AS percent_above_mmr
FROM vehicle_sales
WHERE sellingprice IS NOT NULL
  AND mmr IS NOT NULL
  AND mmr > 0
ORDER BY amount_above_mmr DESC
LIMIT 50;

-- 5. Vehicles with the largest negative difference below MMR
SELECT
    year,
    make,
    model,
    trim,
    odometer,
    condition,
    mmr,
    sellingprice,
    sellingprice - mmr AS amount_below_mmr,
    ROUND((sellingprice - mmr) / NULLIF(mmr, 0) * 100, 2) AS percent_below_mmr
FROM vehicle_sales
WHERE sellingprice IS NOT NULL
  AND mmr IS NOT NULL
  AND mmr > 0
ORDER BY amount_below_mmr ASC
LIMIT 50;
