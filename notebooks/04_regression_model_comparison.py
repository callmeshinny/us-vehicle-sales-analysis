from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import GradientBoostingRegressor, RandomForestRegressor
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

DATA_PATH = Path("data/raw/car_prices.csv")
IMAGE_PATH = Path("images/regression_model_comparison.png")
RESULT_PATH = Path("regression_results.csv")

df = pd.read_csv(DATA_PATH)

features = [
    "year",
    "condition",
    "odometer",
    "mmr",
    "make",
    "body",
    "transmission",
    "state",
]

df = df[features + ["sellingprice"]].copy()
df = df.dropna(subset=["sellingprice"])

# Sample for faster portfolio execution.
if len(df) > 150_000:
    df = df.sample(150_000, random_state=42)

X = df[features]
y = df["sellingprice"]

numeric_features = ["year", "condition", "odometer", "mmr"]
categorical_features = ["make", "body", "transmission", "state"]

numeric_pipeline = Pipeline(
    steps=[
        ("imputer", SimpleImputer(strategy="median")),
    ]
)

categorical_pipeline = Pipeline(
    steps=[
        ("imputer", SimpleImputer(strategy="most_frequent")),
        (
            "encoder",
            OneHotEncoder(handle_unknown="ignore", min_frequency=20),
        ),
    ]
)

preprocessor = ColumnTransformer(
    transformers=[
        ("numeric", numeric_pipeline, numeric_features),
        ("categorical", categorical_pipeline, categorical_features),
    ]
)

models = {
    "Linear Regression": LinearRegression(),
    "Random Forest": RandomForestRegressor(
        n_estimators=100,
        max_depth=18,
        n_jobs=-1,
        random_state=42,
    ),
    "Gradient Boosting": GradientBoostingRegressor(
        n_estimators=150,
        learning_rate=0.05,
        max_depth=3,
        random_state=42,
    ),
}

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
)

results = []

for name, model in models.items():
    pipeline = Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("model", model),
        ]
    )

    print(f"Training {name}...")
    pipeline.fit(X_train, y_train)
    predictions = pipeline.predict(X_test)

    mae = mean_absolute_error(y_test, predictions)
    rmse = mean_squared_error(y_test, predictions) ** 0.5
    r2 = r2_score(y_test, predictions)

    results.append(
        {
            "Model": name,
            "MAE": mae,
            "RMSE": rmse,
            "R2": r2,
        }
    )

results_df = pd.DataFrame(results).sort_values("MAE")
results_df.to_csv(RESULT_PATH, index=False)

print("\nModel results:")
print(results_df.to_string(index=False))

plt.figure(figsize=(9, 5))
plt.bar(results_df["Model"], results_df["MAE"])
plt.ylabel("Mean Absolute Error ($)")
plt.title("Regression Model Comparison")
plt.xticks(rotation=15)
plt.tight_layout()
plt.savefig(IMAGE_PATH, dpi=200)
plt.close()

print(f"\nSaved: {RESULT_PATH}")
print(f"Saved: {IMAGE_PATH}")
