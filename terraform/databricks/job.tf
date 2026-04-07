resource "databricks_job" "nyc_taxi_pipeline" {
  name = var.job_name

  task {
    task_key = "execute_medallion_pipeline"

    new_cluster {
      num_workers   = 2
      spark_version = "13.3.x-scala2.12"
      node_type_id  = var.cluster_node_type

      spark_conf = {
        "spark.databricks.delta.optimizeWrite.enabled" = "true"
        "spark.databricks.delta.autoCompact.enabled"   = "true"
      }
    }

    spark_python_task {
      python_file = var.s3_code_path
      parameters  = ["--env", var.environment]
    }
  }
}