import time

from config.settings import PATHS, TABLE_NAMES
from bronze.ingestor import BronzeIngestor
from silver.processor import SilverProcessor
from gold.analytics import GoldAnalytics
from utils.spark import get_spark_session
from utils.logger import get_logger


def run_production_pipeline():
    logger = get_logger("NYC_Taxi_Pipeline")
    start_time = time.time()

    logger.info("======= INICIANDO EXECUÇÃO DO PIPELINE MEDALLION =======")

    try:
        logger.info("Inicializando Spark Session...")
        spark = get_spark_session()

        logger.info("Iniciando ingestão Bronze. Origem: %s", PATHS["landing"])
        bronze_start = time.time()

        bronze_handler = BronzeIngestor(
            spark=spark,
            source_path=PATHS["landing"],
            target_table=TABLE_NAMES["bronze"],
            checkpoint_base_path=PATHS["checkpoints"],
        )
        bronze_handler.execute_incremental_ingestion()

        bronze_duration = time.time() - bronze_start
        logger.info("CAMADA BRONZE FINALIZADA. Duração: %.2fs", bronze_duration)

        start_dt, end_dt = "2023-01-01", "2023-05-31"
        logger.info("Iniciando Processamento Silver. Período: %s a %s", start_dt, end_dt)

        silver_start = time.time()
        silver_handler = SilverProcessor(
            spark=spark,
            bronze_table=TABLE_NAMES["bronze"],
            silver_table=TABLE_NAMES["silver"],
        )
        silver_handler.process_and_save(start_date=start_dt, end_date=end_dt)

        silver_duration = time.time() - silver_start
        logger.info("CAMADA SILVER FINALIZADA. Duração: %.2fs", silver_duration)

        gold_start = time.time()
        gold_handler = GoldAnalytics(
            spark=spark,
            silver_table=TABLE_NAMES["silver"],
            gold_table=TABLE_NAMES["gold"],
        )
        gold_handler.build_monthly_summary()

        gold_duration = time.time() - gold_start
        logger.info("CAMADA GOLD FINALIZADA. Duração: %.2fs", gold_duration)

        total_duration = time.time() - start_time
        logger.info("======= PIPELINE CONCLUÍDO COM SUCESSO EM %.2fs =======", total_duration)

    except Exception as exc:
        total_duration = time.time() - start_time
        logger.exception("PIPELINE ABORTADO APÓS %.2fs. Motivo: %s", total_duration, exc)
        raise


if __name__ == "__main__":
    run_production_pipeline()