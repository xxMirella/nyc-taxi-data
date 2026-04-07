from pyspark.sql import SparkSession


def get_spark_session(app_name="NYC_Taxi_Pipeline"):
    """Retorna a sessão Spark configurada para performance Delta."""
    return SparkSession.builder \
        .appName(app_name) \
        .config("spark.databricks.delta.optimizeWrite.enabled", "true") \
        .config("spark.databricks.delta.autoCompact.enabled", "true") \
        .config("spark.sql.sources.partitionOverwriteMode", "dynamic") \
        .getOrCreate()


def run_delta_maintenance(spark, table_path, zorder_col=None):
    """Executa manutenção periódica para evitar small files e otimizar leitura."""
    print(f"Iniciando manutenção na tabela: {table_path}")
    if zorder_col:
        spark.sql(f"OPTIMIZE delta.`{table_path}` ZORDER BY ({zorder_col})")
    else:
        spark.sql(f"OPTIMIZE delta.`{table_path}`")

    # Vacuum de 7 dias (padrão) para permitir Time Travel seguro
    spark.sql(f"VACUUM delta.`{table_path}` RETENTION 168 HOURS")