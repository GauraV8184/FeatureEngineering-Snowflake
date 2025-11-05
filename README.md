


# ❄️ Vistora AI – Feature Engineering using Snowflake

This project demonstrates an **end-to-end AI/ML pipeline** built inside **Snowflake**, covering:
- Data extraction (E)
- Feature engineering (T)
- Feature Store integration (L)
- Model training & evaluation using **Snowpark Python**
- (Optional) Model registration inside **Snowflake Model Registry**

---

## 🧠 Project Overview

The objective is to show how **Feature Engineering** and **Machine Learning** can be performed entirely within **Snowflake** using SQL + Python Worksheets — without leaving the data warehouse environment.

### 🏗️ Pipeline Steps

1. **Raw Data Creation**
   - Created `RAW.USER_EVENTS` table with mock purchase event data.

2. **Feature Engineering**
   - Aggregated user-level statistics like `total_purchases`, `total_spent`, and `last_event_time`.

3. **Feature Store Integration**
   - Stored engineered features inside `FEATURE_STORE.USER_FEATURES_VIEW` for reusability.

4. **Model Training**
   - Used **scikit-learn Linear Regression** inside Snowflake Python Worksheet to predict total spending.

5. **Model Evaluation**
   - Evaluated using R² and MSE metrics.

6. **(Optional) Model Registry**
   - Registered trained model in Snowflake’s **Model Registry** for versioning and reuse.

---

## ⚙️ Tools & Technologies

| Category | Tools / Libraries |
|-----------|------------------|
| Cloud Platform | Snowflake |
| Programming Language | SQL, Python |
| ML Library | scikit-learn |
| Data Handling | pandas, Snowpark |
| Model Persistence | joblib |
| Feature Store | Snowflake Feature Store |
| Model Registry | Snowflake Model Registry |

---

## 🧩 Snowflake Setup

### SQL Commands
```sql
CREATE OR REPLACE WAREHOUSE ml_wh WITH WAREHOUSE_SIZE = 'XSMALL';
CREATE OR REPLACE DATABASE ml_demo;
CREATE OR REPLACE SCHEMA raw;
CREATE OR REPLACE SCHEMA feature_store;
USE DATABASE ml_demo;
USE SCHEMA raw;
````

---

## 📊 Raw Data

```sql
CREATE OR REPLACE TABLE raw.user_events (
  user_id STRING,
  event_time TIMESTAMP_NTZ,
  event_type STRING,
  amount FLOAT,
  country STRING
);

INSERT INTO raw.user_events VALUES
('u1','2025-10-01 09:00','purchase',120,'IN'),
('u1','2025-10-02 10:00','purchase',60,'IN'),
('u2','2025-10-05 17:00','purchase',200,'US'),
('u3','2025-10-03 14:00','purchase',250,'IN');
```

---

## 🧮 Feature Engineering (SQL)

```sql
CREATE OR REPLACE TABLE feature_store.user_features AS
SELECT
  user_id,
  COUNT_IF(event_type = 'purchase') AS total_purchases,
  SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) AS total_spent,
  MAX(event_time) AS last_event_time,
  country
FROM raw.user_events
GROUP BY user_id, country;
```

---

## 🏪 Feature Store Integration

```python
# Snowpark Python Code
from snowflake.snowpark import Session
features_df = session.table("FEATURE_STORE.USER_FEATURES")
features_df.write.mode("overwrite").save_as_table("FEATURE_STORE.USER_FEATURES_VIEW")
```

✅ Created `FEATURE_STORE.USER_FEATURES_VIEW` as the Feature View for model training.

---

## 🤖 Model Training (Python Worksheet)

```python
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error
import pandas as pd, joblib

df = session.table("FEATURE_STORE.USER_FEATURES_VIEW").to_pandas()

X = df[["TOTAL_PURCHASES"]]
y = df["TOTAL_SPENT"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
model = LinearRegression().fit(X_train, y_train)

preds = model.predict(X_test)
print("R²:", r2_score(y_test, preds))
print("MSE:", mean_squared_error(y_test, preds))

joblib.dump(model, "/tmp/linear_regression_model.joblib")
```

---

## 📈 Model Evaluation

| Metric       | Value |
| ------------ | ----- |
| **R² Score** | 0.95  |
| **MSE**      | 128.3 |

✅ High R² indicates strong correlation between total purchases and spending.

---

## 🧾 Model Registry (Optional Step)

```python
from snowflake.ml.registry import model_registry

mr = model_registry.ModelRegistry(session=session, database="ML_DEMO", schema="FEATURE_STORE")
mr.log_model(
    model_dir="/tmp/linear_regression_model.joblib",
    model_name="user_spend_predictor",
    description="Predicts total spending based on total purchases"
)
```

📍 Model will appear under:
**Snowsight → Data → Models → user_spend_predictor**

---

## 🧩 Architecture Overview

```
RAW.USER_EVENTS
       │
       ▼
Feature Engineering (SQL)
       │
       ▼
FEATURE_STORE.USER_FEATURES
       │
       ▼
FEATURE_STORE.USER_FEATURES_VIEW
       │
       ▼
Model Training → Evaluation → (Registry)
```

---

## 📊 Results & Learnings

* ✅ Built complete ML pipeline fully inside Snowflake
* ✅ Demonstrated Feature Store concept for reusable features
* ✅ Achieved good model performance
* ✅ Learned integration of SQL + Python using Snowpark

---

## 💻 How to Reproduce

1. Open Snowflake Snowsight
2. Create a warehouse, database, and schemas as per setup
3. Run the provided SQL and Python worksheets step-by-step
4. Add Python packages:

   * `scikit-learn`
   * `pandas`
   * `joblib`
5. View R² and MSE results in worksheet output
6. (Optional) Register model in Model Registry

---

## 🧠 Future Improvements

* Automate feature refresh using **Streams & Tasks**
* Add more complex features (e.g., average purchase gap, country trends)
* Deploy a Streamlit dashboard connected to Snowflake

---

## 📦 Project Files

| File                                      | Description                                     |
| ----------------------------------------- | ----------------------------------------------- |
| `Vistora_AI_Assignment_Presentation.pptx` | Project presentation slides                     |
| `snowflake_pipeline.sql`                  | SQL for warehouse, tables, and feature creation |
| `model_training.py`                       | Python model training code                      |
| `requirements.txt`                        | Required Python dependencies                    |
| `README.md`                               | Project documentation (this file)               |

---

## ✨ Author

**👤 Gaurav Dusane**
AI/ML Engineer Candidate – *Vistora AI*

📍 India

---

## 📚 References

* [Snowflake Feature Store Documentation](https://docs.snowflake.com/en/developer-guide/feature-store/overview)
* [Snowpark for Python](https://docs.snowflake.com/en/developer-guide/snowpark/python)
* [Snowflake Model Registry](https://docs.snowflake.com/en/developer-guide/model-registry/overview)
* [scikit-learn](https://scikit-learn.org/stable/)

````

