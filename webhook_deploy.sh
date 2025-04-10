#!/bin/bash

# webhook_deploy.sh
# 此腳本由本地 Webhook Server 自動觸發（POST /deploy 時執行）
# ✅ 用於自動從 GitHub Actions 拉最新 artifact 並部署至本地伺服器

# 載入 token 和 repo 設定
GITHUB_TOKEN=$(grep GITHUB_TOKEN .env | cut -d= -f2)
OWNER="yenhunghuang"
REPO="node-deploy-demo"

echo "🚀 開始部署流程..."
echo "📦 正在檢查最新的 workflow run..."

# Step 1: 取得最新成功的 workflow run
WORKFLOW_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs?per_page=1")

WORKFLOW_RUN_ID=$(echo "$WORKFLOW_RESPONSE" | jq -r '.workflow_runs[0].id')

if [ "$WORKFLOW_RUN_ID" = "null" ] || [ -z "$WORKFLOW_RUN_ID" ]; then
  echo "❌ 無法取得 Workflow Run ID"
  exit 1
fi

echo "✅ 找到最新的 workflow run: $WORKFLOW_RUN_ID"

# Step 2: 確認是否成功完成
STATUS_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$WORKFLOW_RUN_ID")

STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
CONCLUSION=$(echo "$STATUS_RESPONSE" | jq -r '.conclusion')

echo "📋 Workflow 狀態: $STATUS"
echo "📋 執行結果: $CONCLUSION"

if [ "$STATUS" != "completed" ] || [ "$CONCLUSION" != "success" ]; then
  echo "❌ 工作流程尚未完成或失敗，無法部署"
  exit 1
fi

# Step 3: 抓取 artifact ID
echo "🔍 正在查找構建產物..."
ARTIFACTS_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$WORKFLOW_RUN_ID/artifacts")

ARTIFACT_ID=$(echo "$ARTIFACTS_RESPONSE" | jq -r '.artifacts[0].id')

if [ "$ARTIFACT_ID" = "null" ] || [ -z "$ARTIFACT_ID" ]; then
  echo "❌ 無法取得 Artifact ID"
  exit 1
fi

echo "✅ 找到構建產物 ID: $ARTIFACT_ID"

# Step 4: 下載與解壓縮 artifact
echo "📥 正在下載構建產物..."
curl -s -L -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
  -o artifact.zip

if [ ! -f artifact.zip ]; then
  echo "❌ Artifact 下載失敗"
  exit 1
fi

# Step 5: 部署到 public/ 目錄
echo "📂 正在解壓並部署..."
rm -rf deploy
mkdir -p deploy
unzip -o artifact.zip -d deploy/
rm artifact.zip

# 更新 public 目錄內容
echo "🔄 更新網站內容..."
rm -rf public/*
cp -r deploy/* public/

echo "✨ 清理臨時文件..."
rm -rf deploy

echo "✅ 自動部署完成！"
echo "🌐 您可以通過 http://localhost:3000 或 ngrok URL 查看更新後的網站。"