data "archive_file" "bundle" {
  type        = "zip"
  source_dir  = "${path.module}/../../src"
  output_path = "${path.module}/bundle.zip"
}

resource "databricks_file" "code_bundle" {
  path   = "${databricks_volume.scripts.volume_path}/bundle.zip"
  source = data.archive_file.bundle.output_path
}

resource "databricks_file" "main_script" {
  path   = "${databricks_volume.scripts.volume_path}/main.py"
  source = "${path.module}/../../src/main.py"
  md5    = filemd5("${path.module}/../../src/main.py")
}

resource "databricks_job" "nyc_taxi_pipeline" {
  name = var.job_name

  run_as {
    user_name = var.databricks_user_email
  }

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

      python_file = "/Volumes/${databricks_catalog.nyc_taxi.name}/${databricks_schema.production.name}/${databricks_volume.scripts.name}/main.py"

      parameters = [
        "--env", var.environment,
        "--zip_path", "/Volumes/${databricks_catalog.nyc_taxi.name}/${databricks_schema.production.name}/${databricks_volume.scripts.name}/bundle.zip"
      ]
    }
  }
  depends_on = [
    databricks_file.main_script,
    databricks_file.code_bundle
  ]
}