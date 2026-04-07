resource "databricks_job" "nyc-taxi-job" {
  name = var.job_name

  task {
    task_key = "medallion_pipeline"
    new_cluster {
      num_workers   = 4
      spark_version = "13.3.x-scala2.12"
      node_type_id  = "i3.xlarge"
      spark_conf = {
        "spark.databricks.delta.optimizeWrite.enabled" = "true"
        "spark.databricks.delta.autoCompact.enabled"   = "true"
      }
    }
    spark_python_task {
      python_file = var.s3_code_path
      parameters  = ["--env", "prod"]
    }
  }
}