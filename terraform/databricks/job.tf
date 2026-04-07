resource "databricks_file" "main_script" {
  path   = "${databricks_volume.scripts.volume_path}/main.py"
  source = "${path.module}/../src/main.py"
}

resource "databricks_job" "nyc_taxi_pipeline" {
  name = var.job_name

  environment {
    environment_key = "prod_env"
    spec {
      client = "5"
    }
  }

  task {
    task_key        = "execute_medallion_pipeline"
    environment_key = "prod_env"

    spark_python_task {
      python_file = databricks_file.main_script.path
      parameters  = ["--env", var.environment]
    }
  }
}