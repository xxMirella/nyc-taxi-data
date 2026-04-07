resource "databricks_job" "nyc_taxi_pipeline" {
  name = var.job_name

  task {
    task_key = "execute_medallion_pipeline"

    spark_python_task {
      python_file = var.s3_code_path
      parameters  = ["--env", var.environment]
    }
  }
}