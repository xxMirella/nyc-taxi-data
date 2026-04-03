module "bootstrap" {
  source = "./bootstrap"
  github_repo = "xxMirella/nyc-taxi-data"

  providers = {
    aws = aws
  }
}
