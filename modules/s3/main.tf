resource "aws_s3_bucket" "development-bucket" {
  bucket = var.bucket_name
}
