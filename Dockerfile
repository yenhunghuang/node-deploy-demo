FROM node:18-alpine

# 安裝必要的工具
RUN apk add --no-cache \
    git \
    curl \
    jq \
    unzip \
    bash

WORKDIR /app

# 複製 package.json 和 package-lock.json（如果存在）
COPY package*.json ./

# 安裝依賴
RUN npm install

# 複製其餘源代碼
COPY . .

# 確保部署腳本有執行權限
RUN chmod +x webhook_deploy.sh

# 設置環境變數
ENV NODE_ENV=production

# 開放 3000 端口
EXPOSE 3000

# 啟動服務
CMD ["node", "server.js"] 