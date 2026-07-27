from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd

DATA_PATH = Path("data/raw/car_prices.csv")
OUTPUT_PATH = Path("images/business_dashboard.png")

df = pd.read_csv(DATA_PATH)

df["sellingprice"] = pd.to_numeric(df["sellingprice"], errors="coerce")
df["odometer"] = pd.to_numeric(df["odometer"], errors="coerce")
df["mmr"] = pd.to_numeric(df["mmr"], errors="coerce")

clean = df.dropna(subset=["sellingprice"]).copy()

total_sales = len(clean)
average_price = clean["sellingprice"].mean()
average_mmr = clean["mmr"].mean()
average_mileage = clean["odometer"].mean()

top_makes = (
    clean["make"]
    .dropna()
    .value_counts()
    .head(8)
    .sort_values()
)

state_prices = (
    clean.groupby("state")["sellingprice"]
    .agg(["mean", "count"])
    .query("count >= 1000")
    .sort_values("mean", ascending=False)
    .head(8)
    .sort_values("mean")
)

clean["mileage_group"] = pd.cut(
    clean["odometer"],
    bins=[0, 25_000, 50_000, 100_000, 150_000, float("inf")],
    labels=[
        "0–25k",
        "25–50k",
        "50–100k",
        "100–150k",
        "150k+",
    ],
)

mileage_prices = (
    clean.groupby("mileage_group", observed=True)["sellingprice"]
    .mean()
)

fig = plt.figure(figsize=(15, 10))

ax1 = fig.add_subplot(2, 2, 1)
ax1.axis("off")
summary = (
    f"Total vehicles\n{total_sales:,}\n\n"
    f"Average selling price\n${average_price:,.0f}\n\n"
    f"Average MMR\n${average_mmr:,.0f}\n\n"
    f"Average mileage\n{average_mileage:,.0f} miles"
)
ax1.text(0.05, 0.95, summary, va="top", fontsize=16)
ax1.set_title("Key Market Metrics", fontsize=16)

ax2 = fig.add_subplot(2, 2, 2)
top_makes.plot(kind="barh", ax=ax2)
ax2.set_title("Top Vehicle Makes")
ax2.set_xlabel("Number of vehicles")
ax2.set_ylabel("")

ax3 = fig.add_subplot(2, 2, 3)
mileage_prices.plot(kind="bar", ax=ax3)
ax3.set_title("Average Price by Mileage Group")
ax3.set_ylabel("Average selling price ($)")
ax3.set_xlabel("")
ax3.tick_params(axis="x", rotation=25)

ax4 = fig.add_subplot(2, 2, 4)
state_prices["mean"].plot(kind="barh", ax=ax4)
ax4.set_title("Highest Average Prices by State")
ax4.set_xlabel("Average selling price ($)")
ax4.set_ylabel("")

fig.suptitle("US Vehicle Sales Business Dashboard", fontsize=20)
plt.tight_layout()
plt.savefig(OUTPUT_PATH, dpi=200, bbox_inches="tight")
plt.close()

print(f"Saved dashboard to: {OUTPUT_PATH}")
