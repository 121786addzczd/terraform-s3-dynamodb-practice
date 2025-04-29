# terraform-s3-dynamodb-practice

## 目次
- [概要](#概要)
- [目的](#目的)
- [背景](#背景)
- [セットアップ手順](#セットアップ手順)
- [注意事項](#注意事項)


## 概要
このリポジトリは、TerraformのS3バックエンド設定とDynamoDBロックの理解を深めるための学習用リポジトリです。
Terraform v1.10から追加された`use_lockfile`機能についても検証します。


## 目的
- Terraformの`backend.tf`ファイルの役割を理解する
- S3とDynamoDBを組み合わせたステートファイル管理とロック制御を学ぶ
- Terraform v1.10で新たに導入された`use_lockfile`オプションの挙動を検証する


## 背景
Terraformではステートファイル（tfstate）の管理とロック制御が重要です。
従来はDynamoDBによるロック機構が主流でしたが、v1.10以降、S3上にロックファイルを作成する`use_lockfile`オプションが導入されました。
このリポジトリでは、従来のDynamoDBロック方式と新しいS3ロック方式の両方を体験できる構成としています。


## セットアップ手順
### 事前準備
- Terraform CLI（v1.10以上）がローカル端末にインストールされていること
- DockerとDocker Composeがインストールされていること


### サービス起動
```bash
docker compose up -d
```

#### MinIOアクセス
- URL: http://localhost:9001
- ID/PW: minioadmin / minioadmin
#### DynamoDB Adminアクセス
- URL: http://localhost:8001


## 注意事項
- 本リポジトリは学習用途向けであり、本番運用を想定していません。
- Terraformはローカル端末上にインストールしておく必要があります。
- v1.10未満のTerraformバージョンでは`use_lockfile`機能は利用できません。