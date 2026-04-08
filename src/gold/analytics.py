from pyspark.sql import functions as F


class GoldAnalytics:
    def __init__(self, spark, silver_table, gold_table):
        self.spark = spark
        self.silver_table = silver_table
        self.gold_table = gold_table

    def build_monthly_summary(self):
        df_silver = self.spark.read.table(self.silver_table)

        df_gold = (
            df_silver
            .groupBy("taxi_type", "ano", "mes")
            .agg(
                F.count("*").alias("total_corridas"),
                F.sum("fare_amount").alias("valor_total_tarifas"),
                F.sum("tip_amount").alias("valor_total_gorjetas"),
                F.sum("total_amount").alias("valor_total_corridas"),
                F.avg("trip_distance").alias("distancia_media"),
                F.avg("passenger_count").alias("passageiros_medios")
            )
            .withColumn("_data_processamento", F.current_timestamp())
        )

        (
            df_gold.write
            .format("delta")
            .mode("overwrite")
            .option("overwriteSchema", "true")
            .saveAsTable(self.gold_table)
        )