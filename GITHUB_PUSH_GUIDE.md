# GitHub 推送指南

## 🚀 方式一：使用 PowerShell 脚本（推荐）

在项目目录下打开 PowerShell，运行：

```powershell
.\deploy_to_github.ps1
```

脚本会自动检测环境并引导你完成部署。

---

## 🌐 方式二：手动在 GitHub 创建

### 步骤 1：创建仓库

访问 https://github.com/new

填写信息：
- **Repository name**: `glass-curtain-wall-repair`
- **Description**: 玻璃幕墙维修方案生成器 - Flutter跨平台应用
- **Visibility**: Public ✅
- **不要勾选** "Add a README file"

点击 **Create repository**

### 步骤 2：推送代码

创建仓库后，在页面下方会看到类似提示，执行：

```bash
# 确保在项目目录
cd c:\Users\longb\PycharmProjects\RiskForecast\glass_curtain_wall_repair

# 添加远程仓库
git remote add origin https://github.com/LongbowMax/glass-curtain-wall-repair.git

# 推送代码
git push -u origin master
```

### 步骤 3：输入认证信息

如果提示输入用户名和密码：
- **Username**: `LongbowMax`
- **Password**: 使用 GitHub Personal Access Token
  - 访问 https://github.com/settings/tokens
  - 点击 "Generate new token (classic)"
  - 勾选 `repo` 权限
  - 生成后复制作为密码输入

---

## 💻 方式三：使用 GitHub Desktop

1. 下载安装：https://desktop.github.com/
2. 登录账号 `LongbowMax`
3. 选择 **File** → **Add local repository**
4. 选择项目文件夹
5. 点击 **Publish repository**

---

## 🔧 方式四：使用 VS Code

1. 打开 VS Code
2. 安装 GitHub 扩展
3. 左侧源代码管理面板
4. 点击 "Publish to GitHub"
5. 按提示完成

---

## ✅ 验证推送成功

推送完成后访问：
```
https://github.com/LongbowMax/glass-curtain-wall-repair
```

应能看到所有 29 个文件。

---

## 🆘 常见问题

### Q: 提示 "repository not found"
A: 先在 GitHub 上创建仓库，或检查仓库名是否正确

### Q: 提示 "Permission denied"
A: 需要配置 GitHub Token 或 SSH 密钥

### Q: 提示 "failed to push some refs"
A: 执行 `git pull origin master` 后再推送

---

**推荐操作**: 直接运行 `.\deploy_to_github.ps1` 脚本，它会自动处理大部分问题！
