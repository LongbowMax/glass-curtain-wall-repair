# 部署到 GitHub 指南

## ✅ 已完成步骤

- [x] 初始化 Git 仓库
- [x] 添加所有文件 (29个文件)
- [x] 提交代码 (6143行)

## 📋 接下来需要在 GitHub 上完成的步骤

### 步骤 1: 创建 GitHub 仓库

1. 打开浏览器访问: https://github.com/new
2. 填写仓库信息:
   - **Repository name**: `glass-curtain-wall-repair` (或其他你喜欢的名称)
   - **Description**: 玻璃幕墙维修方案生成器 - Flutter跨平台应用
   - **Visibility**: 选择 Public（公开）或 Private（私有）
   - **不要勾选** "Initialize this repository with a README"（因为我们已经有README了）
3. 点击 **Create repository**

### 步骤 2: 推送代码到 GitHub

创建仓库后，GitHub会显示类似下面的命令，你可以在终端中运行：

```bash
# 进入项目目录
cd c:\Users\longb\PycharmProjects\RiskForecast\glass_curtain_wall_repair

# 添加远程仓库（将 YOUR_USERNAME 替换为你的GitHub用户名）
git remote add origin https://github.com/YOUR_USERNAME/glass-curtain-wall-repair.git

# 推送代码
git push -u origin master
```

或者，如果你使用 SSH 密钥：

```bash
git remote add origin git@github.com:YOUR_USERNAME/glass-curtain-wall-repair.git
git push -u origin master
```

### 步骤 3: 验证推送

推送成功后，访问以下链接查看你的仓库：
```
https://github.com/YOUR_USERNAME/glass-curtain-wall-repair
```

---

## 🔧 备用方法：使用 GitHub Desktop

如果你不习惯命令行，可以使用 GitHub Desktop：

1. 下载安装 GitHub Desktop: https://desktop.github.com/
2. 登录你的 GitHub 账号
3. 选择 "Add Existing Repository"
4. 选择项目文件夹: `c:\Users\longb\PycharmProjects\RiskForecast\glass_curtain_wall_repair`
5. 点击 "Publish repository"

---

## 📦 项目信息

| 项目 | 内容 |
|------|------|
| 文件数量 | 29个 |
| 代码行数 | 6143行 |
| 主要语言 | Dart (Flutter) |
| 平台支持 | Android, iOS |

---

## ❓ 常见问题

### Q: 提示 "Permission denied" 怎么办？
A: 需要配置 GitHub 认证：
- HTTPS: 使用个人访问令牌 (https://github.com/settings/tokens)
- SSH: 配置 SSH 密钥 (https://github.com/settings/keys)

### Q: 推送时提示 "rejected"？
A: 可能是远程仓库有冲突，执行：
```bash
git pull origin master --rebase
git push origin master
```

### Q: 如何更改远程仓库地址？
```bash
git remote set-url origin https://github.com/新用户名/新仓库名.git
```

---

完成推送后，你的项目就成功部署到 GitHub 了！🎉
