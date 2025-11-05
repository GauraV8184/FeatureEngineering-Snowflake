
import pandas as pd
import joblib
from snowflake.snowpark import Session, Row
from snowflake.snowpark.functions import col
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error

def main(session):  
    
    
    df = session.table("FEATURE_STORE.USER_FEATURES_VIEW")
    print("=== Sample of Feature Data ===")
    df.show()

    
    pdf = df.to_pandas()

    
    feature_cols = ["TOTAL_PURCHASES"]
    target_col = "TOTAL_SPENT"

    
    pdf = pdf.dropna(subset=feature_cols + [target_col])

    
    X_train, X_test, y_train, y_test = train_test_split(
        pdf[feature_cols], pdf[target_col], test_size=0.3, random_state=42
    )

    
    model = LinearRegression()
    model.fit(X_train, y_train)

    
    preds = model.predict(X_test)
    r2 = r2_score(y_test, preds)
    mse = mean_squared_error(y_test, preds)

    print("Model trained successfully!")
    print(f"R² Score: {r2:.4f}")
    print(f"MSE: {mse:.4f}")

    
    joblib.dump(model, "/tmp/linear_regression_model.joblib")
    print("Model saved successfully at /tmp/linear_regression_model.joblib")

   
    return session.create_dataframe([Row(R2_Score=r2, MSE=mse)])
