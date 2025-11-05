from snowflake.snowpark import Session
from snowflake.snowpark.functions import col
import datetime

def main(session: Session):

    
    features_df = session.table("FEATURE_STORE.USER_FEATURES")

    
    print("=== User Features Sample ===")
    features_df.show()

   
    features_df.write.mode("overwrite").save_as_table("FEATURE_STORE.USER_FEATURES_VIEW")

    print(" Feature table 'USER_FEATURES_VIEW' created successfully!")

    
    check_df = session.table("FEATURE_STORE.USER_FEATURES_VIEW")
    check_df.show()

    return check_df
