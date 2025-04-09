#!/bin/bash

# 從 .env 讀取 token
GITHUB_TOKEN=$(grep GITHUB_TOKEN .env | cut -d= -f2)
OWNER="yenhunghuang"
REPO="node-deploy-demo"

echo "🔍 檢查最新的工作流程運行狀態..."

# 獲取最新的工作流程運行 ID
WORKFLOW_RUN_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs?per_page=1" \
  | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$WORKFLOW_RUN_ID" ]; then
  echo "❌ 無法獲取工作流程 ID"
  exit 1
fi

echo "⏳ 等待工作流程完成..."

while true; do
  STATUS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$WORKFLOW_RUN_ID" \
    | grep -o '"status":"[^"]*' | cut -d'"' -f4)
  
  if [ "$STATUS" = "completed" ]; then
    break
  fi
  echo "   工作流程仍在運行中..."
  sleep 10
done

# 檢查工作流程結果
CONCLUSION=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$WORKFLOW_RUN_ID" \
  | grep -o '"conclusion":"[^"]*' | cut -d'"' -f4)

if [ "$CONCLUSION" != "success" ]; then
  echo "❌ 工作流程失敗"
  exit 1
fi

echo "✅ 工作流程成功完成"

# 獲取並下載 artifact
echo "📦 下載部署產物..."
ARTIFACTS_URL="https://api.github.com/repos/$OWNER/$REPO/actions/runs/$WORKFLOW_RUN_ID/artifacts"
ARTIFACT_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$ARTIFACTS_URL" \
  | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$ARTIFACT_ID" ]; then
  echo "❌ 無法獲取部署產物 ID"
  exit 1
fi

# 下載 artifact
curl -s -L -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
  -o artifact.zip

# 解壓並部署
echo "📂 部署到本地伺服器..."
rm -rf deploy/*
unzip -o artifact.zip -d deploy/
rm artifact.zip

echo "🚀 部署完成！"
echo "🌐 您可以通過 http://localhost:3000 訪問網站"