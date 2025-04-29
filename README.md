# terraform-s3-dynamodb-practice

## 目次
- [概要](#概要)
- [目的](#目的)
- [背景](#背景)
- [セットアップ手順](#セットアップ手順)
- [Terraform導入ガイド（初めてTerraformを使う方へ）](#terraform導入ガイド初めてterraformを使う方へ)
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


## Terraform導入ガイド（初めてTerraformを使う方へ）
※既にTerraformがインストールされている場合、このセクションは読み飛ばしてください

### miseのインストール
まず、[mise](https://github.com/jdx/mise)（バージョン管理ツール）をインストールします。
miseがすでにインストールされている場合はこのステップをスキップしてください。

```bash
curl https://mise.run | sh && ~/.local/bin/mise --version
```
次に、miseコマンドがシェル起動時に使えるように設定を追加します。
```bash
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```
bashユーザーは .bashrcに書いてください

### miseのパスが通っているか確認
以下コマンドを実行し、パスが通っていることを確認してください。
```bash
which mise
```
（例：command /Users/username/.local/bin/mise "$command" "$@" などが表示されればOK）

### miseを使ったTerraformインストール
Terraformをインストールします。
```bash
mise install terraform
mise use terraform@1.11.4
```
※ここではバージョン1.11.4を指定していますが、Terraform v1.11以上であれば問題ありません。
（v1.10以前では use_lockfile が使えないため注意）

### Terraformのバージョン確認
最後に、Terraformが正しくインストールされたか確認します。

```bash
terraform -v
```
Terraform v1.11系以上が表示されれば準備完了です。

## 注意事項
- 本リポジトリは学習用途向けであり、本番運用を想定していません。
- Terraformはローカル端末上にインストールしておく必要があります。
- v1.10未満のTerraformバージョンでは`use_lockfile`機能は利用できません。
- 現時点では `dynamodb_table` を指定したステートロックも動作しますが、**Terraform公式は DynamoDB ベースのロックを非推奨（Deprecated）としており、将来のバージョンで削除される予定です**。そのため、なるべく **Terraform v1.11 以降のバージョンを使用し、 `use_lockfile = true` を利用する構成に合わせることを推奨します。**
