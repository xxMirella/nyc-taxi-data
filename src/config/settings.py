from pyspark.sql.types import (StructType, IntegerType, TimestampType,
                               DoubleType, StructField, StringType)


CATALOG_NAME = "nyc_taxi_catalog"
SCHEMA_NAME = "nyc_taxi_prod"

LANDING_VOLUME_NAME = "landing"
CHECKPOINT_VOLUME_NAME = "checkpoints"

VOLUME_ROOT = f"/Volumes/{CATALOG_NAME}/{SCHEMA_NAME}"
LANDING_PATH = f"{VOLUME_ROOT}/{LANDING_VOLUME_NAME}"
CHECKPOINT_BASE_PATH = f"{VOLUME_ROOT}/{CHECKPOINT_VOLUME_NAME}"

TABLE_NAMES = {
    "bronze": f"{CATALOG_NAME}.{SCHEMA_NAME}.bronze_nyc_taxi_trips",
    "silver": f"{CATALOG_NAME}.{SCHEMA_NAME}.silver_nyc_taxi_trips",
    "gold": f"{CATALOG_NAME}.{SCHEMA_NAME}.gold_nyc_taxi_monthly_summary",
}

BUCKET_NAME = "55-taxi-data"
BASE_PATH = f"s3://{BUCKET_NAME}"

PATHS = {
    "landing": LANDING_PATH,
    "checkpoints": CHECKPOINT_BASE_PATH,
    "bronze": f"{BASE_PATH}/bronze/{TABLE_NAMES['bronze']}/",
    "silver": f"{BASE_PATH}/silver/{TABLE_NAMES['silver']}/",
    "gold": f"{BASE_PATH}/gold/{TABLE_NAMES['gold']}/"
}

SILVER_MASTER_SCHEMA = StructType([
    StructField("vendor_id", IntegerType(), True),
    StructField("pickup_datetime", TimestampType(), True),
    StructField("dropoff_datetime", TimestampType(), True),
    StructField("passenger_count", IntegerType(), True),
    StructField("trip_distance", DoubleType(), True),
    StructField("rate_code_id", IntegerType(), True),
    StructField("pu_location_id", IntegerType(), True),
    StructField("do_location_id", IntegerType(), True),
    StructField("payment_type", IntegerType(), True),
    StructField("fare_amount", DoubleType(), True),
    StructField("tip_amount", DoubleType(), True),
    StructField("total_amount", DoubleType(), True),
    StructField("taxi_type", StringType(), True),
    StructField("data_carga", TimestampType(), True)
])

RAW_COLUMN_MAPPING = {
    "VendorID": "vendor_id",
    "tpep_pickup_datetime": "pickup_datetime",
    "lpep_pickup_datetime": "pickup_datetime",
    "PULocationID": "pu_location_id",
    "DOLocationID": "do_location_id",
    "RatecodeID": "rate_code_id"
}