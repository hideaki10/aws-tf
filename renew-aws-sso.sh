#!/bin/bash
# AWS SSO認証情報を更新するためのスクリプト

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# プロファイル名（デフォルトまたは引数から）
PROFILE=${1:-"dev-user-terraform"}

echo -e "${YELLOW}AWS SSOセッションを更新します (プロファイル: ${PROFILE})...${NC}"

# 現在のトークン期限をチェック
TOKEN_EXPIRY=$(aws configure get sso_session_expiration --profile $PROFILE 2>/dev/null)
CURRENT_TIME=$(date +%s)

if [ -n "$TOKEN_EXPIRY" ]; then
  EXPIRY_TIME=$(date -d "$TOKEN_EXPIRY" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S%z" "$TOKEN_EXPIRY" +%s 2>/dev/null)
  
  # トークンの残り時間（分）を計算
  if [ -n "$EXPIRY_TIME" ]; then
    REMAINING_MINS=$(( ($EXPIRY_TIME - $CURRENT_TIME) / 60 ))
    if [ $REMAINING_MINS -gt 10 ]; then
      echo -e "${GREEN}現在のトークンはまだ有効です（残り約${REMAINING_MINS}分）${NC}"
      echo -e "強制的に更新するには: ${YELLOW}aws sso login --profile $PROFILE${NC}"
      exit 0
    fi
  fi
fi

# SSOログインを実行
echo "AWS SSOログインを開始します..."
aws sso login --profile $PROFILE

if [ $? -eq 0 ]; then
  echo -e "${GREEN}AWS SSOセッションが正常に更新されました！${NC}"
  
  # Terraformのためにプロファイルを環境変数として設定
  export AWS_PROFILE="$PROFILE"
  echo -e "環境変数を設定しました: ${YELLOW}AWS_PROFILE=$PROFILE${NC}"
  
  # 新しいトークンの有効期限を表示
  NEW_EXPIRY=$(aws configure get sso_session_expiration --profile $PROFILE 2>/dev/null)
  if [ -n "$NEW_EXPIRY" ]; then
    echo -e "トークン有効期限: ${YELLOW}$NEW_EXPIRY${NC}"
  fi
  
  echo ""
  echo -e "${YELLOW}このスクリプトは 'source' で実行してください:${NC}"
  echo -e "${GREEN}source renew-aws-sso.sh [プロファイル名]${NC}"
  echo -e "これにより環境変数がシェルセッションに適用されます"
else
  echo -e "\033[0;31mAWS SSOログインに失敗しました。手動で確認してください。\033[0m"
fi 