# Node.js Deployment Demo

這是一個示範 Node.js 應用程序的自動部署流程的專案。包含從 GitHub Actions 到 Docker、Kubernetes 的完整部署流程。

## 功能特點

-   使用 GitHub Actions 實現 CI/CD
-   Docker 容器化部署
-   Kubernetes 集群部署
-   自動化部署流程
-   Webhook 觸發更新
-   健康檢查 API 端點
-   優化的構建緩存

## 部署流程

### Docker 部署流程

1. 推送代碼到 GitHub
2. GitHub Actions 自動觸發構建
3. 構建 Docker 映像並推送到 Docker Hub
4. 觸發 Render 平台部署更新

### Kubernetes 部署流程

1. 創建 Kubernetes 部署配置文件
2. 在 Minikube 本地集群中部署應用
3. 通過 NodePort 服務暴露應用
4. 使用 kubectl 進行應用管理和監控

## 環境要求

-   Node.js 18.x
-   Docker
-   Git
-   Kubernetes (Minikube 或其他集群)
-   kubectl

## 測試更新

這是一個測試更新，用於觸發 GitHub Actions 工作流程。
更新時間：2024 年 7 月 16 日 21:30
測試多架構 Docker 映像檔構建 (linux/amd64, linux/arm64)。

## 技術棧

-   Node.js & Express.js
-   GitHub Actions
-   Docker (多架構支持：amd64/arm64)
-   Kubernetes
-   Render (雲端部署)

## 前置需求

-   Node.js（建議版本 >= 18）
-   npm 或 yarn
-   GitHub 帳號
-   Docker 帳號
-   Minikube (本地 Kubernetes)

## 環境設置

1. 克隆專案：

```bash
git clone https://github.com/yenhunghuang/node-deploy-demo.git
cd node-deploy-demo
```

2. 安裝依賴：

```bash
npm install
```

3. 設置環境變數：
   創建 `.env` 文件並添加以下內容：

```
WEBHOOK_SECRET=您的Webhook密鑰
GITHUB_TOKEN=您的GitHub個人訪問令牌
DOCKER_USERNAME=您的Docker用戶名
```

## 啟動專案

### 方法一：直接運行

```bash
node server.js
```

### 方法二：使用 Docker

```bash
docker build -t yourname/node-deploy-demo .
docker run -d -p 3000:3000 --env-file .env yourname/node-deploy-demo
```

### 方法三：使用 Kubernetes (Minikube)

1. 啟動 Minikube：

```bash
minikube start
```

2. 部署應用：

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

3. 獲取服務 URL：

```bash
minikube service node-deploy-demo-service --url
```

4. 訪問應用：

```bash
# 替換 URL 為上一步獲取的 URL
curl http://URL/health
```

## Kubernetes 配置說明

本項目包含兩個主要的 Kubernetes 配置文件：

### 1. deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: node-deploy-demo
    # ... (更多配置)
spec:
    replicas: 1
    # ... (容器配置)
    containers:
        - name: node-deploy-demo
          image: yenhung/node-deploy-demo:latest
          # ... (資源限制、環境變數等)
```

-   定義了應用的部署配置
-   使用 Docker Hub 上的映像檔
-   配置了資源限制和健康檢查
-   設置了必要的環境變數和機密

### 2. service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
    name: node-deploy-demo-service
    # ...
spec:
    type: NodePort
    ports:
        - port: 80
          targetPort: 3000
          nodePort: 30080
    # ...
```

-   通過 NodePort 類型的服務暴露應用
-   將內部 3000 端口映射到節點的 30080 端口
-   允許外部訪問應用

## 健康檢查 API

應用提供了一個健康檢查 API 端點：

```
GET /health
```

回應示例：

```json
{
    "status": "OK",
    "timestamp": "2025-04-26T15:46:48.769Z",
    "uptime": 19.112,
    "memory": {
        "rss": 55488512,
        "heapTotal": 9289728,
        "heapUsed": 7264008,
        "external": 1066163,
        "arrayBuffers": 32970
    },
    "version": "1.0.0",
    "environment": "production"
}
```

此端點可用於：

-   監控應用狀態
-   整合到 UptimeRobot 等監控服務
-   Kubernetes 的存活和就緒探針

## GitHub Actions 優化

本項目的 GitHub Actions 工作流程包含多項優化：

1. **並發控制**：

```yaml
concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true
```

2. **依賴緩存**：

```yaml
- uses: actions/setup-node@v4
  with:
      node-version: ${{ env.NODE_VERSION }}
      cache: "npm"
```

3. **Docker 構建緩存**：

```yaml
cache-from: type=registry,ref=${{ env.DOCKER_IMAGE }}:latest
cache-to: type=inline
```

## 故障排除

### Docker 相關問題

-   確認 Docker 服務正在運行
-   檢查容器日誌
-   驗證環境變數是否正確

### Kubernetes 相關問題

-   檢查 Pod 狀態：`kubectl get pods`
-   查看 Pod 日誌：`kubectl logs <pod-name>`
-   檢查服務配置：`kubectl describe service node-deploy-demo-service`
-   確認 Minikube 狀態：`minikube status`

## 生產環境部署建議

1. 使用名稱空間隔離不同環境：

```bash
kubectl create namespace production
kubectl apply -f k8s/deployment.yaml -n production
```

2. 使用 ConfigMap 和 Secret 管理配置和機密信息
3. 設置資源限制和請求
4. 實施水平自動擴展
5. 配置持久卷存儲數據
6. 設置網絡策略控制流量

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

# Node.js 示例项目

这是一个使用 Node.js 和 Express 构建的示例项目。

## 功能特点

-   Express 服务器
-   Docker 容器化
-   GitHub Actions 自动构建
-   多架构支持 (AMD64/ARM64)
-   Render 自动部署

## 测试自动化部署流程

-   当前时间：2024 年 3 月 19 日
-   目的：验证 GitHub Actions → Docker Hub → Render 的自动化部署流程

## 部署狀態

![Helm Deploy](https://github.com/yenhunghuang/node-deploy-demo/actions/workflows/helm-deploy.yml/badge.svg)
