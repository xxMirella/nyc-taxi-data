from config.settings import PATHS
from bronze.ingestor import BronzeIngestor
from silver.processor import SilverProcessor
from utils.spark import get_spark_session

def run_production_pipeline():
    spark = get_spark_session()

    bronze_handler = BronzeIngestor(
        spark=spark,
        source_path=PATHS["landing"],
        target_path=PATHS["bronze"],
        checkpoint_base_path=PATHS["checkpoints"]
    )
    bronze_handler.execute_incremental_ingestion()

    silver_handler = SilverProcessor(
        spark=spark,
        bronze_path=PATHS["bronze"],
        silver_path=PATHS["silver"]
    )
    silver_handler.process_and_save(start_date="2023-01-01", end_date="2023-05-31")

if __name__ == "__main__":
    run_production_pipeline()