# SQL Analysis

This folder contains the SQL component of the **US Vehicle Sales Analysis** project.

The queries are used to validate the dataset and analyse sales performance, vehicle makes and models, pricing, mileage and state-level trends.

## Dataset

Source:

[Vehicle Sales Data](https://www.kaggle.com/datasets/syedanwarafridi/vehicle-sales-data)

The dataset contains approximately **558,000 US vehicle auction records**.

All queries assume the dataset has been imported into a table named:

```sql
vehicle_sales
```

Change the table name in the queries if necessary.

## SQL Files

### `01_data_quality_checks.sql`

Checks missing values, duplicate VINs, invalid prices, unusual mileage and inconsistent text values.

### `02_sales_summary.sql`

Summarises total records, average selling price, average MMR, average mileage and sales above or below MMR.

### `03_top_makes_models.sql`

Analyses popular makes and models, average selling prices and high-value brands.

### `04_price_and_mileage_analysis.sql`

Examines the relationships among mileage, vehicle condition, MMR and selling price.

### `05_state_sales_analysis.sql`

Compares sales volume, average price, mileage and MMR across US states.

## Folder Structure

```text
sql/
├── README.md
├── 01_data_quality_checks.sql
├── 02_sales_summary.sql
├── 03_top_makes_models.sql
├── 04_price_and_mileage_analysis.sql
└── 05_state_sales_analysis.sql
```

## Running the Queries

Run the files in this order:

1. `01_data_quality_checks.sql`
2. `02_sales_summary.sql`
3. `03_top_makes_models.sql`
4. `04_price_and_mileage_analysis.sql`
5. `05_state_sales_analysis.sql`

Review the data quality checks before interpreting the other results.

## Notes

- The raw CSV is not included because of its size.
- The queries use standard SQL syntax.
- Minor syntax changes may be required depending on the database system.
- MMR should be interpreted as a market benchmark because it is strongly related to selling price.
- Historical auction data may not represent current market prices.