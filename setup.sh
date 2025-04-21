#!/bin/bash
# AWS共通設定のための環境変数
export AWS_PROFILE="dev-user-terraform"
export AWS_REGION="ap-northeast-1"

# 使用方法: source setup.sh の後に terraform コマンドを実行
echo "AWS環境変数が設定されました：プロファイル=$AWS_PROFILE、リージョン=$AWS_REGION" 