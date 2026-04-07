resource "databricks_job" "nyc_taxi_pipeline" {
  name = var.job_name

  environment {
    environment_key = "prod_env"
    spec {
      client = "default"
    }
  }

  task {
    task_key        = "execute_medallion_pipeline"
    environment_key = "prod_env"

    library {
      pypi {
        package = "opentelemetry-api"
      }
    }
    library {
      pypi {
        package = "opentelemetry-sdk"
      }
    }
    library {
      pypi {
        package = "opentelemetry-exporter-otlp"
      }
    }
    library {
      pypi {
        package = "watchtower"
      }
    }

    spark_python_task {
      python_file = var.s3_code_path
      parameters  = ["--env", var.environment]
    }
  }

  max_concurrent_runs = 1
}