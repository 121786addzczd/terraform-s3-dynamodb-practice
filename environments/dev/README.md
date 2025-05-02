# ローカル環境での Terraform 実行手順（MinIO + DynamoDB Local）

## 前提条件

- Docker および Docker Compose がインストールされていること
- Terraform CLI がインストールされていること

## 実行手順
1.開発用の MinIO / DynamoDB Local を起動します
```bash
docker-compose up -d
```
2.environments/dev/ ディレクトリに移動します
```bash
cd environments/dev
```
3.Terraform 初期化と apply を実行します
```bash
terraform init
terraform apply -auto-approve
```
これにより以下のリソースがローカルで作成されます
- S3 バケット（MinIO 上）
- DynamoDB テーブル（DynamoDB Local 上）

## tfstate ファイルについて
Terraform の状態ファイル（tfstate）は ローカルファイルとして管理 されます（MinIO に直接保存はされません）。

そのため、バックアップや共有が必要な場合は以下のいずれかの方法で MinIO に転送してください

### 方法①：AWS CLI で手動転送
```bash
aws --endpoint-url http://localhost:9000 \
  s3 cp terraform.tfstate s3://dev-bucket/terraform.tfstate \
  --region ap-northeast-1 \
  --no-verify-ssl
```
### 方法②：シェルスクリプトで自動転送
```bash
./upload_tfstate.sh
```

## リソース削除方法
作成したリソースをローカル環境から削除するには以下のコマンドを使用します
```bash
terraform destroy -auto-approve
```
### terraform destroy 実行時の注意
Terraform で S3 バケット（MinIO）を削除する際、バケット内にファイル（オブジェクト）が残っていると削除に失敗します。
そのため、`terraform destroy -auto-approve`を実行する前に、以下のコマンドでバケット内のオブジェクトを空にしてください。
```bash
aws --endpoint-url http://localhost:9000 \
  s3 rm s3://dev-bucket --recursive \
  --region ap-northeast-1 \
  --no-verify-ssl
```


## 注意事項（MinIO + DynamoDB Local の制限）
MinIO と DynamoDB Local を使用したローカル開発環境では、Terraform の backend "s3" を使って状態管理（tfstate）とロック機構（DynamoDB）を完全に構成することはできません。

これは、Terraform の terraform init がバックエンド初期化時に AWS の STS/IAM API にアクセスする仕様となっており、MinIO や DynamoDB Local ではこれを正しく再現できないためです。

そのため、本リポジトリでは以下の構成を採用しています。

- backend は local を使用（tfstate はローカルに保存）
- 必要に応じて MinIO に terraform.tfstate を手動アップロード
- DynamoDB Local はリソース定義や検証のみに利用

本番環境では S3 + DynamoDB（本物の AWS）によるバックエンド構成を推奨します。