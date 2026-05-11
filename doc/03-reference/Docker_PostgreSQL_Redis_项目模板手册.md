# Docker + PostgreSQL + Redis 项目模板手册

适用目标：

- 在 `Windows + WSL Ubuntu` 开发环境中
- 用 `Docker` 跑 `PostgreSQL` 和 `Redis`
- 给新项目准备一套可直接复用的基础模板
- 避免把数据库和缓存直接安装到系统里

适用场景：

- Python 后端项目
- Node.js 后端项目
- 全栈项目本地联调
- 需要数据库和缓存，但不想污染本机系统

---

## 1. 总体思路

推荐做法：

- 代码在 `WSL Ubuntu` 中开发
- 数据库和缓存通过 `Docker Compose` 启动
- 项目目录统一放在 `~/workspace`
- 每个项目自带自己的 `compose.yaml` 和 `.env`

推荐结果：

- `PostgreSQL` 负责结构化数据
- `Redis` 负责缓存、会话、队列或临时数据
- 停项目时直接停容器
- 不需要时不让数据库常驻占资源

---

## 2. 前置条件

你应该已经具备：

- `WSL Ubuntu`
- `Docker Desktop`
- `Docker Desktop` 已启用 `WSL 2 based engine`
- `Docker Desktop` 已在 `WSL Integration` 中勾选你的 `Ubuntu`

在 Ubuntu 中先验证：

```bash
docker version
docker compose version
```

如果都能正常输出，说明 Docker 环境可用。

---

## 3. 推荐项目目录结构

建议结构：

```text
~/workspace
└─ my-app
   ├─ app
   ├─ compose.yaml
   ├─ .env
   ├─ .env.example
   └─ README.md
```

也可以更细分：

```text
~/workspace
└─ my-app
   ├─ backend
   ├─ frontend
   ├─ infra
   │  └─ compose.yaml
   ├─ .env
   └─ README.md
```

如果是单体项目，优先用第一种，最简单。

---

## 4. 最小可用 `compose.yaml`

这是最推荐的起步模板。

```yaml
services:
  postgres:
    image: postgres:16
    container_name: myapp-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app123
      POSTGRES_DB: appdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app -d appdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7
    container_name: myapp-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

说明：

- `postgres:16`：稳定常用版本
- `redis:7`：稳定常用版本
- `restart: unless-stopped`：重启 Docker 后容器会恢复，但你也可以手动停掉
- `healthcheck`：便于判断容器是否真的可用
- `volumes`：保证容器删了，数据也不会马上丢

---

## 5. 推荐 `.env.example`

建议每个项目都带一份示例配置。

```env
APP_ENV=development

POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
POSTGRES_DB=appdb
POSTGRES_USER=app
POSTGRES_PASSWORD=app123

REDIS_HOST=127.0.0.1
REDIS_PORT=6379

DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
```

建议：

- 项目里提交 `.env.example`
- 本机使用 `.env`
- 不要把真实 `.env` 提交到 Git

---

## 6. 首次创建项目模板

在 Ubuntu 中执行：

```bash
cd ~/workspace
mkdir my-app && cd my-app
mkdir app
touch compose.yaml .env .env.example README.md
```

然后：

- 把模板 `compose.yaml` 内容复制进去
- 把 `.env.example` 内容复制进去
- 再执行：

```bash
cp .env.example .env
```

---

## 7. 启动与停止命令

### 1. 启动容器

在项目目录中执行：

```bash
docker compose up -d
```

说明：

- `up -d` 表示后台启动
- 第一次会自动拉镜像，可能稍慢

### 2. 查看运行状态

```bash
docker compose ps
```

如果健康检查通过，状态通常会是：

- `running`
- `healthy`

### 3. 查看日志

查看全部日志：

```bash
docker compose logs
```

查看 PostgreSQL 日志：

```bash
docker compose logs postgres
```

查看 Redis 日志：

```bash
docker compose logs redis
```

持续跟踪日志：

```bash
docker compose logs -f
```

### 4. 停止容器

```bash
docker compose down
```

说明：

- 停止并删除容器
- 但不会删除卷数据

### 5. 停止并删除数据

如果你想完全重置数据库和缓存：

```bash
docker compose down -v
```

注意：

- 这会删除卷
- `PostgreSQL` 和 `Redis` 数据都会清空

---

## 8. 常用连接信息

如果你的应用运行在本机开发环境中，一般直接连：

### PostgreSQL

- Host: `127.0.0.1`
- Port: `5432`
- Database: `appdb`
- User: `app`
- Password: `app123`

连接串：

```text
postgresql://app:app123@127.0.0.1:5432/appdb
```

### Redis

- Host: `127.0.0.1`
- Port: `6379`

连接串：

```text
redis://127.0.0.1:6379/0
```

---

## 9. 在 Python 项目中的使用示例

### 1. 安装依赖

如果你使用 `uv`：

```bash
uv add psycopg[binary] redis python-dotenv
```

### 2. 示例 `.env`

```env
DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
```

### 3. PostgreSQL 测试代码

```python
import os
from dotenv import load_dotenv
import psycopg

load_dotenv()

database_url = os.getenv("DATABASE_URL")

with psycopg.connect(database_url) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT version();")
        print(cur.fetchone())
```

### 4. Redis 测试代码

```python
import os
from dotenv import load_dotenv
import redis

load_dotenv()

redis_client = redis.from_url(os.getenv("REDIS_URL"))
redis_client.set("hello", "world")
print(redis_client.get("hello"))
```

---

## 10. 在 Node.js 项目中的使用示例

### 1. 安装依赖

```bash
pnpm add pg redis dotenv
```

### 2. 示例 `.env`

```env
DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
```

### 3. PostgreSQL 测试代码

```javascript
import 'dotenv/config';
import pg from 'pg';

const { Client } = pg;

const client = new Client({
  connectionString: process.env.DATABASE_URL,
});

await client.connect();
const res = await client.query('SELECT NOW()');
console.log(res.rows[0]);
await client.end();
```

### 4. Redis 测试代码

```javascript
import 'dotenv/config';
import { createClient } from 'redis';

const client = createClient({
  url: process.env.REDIS_URL,
});

await client.connect();
await client.set('hello', 'world');
console.log(await client.get('hello'));
await client.quit();
```

---

## 11. 推荐的 README 写法

建议在项目 `README.md` 中写清楚下面几项：

- 项目依赖哪些服务
- 如何启动 Docker
- 数据库连接信息
- 首次启动命令
- 如何重置数据

一个最小示例：

```md
## Local Infra

启动：

docker compose up -d

查看状态：

docker compose ps

停止：

docker compose down

彻底重置：

docker compose down -v
```

---

## 12. 最常用操作清单

进入项目：

```bash
cd ~/workspace/my-app
```

启动基础设施：

```bash
docker compose up -d
```

查看状态：

```bash
docker compose ps
```

查看日志：

```bash
docker compose logs -f
```

关闭：

```bash
docker compose down
```

完全清空数据：

```bash
docker compose down -v
```

---

## 13. 常见问题

### 1. `docker: command not found`

说明：

- Docker Desktop 没装好
- 或没有启用 WSL 集成

检查：

- Windows 是否安装 `Docker Desktop`
- `Settings -> General` 是否启用 `WSL 2 based engine`
- `Settings -> Resources -> WSL Integration` 是否勾选 `Ubuntu`

### 2. `5432` 或 `6379` 端口被占用

现象：

- 启动时报端口冲突

解决：

- 停掉占用这些端口的程序
- 或修改 `compose.yaml` 中左侧映射端口

例如改成：

```yaml
ports:
  - "5433:5432"
```

这时连接串也要改成：

```text
postgresql://app:app123@127.0.0.1:5433/appdb
```

### 3. PostgreSQL 账号密码改了但不生效

说明：

- 旧数据卷还在
- `POSTGRES_*` 环境变量只在数据库初始化时生效

解决：

```bash
docker compose down -v
docker compose up -d
```

注意：

- 这样会清空数据库数据

### 4. 容器启动了但应用连不上

先检查：

```bash
docker compose ps
docker compose logs postgres
docker compose logs redis
```

再确认：

- Host 是否写成了 `127.0.0.1`
- 端口是否和映射一致
- 应用是否读取了正确的 `.env`

### 5. WSL 里启动很慢

常见原因：

- Docker Desktop 没完全启动
- 机器内存不够
- 同时开了太多浏览器标签和 IDE

建议：

- Docker 按需开
- 同时只保留当前项目需要的容器
- 配好 `.wslconfig`

---

## 14. 一个更适合真实项目的增强版 `compose.yaml`

如果你想让配置更整洁，可以把环境变量从文件里读取。

```yaml
services:
  postgres:
    image: postgres:16
    container_name: myapp-postgres
    restart: unless-stopped
    env_file:
      - .env
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7
    container_name: myapp-redis
    restart: unless-stopped
    ports:
      - "${REDIS_PORT}:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

对应 `.env` 示例：

```env
POSTGRES_PORT=5432
POSTGRES_DB=appdb
POSTGRES_USER=app
POSTGRES_PASSWORD=app123

REDIS_PORT=6379

DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
```

---

## 15. 推荐使用原则

长期使用时，建议遵守这些规则：

- 一个项目一份 `compose.yaml`
- 一个项目一份 `.env`
- 项目停了就 `docker compose down`
- 不在 Windows 里直接安装数据库
- 不长期挂很多无关容器
- 需要清库时优先确认是否真的要 `down -v`

---

## 16. 最短模板复现流程

下次新项目可以直接按这个流程走。

### 1. 创建目录

```bash
cd ~/workspace
mkdir my-app && cd my-app
touch compose.yaml .env .env.example
```

### 2. 写入 `compose.yaml`

```yaml
services:
  postgres:
    image: postgres:16
    container_name: myapp-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app123
      POSTGRES_DB: appdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    container_name: myapp-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### 3. 写入 `.env.example`

```env
DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
```

### 4. 复制本地配置

```bash
cp .env.example .env
```

### 5. 启动

```bash
docker compose up -d
docker compose ps
```

---

## 17. 一句话记忆

- `代码在 WSL`
- `数据库走 Docker`
- `一项目一 compose`
- `一项目一 .env`
- `用完就 down`
