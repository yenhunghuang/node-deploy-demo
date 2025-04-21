# Node.js Deployment Demo

這是一個示範 Node.js 應用程序的自動部署流程的專案。

## 功能特點

-   使用 GitHub Actions 實現 CI/CD
-   Docker 容器化部署
-   自動化部署流程
-   Webhook 觸發更新

## 部署流程

1. 推送代碼到 GitHub
2. GitHub Actions 自動觸發構建
3. 構建 Docker 映像並推送到 Docker Hub
4. 執行部署腳本

## 環境要求

-   Node.js 18.x
-   Docker
-   Git

## 測試更新

這是一個測試更新，用於觸發 GitHub Actions 工作流程。
更新時間：2024 年 7 月 16 日 21:30
測試多架構 Docker 映像檔構建 (linux/amd64, linux/arm64)。

## 技術棧

-   Node.js
-   Express.js
-   GitHub Actions
-   ngrok（用於本地開發）
-   Docker

## 前置需求

-   Node.js（建議版本 >= 14）
-   npm 或 yarn
-   GitHub 帳號
-   ngrok
-   Docker

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

### 方法一：直接運行

1. 啟動本地伺服器：

```bash
node server.js
```

2. 啟動 ngrok（在新的終端視窗）：

```bash
ngrok http 3000
```

### 方法二：使用 Docker

1. 建置 Docker 映像檔：

```bash
docker build -t yourname/node-deploy-demo .
```

2. 運行容器：

```bash
docker run -d -p 3000:3000 --env-file .env yourname/node-deploy-demo
```

3. 發布到 Docker Hub（選擇性）：

```bash
# 登入 Docker Hub
docker login

# 標記映像檔
docker tag yourname/node-deploy-demo yourdockerid/node-deploy-demo:latest

# 推送到 Docker Hub
docker push yourdockerid/node-deploy-demo:latest
```

4. 啟動 ngrok：

```bash
ngrok http 3000
```

## 設置 GitHub Webhook

-   在您的 GitHub 儲存庫設置中添加 Webhook
-   URL：您的 ngrok URL（例如：https://xxxx.ngrok.io/webhook）
-   Content type：application/json
-   Secret：與您的 WEBHOOK_SECRET 相同
-   選擇 "Just the push event"

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
-   使用 Docker 時確保 .env 文件正確配置

## Docker 相關指令

```bash
# 列出所有容器
docker ps -a

# 停止容器
docker stop <container_id>

# 移除容器
docker rm <container_id>

# 列出映像檔
docker images

# 移除映像檔
docker rmi <image_id>

# 查看容器日誌
docker logs <container_id>
```

## 開發建議

-   在推送代碼前先在本地測試
-   檢查 GitHub Actions 工作流程狀態
-   監控 Webhook 請求日誌
-   定期備份環境變數
-   使用 Docker 時注意映像檔大小優化

## 故障排除

1. Webhook 404 錯誤：

    - 確認本地伺服器正在運行
    - 驗證 ngrok URL 是否正確
    - 檢查 GitHub Webhook 設置

2. 部署失敗：

    - 檢查 GitHub Actions 日誌
    - 確認 Token 權限
    - 驗證環境變數設置

3. Docker 相關問題：
    - 確認 Docker 服務正在運行
    - 檢查容器日誌
    - 驗證端口映射是否正確
    - 確認環境變數是否正確傳遞

## 關閉服務

當您完成開發時：

1. 在運行 ngrok 的終端按 Ctrl + C
2. 如果使用 Docker：
    ```bash
    docker stop <container_id>
    ```
    如果直接運行：在運行 node server.js 的終端按 Ctrl + C

## 授權

MIT

## 貢獻

歡迎提交 Issue 和 Pull Request！

## 部署腳本功能

webhook_deploy.sh 腳本提供以下功能：

-   自動從 GitHub Actions 下載最新的構建產物
-   驗證 workflow 運行狀態
-   解壓並更新網站內容
-   提供詳細的部署日誌

## Docker 環境說明

Docker 映像檔包含以下工具和功能：

-   git：用於代碼更新
-   curl：用於 API 請求
-   jq：用於解析 JSON 響應
-   unzip：用於解壓構建產物
-   bash：用於執行部署腳本

## 開發流程

1. 本地開發：

    ```bash
    # 修改代碼後
    git add .
    git commit -m "您的提交信息"
    git push
    ```

2. 自動化流程：

    - GitHub Actions 自動構建
    - Webhook 觸發本地部署
    - 部署腳本執行更新

3. 驗證部署：
    - 訪問 http://localhost:3000
    - 檢查部署時間和更新內容
    - 查看容器日誌了解部署狀態
