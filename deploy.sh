#!/bin/bash
echo "⚙️ 模擬部署中..."
rm -rf deploy
mkdir deploy
cp -r public/* deploy/
echo "✅ Deploy 完成，請檢查 deploy/ 內容"