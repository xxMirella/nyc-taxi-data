from utils.schema import rename_inconsistent_columns, align_to_master_schema
from pyspark.sql import functions as F


class SilverProcessor:
    def __init__(self, spark, bronze_path, silver_path):
        self.spark = spark
        self.bronze_path = bronze_path
        self.silver_path = silver_path

    def process_and_save(self, start_date, end_date):
        df_bronze = self.spark.read.format("delta").load(self.bronze_path)

        df_normalized = rename_inconsistent_columns(df_bronze)
        df_aligned = align_to_master_schema(df_normalized)

        df_final = df_aligned \
            .withColumn("ano", F.year("pickup_datetime")) \
            .withColumn("mes", F.month("pickup_datetime")) \
            .withColumn("dia", F.dayofmonth("pickup_datetime")) \
            .withColumn("_data_processamento", F.current_timestamp())

        save_condition = f"pickup_datetime >= '{start_date}' AND pickup_datetime <= '{end_date}'"

        df_final.write.format("delta") \
            .mode("overwrite") \
            .option("replaceWhere", save_condition) \
            .partitionBy("taxi_type", "ano", "mes", "dia") \
            .save(self.silver_path)