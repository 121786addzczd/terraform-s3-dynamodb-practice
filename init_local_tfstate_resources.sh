#!/bin/bash
set -e

# ==============================================================================
# Script Name: init_local_tfstate_resources.sh
#
# Overview:
#   ローカル環境で Terraform のステート管理に必要な S3 互換バケット（MinIO）および
#   DynamoDB ロックテーブル（DynamoDB Local）を作成します。
#
# Usage:
#   ./init_local_tfstate_resources.sh
#
# Requirements:
#   - .env.dev に以下の環境変数が定義されていること:
#       MINIO_ACCESS_KEY
#       MINIO_SECRET_KEY
#       MINIO_ENDPOINT
#       DYNAMODB_ENDPOINT
#       AWS_REGION
#       ACCOUNT_ALIAS
#       ENV
#   - aws CLI がインストールされていること
#   - MinIO / DynamoDB Local が起動していること（Docker 等）
#
# Notes:
#   - バケットやテーブルが既に存在する場合はスキップします。
#   - aws configure は不要です（環境変数で認証情報を渡しています）。
# ==============================================================================


# ====== 初期設定 ======
LOG_BUCKET_ERR="bucket_error.log"
LOG_TABLE_ERR="table_error.log"

# .env.dev を読み込む
if [ -f .env.dev ]; then
  echo "[INFO]: .env.dev を読み込みます"
  export $(grep -v '^#' .env.dev | xargs)
else
  echo "[ERROR]: .env.dev が見つかりません"
  exit 1
fi

# AWS CLI 設定（MinIO向け）
export AWS_PAGER=""
export AWS_ACCESS_KEY_ID=$MINIO_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$MINIO_SECRET_KEY

TFSTATE_BUCKET="terraform-tfstate-${ACCOUNT_ALIAS}-${ENV}"
LOCK_TABLE="terraform-locks-${ACCOUNT_ALIAS}-${ENV}"

# ====== S3 バケット作成（MinIO） ======
echo "[INFO]: S3 バケット作成開始: $TFSTATE_BUCKET"
if aws --endpoint-url "$MINIO_ENDPOINT" \
    s3api create-bucket \
    --bucket "$TFSTATE_BUCKET" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION" \
    --no-verify-ssl \
    > /dev/null 2> "$LOG_BUCKET_ERR"; then
  rm -f "$LOG_BUCKET_ERR"
  echo "[INFO]: バケット $TFSTATE_BUCKET を作成しました"

else
  if grep -q 'BucketAlreadyOwnedByYou' "$LOG_BUCKET_ERR"; then
    echo "[INFO]: バケット $TFSTATE_BUCKET は既に存在します（スキップ）"
    rm -f "$LOG_BUCKET_ERR"
  else
    echo "[ERROR]: バケット $TFSTATE_BUCKET の作成に失敗しました"
    cat "$LOG_BUCKET_ERR"
    rm -f "$LOG_BUCKET_ERR"
    exit 1
  fi
fi

# ====== DynamoDB テーブル作成（Local） ======
echo "[INFO]: DynamoDB テーブル作成開始: $LOCK_TABLE"
if aws dynamodb create-table \
    --endpoint-url "$DYNAMODB_ENDPOINT" \
    --region "$AWS_REGION" \
    --table-name "$LOCK_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    2> "$LOG_TABLE_ERR"; then

  rm -f "$LOG_TABLE_ERR"
  echo "[INFO]: テーブル $LOCK_TABLE を作成しました"

else
  if grep -q 'ResourceInUseException' "$LOG_TABLE_ERR"; then
    echo "[INFO]: テーブル $LOCK_TABLE は既に存在します（スキップ）"
    rm -f "$LOG_TABLE_ERR"
  else
    echo "[ERROR]: テーブル $LOCK_TABLE の作成に失敗しました"
    cat "$LOG_TABLE_ERR"
    exit 1
  fi
fi

echo "[INFO]: すべての処理が正常に完了しました"
