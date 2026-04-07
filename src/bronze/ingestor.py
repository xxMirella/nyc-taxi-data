from pyspark.sql import functions as F
from config.settings import PATHS


class BronzeIngestor:
    def __init__(self, spark, source_path, target_path, checkpoint_base_path):
        self.spark = spark
        self.source_path = source_path
        self.target_path = target_path
        self.checkpoint_path = f"{checkpoint_base_path}/bronze_nyc_taxi"

    def _extract_metadata_from_path(self, dataframe):
        return dataframe \
            .withColumn("_arquivo_origem", F.input_file_name()) \
            .withColumn("_data_ingestao", F.current_timestamp()) \
            .withColumn("ingestion_year", F.year(F.current_timestamp())) \
            .withColumn("ingestion_month", F.month(F.current_timestamp())) \
            .withColumn("taxi_type", F.element_at(F.split(F.element_at(F.split(F.input_file_name(), "/"), -1), "_"), 1))


    def execute_incremental_ingestion(self):
        raw_stream_df = (self.spark.readStream
                         .format("cloudFiles")
                         .option("cloudFiles.format", "parquet")
                         .option("cloudFiles.schemaLocation", f"{self.checkpoint_path}/schema")
                         .option("cloudFiles.inferColumnTypes", "true")
                         .load(self.source_path))

        bronze_df = self._extract_metadata_from_path(raw_stream_df)

        query = (bronze_df.writeStream
                 .format("delta")
                 .outputMode("append")
                 .option("checkpointLocation", f"{self.checkpoint_path}/data")
                 .partitionBy("taxi_type", "ingestion_year", "ingestion_month")
                 .trigger(availableNow=True)
                 .start(self.target_path))

        query.awaitTermination()