# 自動部署示範專案 🚀

這個專案展示了如何使用 GitHub Actions 和 Webhook 實現自動化部署流程。

## 功能特點

-   ✨ GitHub Actions 自動化部署
-   🔄 Webhook 觸發本地部署
-   ⏱️ 部署時間計數器
-   🔒 安全的 Webhook 驗證
-   📊 即時部署狀態顯示

## 技術棧

-   Node.js
-   Express.js
-   GitHub Actions
-   ngrok（用於本地開發）

## 前置需求

-   Node.js（建議版本 >= 14）
-   npm 或 yarn
-   GitHub 帳號
-   ngrok

## 環境設置

1. 克隆專案：

```bash
git clone [您的儲存庫URL]
cd node-deploy-demo
```

2. 安裝依賴：

```bash
npm install
```

3. 設置環境變數：
   創建 `.env` 文件並添加以下內容：

```
GITHUB_TOKEN=您的GitHub個人訪問令牌
WEBHOOK_SECRET=您的Webhook密鑰
```

## 啟動專案

1. 啟動本地伺服器：

```bash
node server.js
```

2. 啟動 ngrok（在新的終端視窗）：

```bash
ngrok http 3000
```

3. 設置 GitHub Webhook：
    - 在您的 GitHub 儲存庫設置中添加 Webhook
    - URL：您的 ngrok URL（例如：https://xxxx.ngrok.io/webhook）
    - Content type：application/json
    - Secret：與您的 WEBHOOK_SECRET 相同
    - 選擇 "Just the push event"

## 自動部署流程

1. 開發者推送代碼到 GitHub
2. GitHub Actions 自動運行部署工作流
3. 部署完成後觸發 Webhook
4. 本地伺服器接收 Webhook 並執行部署腳本
5. 網站自動更新

## 注意事項

-   確保 GitHub Token 具有適當的權限
-   本地伺服器必須持續運行以接收 Webhook
-   定期更新 ngrok URL 在 GitHub Webhook 設置中

## 開發建議

-   在推送代碼前先在本地測試
-   檢查 GitHub Actions 工作流程狀態
-   監控 Webhook 請求日誌
-   定期備份環境變數

## 故障排除

1. Webhook 404 錯誤：

    - 確認本地伺服器正在運行
    - 驗證 ngrok URL 是否正確
    - 檢查 GitHub Webhook 設置

2. 部署失敗：
    - 檢查 GitHub Actions 日誌
    - 確認 Token 權限
    - 驗證環境變數設置

## 關閉服務

當您完成開發時：

1. 在運行 ngrok 的終端按 Ctrl + C
2. 在運行 node server.js 的終端按 Ctrl + C

## 授權

MIT

## 貢獻

歡迎提交 Issue 和 Pull Request！
