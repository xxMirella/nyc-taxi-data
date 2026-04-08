import logging
import sys
import boto3
from botocore.config import Config


def get_logger(logger_name="NYC_Taxi_Pipeline", log_group_name="/databricks/jobs/nyc-taxi"):
    logger = logging.getLogger(logger_name)

    if logger.hasHandlers():
        return logger

    logger.setLevel(logging.INFO)

    formatter = logging.Formatter(
        "[%(asctime)s] %(levelname)s [%(name)s.%(funcName)s:%(lineno)d] %(message)s"
    )

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    try:
        import watchtower

        boto3_config = Config(
            region_name="us-east-1",
            retries={"max_attempts": 3, "mode": "standard"},
        )
        cw_client = boto3.client("logs", config=boto3_config)

        cw_handler = watchtower.CloudWatchLogHandler(
            log_group_name=log_group_name,
            log_stream_name=f"execution_{logger_name}",
            boto3_client=cw_client,
            send_interval=10,
            create_log_group=False,
        )
        cw_handler.setFormatter(formatter)
        logger.addHandler(cw_handler)

    except Exception as exc:
        logger.warning("CloudWatch logging disabled: %s", exc)

    return logger