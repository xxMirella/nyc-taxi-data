locals {
  source_root_local   = abspath("${path.module}/../../src")
  workspace_code_root = "/Workspace/Shared/${var.schema_name}/src"

  source_files = fileset(local.source_root_local, "**")

  source_directories = toset(
    concat(
      ["."],
      distinct([for file in local.source_files : dirname(file)])
    )
  )
}

resource "databricks_directory" "source_directories" {
  for_each = local.source_directories

  path = each.value == "." ? local.workspace_code_root : "${local.workspace_code_root}/${each.value}"
}

resource "databricks_workspace_file" "source_files" {
  for_each = toset(local.source_files)

  source = "${local.source_root_local}/${each.value}"
  path   = "${local.workspace_code_root}/${each.value}"

  depends_on = [databricks_directory.source_directories]
}

resource "databricks_permissions" "workspace_code_root" {
  directory_path = databricks_directory.source_directories["."].path

  access_control {
    user_name        = var.databricks_user_email
    permission_level = "CAN_MANAGE"
  }

  access_control {
    service_principal_name = var.databricks_run_as_service_principal
    permission_level       = "CAN_READ"
  }
}

resource "databricks_job" "nyc_taxi_pipeline" {
  name = var.job_name

  run_as {
    service_principal_name = var.databricks_run_as_service_principal
  }

  environment {
    environment_key = "prod_env"
    spec {
      client = "5"
      dependencies = [
        "-r ${local.workspace_code_root}/requirements.txt"
      ]
    }
  }

  task {
    task_key        = "execute_medallion_pipeline"
    environment_key = "prod_env"

    spark_python_task {
      source      = "WORKSPACE"
      python_file = databricks_workspace_file.source_files["main.py"].path

      parameters = [
        "--env", var.environment
      ]
    }

  }

  depends_on = [
    databricks_workspace_file.source_files,
    databricks_permissions.workspace_code_root
  ]
}