from pyspark.sql import functions as F
from config.settings import RAW_COLUMN_MAPPING, SILVER_MASTER_SCHEMA


def rename_inconsistent_columns(dataframe):
    for raw_name, clean_name in RAW_COLUMN_MAPPING.items():
        if raw_name in dataframe.columns:
            dataframe = dataframe.withColumnRenamed(raw_name, clean_name)
    return dataframe


def align_to_master_schema(dataframe):
    for field in SILVER_MASTER_SCHEMA:
        if field.name not in dataframe.columns:
            dataframe = dataframe.withColumn(field.name, F.lit(None).cast(field.dataType))
        else:
            dataframe = dataframe.withColumn(field.name, F.col(field.name).cast(field.dataType))

    return dataframe.select([field.name for field in SILVER_MASTER_SCHEMA])


def add_time_partitions(dataframe, timestamp_column):
    return dataframe \
        .withColumn("ano", F.year(F.col(timestamp_column))) \
        .withColumn("mes", F.month(F.col(timestamp_column))) \
        .withColumn("dia", F.dayofmonth(F.col(timestamp_column)))