#!/bin/bash
set -e

ENV="dev"
BUCKET_NAME="${ENV}-bucket"
TFSTATE_FILE="terraform.tfstate"
DEST_KEY="terraform.tfstate"
ENDPOINT="http://localhost:9000"
REGION="ap-northeast-1"

echo "[INFO]: MinIOに tfstate をアップロード開始"
if aws --endpoint-url "$ENDPOINT" \
    s3 cp terraform.tfstate "s3://${BUCKET_NAME}/terraform.tfstate" \
    --region "$REGION" \
    --no-verify-ssl; then
  echo "[INFO]: s3://${BUCKET_NAME}/terraform.tfstate アップロード成功"
else
  echo "[ERROR]: アップロード失敗"
  exit 1
fi
