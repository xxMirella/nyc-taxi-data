from pyspark.sql import functions as F
from config.settings import PATHS


class BronzeIngestor:
    def __init__(self, spark, source_path, target_table, checkpoint_base_path):
        self.spark = spark
        self.source_path = source_path
        self.target_table = target_table
        self.checkpoint_path = f"{checkpoint_base_path}/bronze_nyc_taxi"

    def _extract_metadata_from_path(self, dataframe):
        taxi_type = F.regexp_extract(F.col("_file_name"), r"^([a-zA-Z0-9]+)_", 1)

        return (
            dataframe
            .withColumn("_nome_arquivo", F.col("_file_name"))
            .withColumn("_data_ingestao", F.current_timestamp())
            .withColumn("data_carga", F.current_timestamp())
            .withColumn("ingestion_year", F.year(F.current_timestamp()))
            .withColumn("ingestion_month", F.month(F.current_timestamp()))
            .withColumn("ingestion_day", F.dayofmonth(F.current_timestamp()))
            .withColumn("taxi_type", taxi_type)
        )

    def execute_incremental_ingestion(self):
        raw_stream_df = (
            self.spark.readStream
            .format("cloudFiles")
            .option("cloudFiles.format", "parquet")
            .option("cloudFiles.schemaLocation", f"{self.checkpoint_path}/schema")
            .option("cloudFiles.inferColumnTypes", "true")
            .load(self.source_path)
            .selectExpr(
                "*",
                "_metadata.file_name as _file_name"
            )
        )

        bronze_df = self._extract_metadata_from_path(raw_stream_df)

        query = (bronze_df.writeStream
                 .format("delta")
                 .outputMode("append")
                 .option("checkpointLocation", f"{self.checkpoint_path}/data")
                 .partitionBy("taxi_type", "ingestion_year", "ingestion_month", "ingestion_day")
                 .trigger(availableNow=True)
                 .toTable(self.target_table))

        query.awaitTermination()
