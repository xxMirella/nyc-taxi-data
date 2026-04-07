import time
import sys

if "--zip_path" in sys.argv:
    zip_idx = sys.argv.index("--zip_path") + 1
    sys.path.insert(0, sys.argv[zip_idx])

from config.settings import PATHS
from bronze.ingestor import BronzeIngestor
from silver.processor import SilverProcessor
from utils.spark import get_spark_session
from utils.logger import get_logger


def run_production_pipeline():
    logger = get_logger("NYC_Taxi_Pipeline")
    start_time = time.time()

    logger.info("======= INICIANDO EXECUÇÃO DO PIPELINE MEDALLION =======")

    try:
        logger.info("Inicializando Spark Session...")
        spark = get_spark_session()

        logger.info(f"Iniciando Ingestão Bronze. Origem: {PATHS['landing']}")
        try:
            bronze_start = time.time()
            bronze_handler = BronzeIngestor(
                spark=spark,
                source_path=PATHS["landing"],
                target_path=PATHS["bronze"],
                checkpoint_base_path=PATHS["checkpoints"]
            )
            bronze_handler.execute_incremental_ingestion()

            bronze_duration = time.time() - bronze_start
            logger.info(f"CAMADA BRONZE FINALIZADA. Duração: {bronze_duration:.2f}s")

        except Exception as e:
            logger.error(f"FALHA NA CAMADA BRONZE: {str(e)}", exc_info=True)
            raise

        start_dt, end_dt = "2023-01-01", "2023-05-31"
        logger.info(f"Iniciando Processamento Silver. Período: {start_dt} a {end_dt}")

        try:
            silver_start = time.time()
            silver_handler = SilverProcessor(
                spark=spark,
                bronze_path=PATHS["bronze"],
                silver_path=PATHS["silver"]
            )
            silver_handler.process_and_save(start_date=start_dt, end_date=end_dt)

            silver_duration = time.time() - silver_start
            logger.info(f"CAMADA SILVER FINALIZADA. Duração: {silver_duration:.2f}s")

        except Exception as e:
            logger.error(f"FALHA NA CAMADA SILVER: {str(e)}", exc_info=True)
            raise

        total_duration = time.time() - start_time
        logger.info(f"======= PIPELINE CONCLUÍDO COM SUCESSO EM {total_duration:.2f}s =======")

    except Exception as e:
        total_duration = time.time() - start_time
        logger.critical(f"PIPELINE ABORTADO APÓS {total_duration:.2f}s. Motivo: {str(e)}")
        raise e


if __name__ == "__main__":
    run_production_pipeline()