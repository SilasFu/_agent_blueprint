# 防止重装丢代码与 Git 远程同步手册

适用目标：

- 解决“重装电脑后代码会不会丢”的问题
- 建立一套长期可靠的代码备份方案
- 学会把本地项目同步到 `GitHub`、`Gitee` 或其他 Git 远程仓库
- 区分哪些东西必须备份，哪些东西不需要备份

---

## 1. 先说结论

如果你的代码只放在本机，那么：

- 重装系统可能会丢
- 硬盘损坏可能会丢
- WSL 损坏可能会丢
- 误删也可能会丢

真正安全的方案不是“把代码放在哪”，而是：

- `代码进 Git`
- `仓库推送到远程`
- `重要数据单独备份`

一句话记忆：

- `本机是工作区`
- `远程仓库是主备份`

---

## 2. 哪些东西必须备份

必须重点保护的内容：

- 项目源码
- 文档
- 脚本
- `Docker Compose` 配置
- 数据库迁移文件
- 项目说明
- `.env.example`
- 部署说明

一般不需要备份的内容：

- `node_modules`
- `.venv`
- Python 和 Node 安装本体
- Docker 镜像
- Docker 容器
- 各类缓存目录
- 编译产物

建议原则：

- 能通过命令重新安装的，通常不必备份
- 自己写的内容，必须备份

---

## 3. 你真正要防的是什么

很多人以为“代码在 WSL 里就安全”，其实不是。

你要防的主要是这几类情况：

- Windows 重装导致本地文件被清空
- WSL 发行版损坏
- 硬盘损坏
- 误删项目目录
- Docker 卷误删
- 本地环境配置丢失

所以安全方案通常分三层：

- `代码备份`
- `配置备份`
- `数据备份`

---

## 4. 最推荐的整体方案

最推荐的长期方案：

1. 代码放在 `WSL ~/workspace`
2. 代码用 `Git` 管理
3. 远程推送到 `GitHub`、`GitLab`、`Gitee` 或私有仓库
4. 重要配置用 `.env.example` 和文档保存结构
5. 真正的 `.env`、密钥、密码单独保管
6. 数据库定期导出
7. 必要时导出 WSL 发行版

这套方案的优点：

- 重装系统后可以快速恢复
- 换电脑时迁移成本低
- 本机坏了也不至于全丢

---

## 5. 最适合个人开发者的备份模型

建议你长期使用下面这个模型。

### 第 1 层：Git 远程仓库

这是最重要的一层。

适合保存：

- 源码
- 文档
- 脚本
- 配置模板

推荐平台：

- `GitHub`
- `Gitee`
- `GitLab`

### 第 2 层：本地导出型备份

适合保存：

- 数据库导出文件
- 重要证书
- SSH 密钥备份
- 一些不方便直接公开放进 Git 的文件

建议放在：

- 外接硬盘
- NAS
- 加密云盘

### 第 3 层：环境恢复文档

适合保存：

- 环境搭建教程
- 常用命令
- 项目启动步骤

你现在已经有了这类文档，这很好。

---

## 6. 为什么 Git 远程仓库这么重要

因为它解决的是“代码本体”的生存问题。

只要你满足这三件事：

- 已初始化 Git
- 已提交 commit
- 已 push 到远程

那么即使你换电脑、重装系统，也只需要：

```bash
git clone 仓库地址
```

然后重新装环境即可。

如果你只是：

- `git init`
- 但没提交
- 或提交了但没 push

那本地丢了还是会出问题。

所以真正安全的是：

- `commit`
- `push`

两步都做。

---

## 7. 新项目的标准做法

每次新项目都按这个流程来。

### 1. 创建项目目录

```bash
cd ~/workspace
mkdir my-project
cd my-project
```

### 2. 初始化 Git

```bash
git init
```

### 3. 创建 `.gitignore`

一个通用示例：

```gitignore
.env
.venv/
node_modules/
dist/
build/
__pycache__/
.pytest_cache/
.idea/
.vscode/
*.log
```

### 4. 第一次提交

```bash
git add .
git commit -m "chore: init project"
```

### 5. 关联远程仓库并推送

```bash
git remote add origin 你的仓库地址
git branch -M main
git push -u origin main
```

---

## 8. 从零开始创建远程仓库

这里以 `GitHub` 和 `Gitee` 为例。

### 方案 A：GitHub

#### 1. 注册账号

访问：

- [GitHub](https://github.com/)

#### 2. 创建仓库

创建时建议：

- Repository name：项目名
- 先不要勾选自动生成 README
- 先不要勾选 `.gitignore`
- 先不要勾选 License

原因：

- 这样最适合你从本地已有项目推上去

#### 3. 创建完成后得到仓库地址

通常类似：

```text
https://github.com/你的用户名/你的项目.git
```

或：

```text
git@github.com:你的用户名/你的项目.git
```

### 方案 B：Gitee

访问：

- [Gitee](https://gitee.com/)

创建仓库逻辑和 GitHub 类似。

仓库地址通常类似：

```text
https://gitee.com/你的用户名/你的项目.git
```

---

## 9. HTTPS 还是 SSH

你连接远程仓库主要有两种方式。

### 1. HTTPS

示例：

```text
https://github.com/username/project.git
```

优点：

- 上手简单
- 不需要先配 SSH 密钥

缺点：

- 有些平台推送时会要求令牌
- 某些情况下不如 SSH 顺手

### 2. SSH

示例：

```text
git@github.com:username/project.git
```

优点：

- 日常推送更方便
- 适合长期开发

缺点：

- 需要先生成 SSH 密钥并绑定平台

推荐：

- 新手先用 `HTTPS`
- 以后稳定了再切到 `SSH`

---

## 10. 用 HTTPS 推送项目

本地项目中执行：

```bash
git init
git add .
git commit -m "chore: init project"
git remote add origin https://github.com/你的用户名/你的项目.git
git branch -M main
git push -u origin main
```

如果平台要求认证：

- GitHub 通常使用 `Personal Access Token`
- Gitee 可用账号密码或令牌，视平台政策而定

---

## 11. 用 SSH 推送项目

### 1. 生成 SSH 密钥

在 Ubuntu 中执行：

```bash
ssh-keygen -t ed25519 -C "你的邮箱"
```

一路回车即可。

生成后，公钥通常在：

```text
~/.ssh/id_ed25519.pub
```

### 2. 查看公钥内容

```bash
cat ~/.ssh/id_ed25519.pub
```

复制整段内容。

### 3. 添加到 GitHub 或 Gitee

在平台里找到：

- `SSH Keys`
- `Deploy Keys`
- 或 `SSH 公钥管理`

把刚才复制的公钥粘贴进去。

### 4. 测试 SSH 连接

GitHub：

```bash
ssh -T git@github.com
```

Gitee：

```bash
ssh -T git@gitee.com
```

### 5. 使用 SSH 地址推送

```bash
git remote add origin git@github.com:你的用户名/你的项目.git
git branch -M main
git push -u origin main
```

---

## 12. 每天应该怎么做

最推荐的日常习惯：

### 写完一个小功能

```bash
git add .
git commit -m "feat: 完成某功能"
git push
```

### 改完一个 bug

```bash
git add .
git commit -m "fix: 修复某问题"
git push
```

### 改完文档或脚本

```bash
git add .
git commit -m "docs: 更新说明"
git push
```

重点不是 commit 多么优雅，而是：

- 不要长期只改本地不 push

---

## 13. 下次重装电脑后怎么恢复

如果你已经把项目 push 到远程，那么恢复流程很简单。

### 1. 先重建开发环境

按你现有的环境手册重新安装：

- `WSL Ubuntu`
- `Python`
- `Node.js`
- `pnpm`
- `Docker`

### 2. 重新拉代码

在 Ubuntu 中执行：

```bash
cd ~/workspace
git clone 你的仓库地址
cd 你的项目目录
```

### 3. 重新装依赖

Python 项目：

```bash
uv venv
source .venv/bin/activate
uv sync
```

Node 项目：

```bash
pnpm install
```

### 4. 如有 Docker 基础设施，重新启动

```bash
docker compose up -d
```

### 5. 补回本地私密配置

例如：

- `.env`
- API Key
- 数据库密码
- SSH 私钥

这部分不能只靠代码仓库，需要你自己备份。

---

## 14. `.env` 应该怎么处理

这是最常见的坑之一。

正确做法：

- 提交 `.env.example`
- 忽略 `.env`

例如：

`.env.example`

```env
DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
OPENAI_API_KEY=your-key-here
```

`.gitignore`

```gitignore
.env
```

这样做的好处：

- 重装后知道需要哪些变量
- 不会把真实密钥传到远程仓库

---

## 15. 数据库为什么不能只靠 Docker 卷

因为 Docker 卷适合本地开发，但它不是长期主备份方案。

你不能指望：

- 重装系统后 Docker 卷还在
- 误删卷后还能自动恢复

真正重要的数据，应该定期导出。

---

## 16. PostgreSQL 备份与恢复

### 1. 导出数据库

如果 PostgreSQL 跑在 Docker 中，可以执行：

```bash
docker exec -t myapp-postgres pg_dump -U app -d appdb > backup_appdb.sql
```

这会在当前目录生成：

- `backup_appdb.sql`

### 2. 恢复数据库

先确保数据库容器已启动，然后执行：

```bash
cat backup_appdb.sql | docker exec -i myapp-postgres psql -U app -d appdb
```

### 3. 建议

- 小项目至少一周导出一次
- 重要项目在大改前导出一次

---

## 17. Redis 备份怎么理解

Redis 常用于：

- 缓存
- 会话
- 临时数据
- 队列状态

如果你的 Redis 只是缓存，通常不需要重点备份。

如果你把重要业务状态也放进 Redis，就要谨慎：

- 考虑业务上能否重新生成
- 考虑是否要额外导出

多数本地开发场景里：

- Redis 丢了问题不大
- PostgreSQL 更重要

---

## 18. 重要但不该进 Git 的东西

这些内容通常不应该直接进仓库：

- `.env`
- 私钥
- SSH 私钥
- 平台令牌
- 生产环境配置
- 真实数据库账号密码

推荐保存方式：

- 密码管理器
- 加密笔记
- 加密 U 盘
- 可信云盘中的加密文件

---

## 19. 还可以做的环境级备份

如果你希望连 WSL 环境都一起备份，可以导出发行版。

### 导出 WSL

在 Windows `PowerShell` 中执行：

```powershell
wsl --export Ubuntu D:\backup\ubuntu.tar
```

### 导入 WSL

重装后可导入：

```powershell
wsl --import Ubuntu D:\WSL\Ubuntu D:\backup\ubuntu.tar
```

注意：

- 这是环境级备份
- 不能代替 Git 远程仓库
- 更适合做辅助恢复

---

## 20. 一套最实用的长期习惯

建议你长期执行下面这些习惯。

### 每个新项目

- 立刻 `git init`
- 立刻创建远程仓库
- 第一天就完成第一次 `push`

### 每天开发

- 完成一个阶段就 `commit`
- 一天结束前至少 `push` 一次

### 每个项目

- 保留 `.env.example`
- 写清楚 `README`
- 把启动步骤文档化

### 每周或每个关键节点

- 导出一次数据库
- 检查代码是否都已 push

---

## 21. 最常见错误

### 1. 只在本地写代码，从不 push

这是最大风险。

### 2. 以为代码在 WSL 就绝对安全

不是，WSL 也只是本机环境。

### 3. 把 `.env` 和密钥提交到仓库

这是安全风险。

### 4. 只备份环境，不备份代码

环境可以重建，代码更重要。

### 5. 只备份代码，不备份数据库

如果数据库里有重要数据，这样仍然不完整。

---

## 22. 适合你的最小方案

如果你现在不想搞得太复杂，最少只做下面 4 件事：

1. 项目全部用 Git 管理
2. 仓库全部 push 到 GitHub 或 Gitee
3. `.env` 不进仓库，但保留 `.env.example`
4. PostgreSQL 定期导出 SQL

只要做到这 4 条，你就已经比大多数“只放本地”的情况安全很多。

---

## 23. 一份最短执行清单

### 新项目初始化

```bash
cd ~/workspace
mkdir my-project && cd my-project
git init
touch .gitignore README.md .env.example
git add .
git commit -m "chore: init project"
git remote add origin 你的仓库地址
git branch -M main
git push -u origin main
```

### 日常同步

```bash
git add .
git commit -m "feat: update"
git push
```

### PostgreSQL 导出

```bash
docker exec -t myapp-postgres pg_dump -U app -d appdb > backup_appdb.sql
```

### 换电脑恢复

```bash
cd ~/workspace
git clone 你的仓库地址
```

---

## 24. 一句话记忆

- `代码靠 Git 远程仓库`
- `配置靠文档和 .env.example`
- `密钥单独保管`
- `数据库单独导出`
- `WSL 可以重建，不要把它当唯一备份`
