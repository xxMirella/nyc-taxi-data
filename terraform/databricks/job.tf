resource "databricks_job" "nyc_taxi_pipeline" {
  name = var.job_name

  environment {
    environment_key = "prod_env"
    spec {
      client = "13.3.x-scala2.12"
    }
  }

  task {
    task_key = "execute_medallion_pipeline"

    environment_key = "prod_env"

    spark_python_task {
      python_file = var.s3_code_path
      parameters  = ["--env", var.environment]
    }
  }
}