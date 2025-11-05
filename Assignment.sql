CREATE OR REPLACE WAREHOUSE ml_wh
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;
CREATE OR REPLACE DATABASE ml_demo;

USE DATABASE ml_demo;

CREATE OR REPLACE SCHEMA raw;
CREATE OR REPLACE SCHEMA feature_store;

USE WAREHOUSE ml_wh;
USE SCHEMA raw;

SHOW WAREHOUSES;
SHOW DATABASES;
SHOW SCHEMAS;


CREATE OR REPLACE TABLE raw.user_events (
  user_id STRING,
  event_time TIMESTAMP_NTZ,
  event_type STRING,
  amount FLOAT,
  country STRING
);

INSERT INTO raw.user_events VALUES
  ('u1', '2025-10-01 09:00:00', 'purchase', 120.0, 'IN'),
  ('u1', '2025-10-02 10:00:00', 'purchase', 60.0, 'IN'),
  ('u2', '2025-10-01 11:00:00', 'view', NULL, 'US'),
  ('u2', '2025-10-05 17:00:00', 'purchase', 200.0, 'US'),
  ('u3', '2025-10-03 14:00:00', 'purchase', 250.0, 'IN'),
  ('u3', '2025-10-05 09:00:00', 'purchase', 300.0, 'IN'),
  ('u4', '2025-10-06 08:30:00', 'view', NULL, 'CA');

  SELECT * FROM raw.user_events;

  CREATE OR REPLACE TABLE feature_store.user_features AS
SELECT
  user_id,
  COUNT_IF(event_type = 'purchase') AS total_purchases,
  SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) AS total_spent,
  MAX(event_time) AS last_event_time,
  country
FROM raw.user_events
GROUP BY user_id, country;

SELECT * FROM feature_store.user_features;

CREATE OR REPLACE STREAM raw.user_events_stream 
  ON TABLE raw.user_events;
SHOW STREAMS;

CREATE OR REPLACE TASK feature_store.refresh_user_features
  WAREHOUSE = ml_wh
  SCHEDULE = '1 MINUTE'
AS
MERGE INTO feature_store.user_features t
USING (
  SELECT
    user_id,
    COUNT_IF(event_type = 'purchase') AS total_purchases,
    SUM(CASE WHEN event_type = 'purchase' THEN amount ELSE 0 END) AS total_spent,
    MAX(event_time) AS last_event_time,
    ANY_VALUE(country) AS country
  FROM raw.user_events
  GROUP BY user_id, country
) s
ON t.user_id = s.user_id
WHEN MATCHED THEN UPDATE SET
  total_purchases = s.total_purchases,
  total_spent = s.total_spent,
  last_event_time = s.last_event_time,
  country = s.country
WHEN NOT MATCHED THEN INSERT (user_id, total_purchases, total_spent, last_event_time, country)
VALUES (s.user_id, s.total_purchases, s.total_spent, s.last_event_time, s.country);

ALTER TASK feature_store.refresh_user_features RESUME;

SHOW TASKS;

INSERT INTO raw.user_events VALUES ('u1', '2025-10-10 09:00:00', 'purchase', 50.0, 'IN');

SELECT * FROM feature_store.user_features WHERE user_id = 'u1';
