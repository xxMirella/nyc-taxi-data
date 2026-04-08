from pyspark.sql import functions as F
from utils.schema import rename_inconsistent_columns, align_to_master_schema


class SilverProcessor:
    def __init__(self, spark, bronze_table, silver_table):
        self.spark = spark
        self.bronze_table = bronze_table
        self.silver_table = silver_table

    def process_and_save(self, start_date, end_date):
        df_bronze = self.spark.read.table(self.bronze_table)

        df_filtered = df_bronze.filter(
            (F.col("pickup_datetime") >= F.lit(start_date)) &
            (F.col("pickup_datetime") < F.date_add(F.lit(end_date), 1))
        )

        df_normalized = rename_inconsistent_columns(df_filtered)
        df_aligned = align_to_master_schema(df_normalized)

        df_final = (
            df_aligned
            .withColumn("ano", F.year("pickup_datetime"))
            .withColumn("mes", F.month("pickup_datetime"))
            .withColumn("dia", F.dayofmonth("pickup_datetime"))
            .withColumn("_data_processamento", F.current_timestamp())
        )

        (
            df_final.write
            .format("delta")
            .mode("overwrite")
            .option("overwriteSchema", "true")
            .partitionBy("taxi_type", "ano", "mes", "dia")
            .saveAsTable(self.silver_table)
        )