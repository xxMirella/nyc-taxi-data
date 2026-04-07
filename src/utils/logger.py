import logging
import sys
import boto3
from watchtower import CloudWatchLogHandler
from botocore.config import Config


def get_logger(log_group_name="/databricks/jobs/nyc-taxi", logger_name="NYC_Taxi_Pipeline"):

    logger = logging.getLogger(logger_name)

    if logger.hasHandlers():
        return logger

    logger.setLevel(logging.INFO)

    console_handler = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter(
        '[%(asctime)s] %(levelname)s [%(name)s.%(funcName)s:%(lineno)d] %(message)s'
    )
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    try:
        boto3_config = Config(
            region_name="us-east-1",
            retries={'max_attempts': 3, 'mode': 'standard'}
        )
        cw_client = boto3.client("logs", config=boto3_config)

        cw_handler = CloudWatchLogHandler(
            log_group_name=log_group_name,
            log_stream_name=f"execution_{logger_name}",
            boto3_client=cw_client,
            send_interval=10,
            create_log_group=False
        )
        cw_handler.setFormatter(formatter)
        logger.addHandler(cw_handler)

    except Exception as e:
        print(f"AVISO: Falha ao inicializar CloudWatch Handler: {str(e)}")

    return logger