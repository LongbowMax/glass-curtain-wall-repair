# 一键推送到 GitHub

## 🚀 自动推送脚本

我已为你准备好两个推送脚本，选择一种方式运行：

---

## 方式一：双击运行批处理（推荐）

1. **确保已在GitHub创建仓库**
   - 访问 https://github.com/new
   - 仓库名：`glass-curtain-wall-repair`
   - **不要勾选** "Add a README file"
   - 点击 Create repository

2. **双击运行** `push_to_github.bat`

3. **如果提示输入密码**：
   - 用户名：`LongbowMax`
   - 密码：使用 GitHub Token（获取方式见下方）

---

## 方式二：使用 Token 文件（无需交互）

### 步骤 1：获取 GitHub Token

1. 访问 https://github.com/settings/tokens
2. 点击 **"Generate new token (classic)"**
3. 勾选权限：**`repo`**（完整控制仓库）
4. 点击 **Generate token**
5. **复制**生成的Token（只显示一次！）

### 步骤 2：创建 Token 文件

在项目目录下创建文件 `.github_token`，将Token粘贴进去：

```
c:\Users\longb\PycharmProjects\RiskForecast\glass_curtain_wall_repair\.github_token
```

### 步骤 3：运行推送脚本

```bash
cd c:\Users\longb\PycharmProjects\RiskForecast\glass_curtain_wall_repair
.\push_to_github.bat
```

---

## 方式三：手动命令行

```bash
# 1. 进入项目目录
cd c:\Users\longb\PycharmProjects\RiskForecast\glass_curtain_wall_repair

# 2. 配置远程仓库
git remote add origin https://github.com/LongbowMax/glass-curtain-wall-repair.git

# 3. 推送代码
git push -u origin master

# 4. 输入认证信息
# 用户名: LongbowMax
# 密码: [你的GitHub Token]
```

---

## ✅ 推送成功后

访问你的仓库：
```
https://github.com/LongbowMax/glass-curtain-wall-repair
```

应该能看到所有 32 个文件。

---

## 🆘 常见问题

### Q: 提示 "repository not found"
A: 先在GitHub上创建仓库：https://github.com/new

### Q: 提示 "403 Forbidden" 或 "Authentication failed"
A: 需要使用Token而不是密码。访问 https://github.com/settings/tokens 生成Token

### Q: 提示 "failed to push some refs"
A: 可能是网络问题，重试即可

---

**最简单的方法**：
1. 访问 https://github.com/settings/tokens 生成Token
2. 创建 `.github_token` 文件，写入Token
3. 双击 `push_to_github.bat`
