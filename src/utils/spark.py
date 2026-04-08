from pyspark.sql import SparkSession


def get_spark_session(app_name="NYC_Taxi_Pipeline"):
    return (
        SparkSession.builder
        .appName(app_name)
        .config("spark.databricks.delta.optimizeWrite.enabled", "true")
        .config("spark.databricks.delta.autoCompact.enabled", "true")
        .config("spark.sql.sources.partitionOverwriteMode", "dynamic")
        .getOrCreate()
    )


def run_delta_maintenance(spark, table_name, zorder_col=None):
    print(f"Iniciando manutenção na tabela: {table_name}")
    if zorder_col:
        spark.sql(f"OPTIMIZE {table_name} ZORDER BY ({zorder_col})")
    else:
        spark.sql(f"OPTIMIZE {table_name}")

    spark.sql(f"VACUUM {table_name} RETAIN 168 HOURS")