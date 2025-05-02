locals {
  env = "dev"
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "${local.env}-bucket"
}

module "dynamodb_lock_table" {
  source     = "../../modules/dynamodb"
  table_name = "terraform-locks"
}

