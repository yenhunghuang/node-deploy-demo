// 修复版本 - 触发新的 GitHub Actions 构建
// 这个修改是为了修复之前的部署问题
const express = require("express");
const { exec } = require("child_process");
const crypto = require("crypto");
require("dotenv").config();

const app = express();
const port = 3000;

// 用於驗證 GitHub webhook 請求的 secret
const webhookSecret = process.env.WEBHOOK_SECRET || "your-webhook-secret";

// 解析 JSON 請求體
app.use(express.json());

// 靜態文件服務
app.use(express.static("public"));

// Webhook 端點 - POST 請求
app.post("/deploy", (req, res) => {
    console.log("📨 收到 webhook 請求");
    console.log("Headers:", req.headers);

    const signature = req.headers["x-hub-signature-256"];

    if (!signature) {
        console.log("❌ 缺少 Webhook 簽名");
        return res.status(401).send("No signature");
    }

    const payload = JSON.stringify(req.body);

    // 驗證 webhook 簽名
    const hmac = crypto.createHmac("sha256", webhookSecret);
    const digest = "sha256=" + hmac.update(payload).digest("hex");

    if (signature !== digest) {
        console.log("❌ Webhook 簽名驗證失敗");
        console.log("Expected:", digest);
        console.log("Received:", signature);
        return res.status(401).send("Invalid signature");
    }

    console.log("✅ Webhook 簽名驗證成功");

    // 執行部署腳本
    exec("./webhook_deploy.sh", (error, stdout, stderr) => {
        if (error) {
            console.error("❌ 部署失敗:", error);
            return res.status(500).send("Deployment failed");
        }

        console.log("📜 部署日誌:", stdout);
        if (stderr) console.error("⚠️ 部署警告:", stderr);

        res.status(200).send("Deployment triggered");
    });
});

// 測試端點 - GET 請求
app.get("/deploy", (req, res) => {
    res.send(`
    <html>
      <head>
        <title>Webhook 測試頁面</title>
        <style>
          body { font-family: Arial, sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
          pre { background: #f5f5f5; padding: 1rem; border-radius: 4px; }
          .note { color: #666; }
        </style>
      </head>
      <body>
        <h1>Webhook 端點測試頁面</h1>
        <p>這個端點只接受 POST 請求。要測試 webhook，您可以：</p>
        <ol>
          <li>確保伺服器正在運行</li>
          <li>確保 ngrok 正在運行並轉發到這個端口</li>
          <li>在 GitHub 倉庫設置中配置 webhook</li>
          <li>推送新的提交來觸發 webhook</li>
        </ol>
        <p class="note">當前配置：</p>
        <pre>
Webhook URL: ${req.protocol}://${req.get("host")}/deploy
Webhook Secret: ${webhookSecret}
        </pre>
        <p class="note">注意：實際的 webhook 請求應該來自 GitHub，並包含適當的簽名驗證。</p>
      </body>
    </html>
  `);
});

// 健康檢查端點 - 優化用於 UptimeRobot 監控
app.get("/health", (req, res) => {
    const healthData = {
        status: "OK",
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        version: process.env.npm_package_version || "1.0.0",
        environment: process.env.NODE_ENV,
    };

    // UptimeRobot 主要檢查狀態碼，同時我們提供詳細信息供需要時查看
    res.status(200).json(healthData);
});

app.listen(port, () => {
    console.log(`🚀 Server running at http://localhost:${port}`);
    console.log(`📡 Webhook endpoint: http://localhost:${port}/deploy`);
    console.log(`🔑 Using webhook secret: ${webhookSecret}`);
});
