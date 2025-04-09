#!/bin/bash

# 從 .env 讀取 token
GITHUB_TOKEN=$(grep GITHUB_TOKEN .env | cut -d= -f2)
OWNER="yenhunghuang"
REPO="node-deploy-demo"

echo "🔍 檢查最新的工作流程運行狀態..."

# 獲取並顯示完整的 API 響應以進行調試
echo "📥 獲取工作流程列表..."
WORKFLOW_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs?per_page=1")

echo "API 響應:"
echo "$WORKFLOW_RESPONSE" | jq '.'

# 使用 jq 來正確解析 JSON
WORKFLOW_RUN_ID=$(echo "$WORKFLOW_RESPONSE" | jq -r '.workflow_runs[0].id')

if [ "$WORKFLOW_RUN_ID" = "null" ] || [ -z "$WORKFLOW_RUN_ID" ]; then
  echo "❌ 無法獲取工作流程 ID"
  echo "請確認："
  echo "1. GitHub Token 是否正確"
  echo "2. 是否有正在運行的工作流程"
  echo "3. 倉庫名稱和用戶名是否正確"
  exit 1
fi

echo "✅ 找到工作流程 ID: $WORKFLOW_RUN_ID"
echo "⏳ 等待工作流程完成..."

while true; do
  STATUS_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$WORKFLOW_RUN_ID")
  
  STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
  CONCLUSION=$(echo "$STATUS_RESPONSE" | jq -r '.conclusion')
  
  echo "   狀態: $STATUS, 結果: $CONCLUSION"
  
  if [ "$STATUS" = "completed" ]; then
    break
  fi
  sleep 10
done

if [ "$CONCLUSION" != "success" ]; then
  echo "❌ 工作流程失敗"
  exit 1
fi

echo "✅ 工作流程成功完成"

# 獲取並下載 artifact
echo "📦 下載部署產物..."
ARTIFACTS_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$WORKFLOW_RUN_ID/artifacts")

echo "Artifacts 響應:"
echo "$ARTIFACTS_RESPONSE" | jq '.'

ARTIFACT_ID=$(echo "$ARTIFACTS_RESPONSE" | jq -r '.artifacts[0].id')

if [ "$ARTIFACT_ID" = "null" ] || [ -z "$ARTIFACT_ID" ]; then
  echo "❌ 無法獲取部署產物 ID"
  exit 1
fi

echo "✅ 找到部署產物 ID: $ARTIFACT_ID"

# 下載 artifact
echo "📥 下載部署產物..."
curl -s -L -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
  -o artifact.zip

if [ ! -f artifact.zip ]; then
  echo "❌ 下載部署產物失敗"
  exit 1
fi

# 解壓並部署
echo "📂 部署到本地伺服器..."
rm -rf deploy
mkdir -p deploy
unzip -o artifact.zip -d deploy/
rm artifact.zip

echo "🚀 部署完成！"
echo "🌐 您可以通過 http://localhost:3000 訪問網站"