terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key          = "minioadmin"
  secret_key          = "minioadmin"
  region              = "ap-northeast-1"
  # MinIOでは s3_use_path_style = true が必要
  s3_use_path_style   = true

  endpoints {
    s3 = "http://localhost:9000"
    dynamodb = "http://localhost:8000"
  }

  # 認証のエラーが出るため、以下の設定を追加して回避している
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}
