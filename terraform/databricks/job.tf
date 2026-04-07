resource "null_resource" "build_wheel" {
  provisioner "local-exec" {
    command = "python3 setup.py bdist_wheel"
  }
  triggers = {
    always_run = timestamp()
  }
}

resource "databricks_file" "wheel_package" {
  depends_on = [null_resource.build_wheel]
  path       = "${databricks_volume.scripts.volume_path}/nyc_taxi_pipeline-0.1-py3-none-any.whl"
  source     = "${path.module}/../../dist/nyc_taxi_pipeline-0.1-py3-none-any.whl"
}

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
      whl = databricks_file.wheel_package.path
    }

    spark_python_task {
      python_file = "${databricks_volume.scripts.volume_path}/main.py"
      parameters  = ["--env", var.environment]
    }
  }
}