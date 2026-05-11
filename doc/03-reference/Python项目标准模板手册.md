# Python 项目标准模板手册

适用目标：

- 在 `WSL Ubuntu` 中快速创建一个规范的 Python 项目
- 使用 `pyenv + uv` 作为推荐工具链
- 适配本地开发、Git 管理、环境变量、Docker 中间件联调
- 让以后新项目可以直接套用

---

## 1. 推荐技术栈

推荐默认组合：

- Python 版本管理：`pyenv`
- 虚拟环境和依赖管理：`uv`
- 代码仓库：`Git`
- 编辑器：`VS Code Remote WSL`
- 数据库和缓存：`Docker + PostgreSQL + Redis`

如果你只是一般 Web 后端或脚本项目，这套已经够用。

---

## 2. 推荐目录结构

一个通用、干净、适合长期维护的结构如下：

```text
my-python-app
├─ src
│  └─ my_python_app
│     ├─ __init__.py
│     └─ main.py
├─ tests
│  └─ test_smoke.py
├─ .env
├─ .env.example
├─ .gitignore
├─ pyproject.toml
├─ README.md
└─ compose.yaml
```

说明：

- `src/`：项目源码
- `tests/`：测试文件
- `.env`：本机私密配置，不进 Git
- `.env.example`：配置模板，提交到 Git
- `pyproject.toml`：Python 项目核心配置
- `compose.yaml`：本地数据库或缓存

---

## 3. 新建项目的标准流程

在 Ubuntu 中执行：

```bash
cd ~/workspace
mkdir my-python-app && cd my-python-app
git init
mkdir -p src/my_python_app tests
touch src/my_python_app/__init__.py
touch src/my_python_app/main.py
touch tests/test_smoke.py
touch .env .env.example .gitignore README.md pyproject.toml
```

---

## 4. 推荐 `.gitignore`

建议内容：

```gitignore
.env
.venv/
__pycache__/
.pytest_cache/
.mypy_cache/
.ruff_cache/
dist/
build/
*.egg-info/
.coverage
htmlcov/
.idea/
.vscode/
*.log
```

作用：

- 不把私密配置、虚拟环境、缓存、构建结果提交进仓库

---

## 5. 初始化虚拟环境

在项目目录中执行：

```bash
uv venv
source .venv/bin/activate
python --version
```

正常情况下：

- `python` 会指向项目虚拟环境

建议以后进入项目后的第一件事就是：

```bash
source .venv/bin/activate
```

---

## 6. 推荐依赖安装方式

### 常见开发依赖

先装一个最小组合：

```bash
uv add python-dotenv
uv add --dev pytest ruff
```

如果你做 Web API，可以再加：

```bash
uv add fastapi uvicorn
```

如果你要连 PostgreSQL 和 Redis，可以再加：

```bash
uv add psycopg[binary] redis
```

---

## 7. 推荐 `pyproject.toml`

一个适合起步项目的示例：

```toml
[project]
name = "my-python-app"
version = "0.1.0"
description = "A standard Python project template"
readme = "README.md"
requires-python = ">=3.12"
dependencies = []

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
target-version = "py312"
```

说明：

- `project`：项目基础信息
- `pytest`：测试配置
- `ruff`：代码检查配置

---

## 8. 最小可运行代码示例

### `src/my_python_app/main.py`

```python
def main() -> None:
    print("Hello from my-python-app")


if __name__ == "__main__":
    main()
```

### 运行方式

```bash
python -m src.my_python_app.main
```

如果你更偏向包式运行，也可以改造结构，但这个起步最简单。

---

## 9. 最小测试示例

### `tests/test_smoke.py`

```python
def test_smoke() -> None:
    assert 1 + 1 == 2
```

运行测试：

```bash
pytest
```

---

## 10. 推荐 `.env.example`

如果项目需要数据库和缓存，可以这样写：

```env
APP_ENV=development
DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
```

说明：

- `.env.example` 提交到 Git
- `.env` 不提交到 Git

复制本地配置：

```bash
cp .env.example .env
```

---

## 11. 读取环境变量示例

### 安装依赖

```bash
uv add python-dotenv
```

### 示例代码

```python
import os
from dotenv import load_dotenv

load_dotenv()


def main() -> None:
    app_env = os.getenv("APP_ENV", "development")
    print(f"APP_ENV={app_env}")


if __name__ == "__main__":
    main()
```

---

## 12. 配合 Docker 的最小 `compose.yaml`

如果项目要用 PostgreSQL 和 Redis，可以直接放这一份：

```yaml
services:
  postgres:
    image: postgres:16
    container_name: my-python-app-postgres
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
    container_name: my-python-app-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

启动：

```bash
docker compose up -d
```

停止：

```bash
docker compose down
```

---

## 13. 常用开发命令

进入项目：

```bash
cd ~/workspace/my-python-app
source .venv/bin/activate
```

安装依赖：

```bash
uv add 包名
uv add --dev 包名
```

运行脚本：

```bash
python -m src.my_python_app.main
```

运行测试：

```bash
pytest
```

运行代码检查：

```bash
ruff check .
```

---

## 14. Git 的推荐流程

### 第一次提交

```bash
git add .
git commit -m "chore: init python project"
```

### 日常开发

```bash
git add .
git commit -m "feat: 完成某功能"
git push
```

重点：

- `.env` 不提交
- `.env.example` 要提交
- `README.md` 要写清项目启动方式

---

## 15. 推荐 README 内容

一个 Python 项目至少写清楚：

- 项目用途
- 如何创建虚拟环境
- 如何安装依赖
- 如何运行
- 如何测试
- 是否需要 Docker
- `.env` 如何配置

一个最小示例：

```md
## Setup

uv venv
source .venv/bin/activate
uv sync

## Run

python -m src.my_python_app.main

## Test

pytest

## Infra

docker compose up -d
```

---

## 16. 最适合你的项目起步命令

下面是一组可以直接照抄的最短起步命令。

```bash
cd ~/workspace
mkdir my-python-app && cd my-python-app
git init
mkdir -p src/my_python_app tests
touch src/my_python_app/__init__.py
cat > src/my_python_app/main.py <<'EOF'
def main() -> None:
    print("Hello from my-python-app")


if __name__ == "__main__":
    main()
EOF
cat > tests/test_smoke.py <<'EOF'
def test_smoke() -> None:
    assert 1 + 1 == 2
EOF
cat > .gitignore <<'EOF'
.env
.venv/
__pycache__/
.pytest_cache/
.mypy_cache/
.ruff_cache/
dist/
build/
*.egg-info/
.coverage
htmlcov/
.idea/
.vscode/
*.log
EOF
cat > .env.example <<'EOF'
APP_ENV=development
DATABASE_URL=postgresql://app:app123@127.0.0.1:5432/appdb
REDIS_URL=redis://127.0.0.1:6379/0
EOF
cp .env.example .env
cat > pyproject.toml <<'EOF'
[project]
name = "my-python-app"
version = "0.1.0"
description = "A standard Python project template"
readme = "README.md"
requires-python = ">=3.12"
dependencies = []

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
target-version = "py312"
EOF
uv venv
source .venv/bin/activate
uv add python-dotenv
uv add --dev pytest ruff
pytest
ruff check .
git add .
git commit -m "chore: init python project"
```

---

## 17. 常见问题

### 1. 进入项目后 `python` 不是虚拟环境的

说明：

- 你还没激活 `.venv`

执行：

```bash
source .venv/bin/activate
```

### 2. `uv` 命令找不到

执行：

```bash
source ~/.bashrc
source $HOME/.local/bin/env
```

### 3. 运行测试时报导入问题

优先检查：

- `pyproject.toml` 中 `pythonpath = ["src"]` 是否存在
- 运行测试时是否在项目根目录

### 4. `.env` 被误提交

解决：

- 先把 `.env` 加入 `.gitignore`
- 再从 Git 中移除追踪

```bash
git rm --cached .env
git commit -m "chore: stop tracking .env"
```

### 5. 数据库连不上

先检查：

```bash
docker compose ps
docker compose logs postgres
docker compose logs redis
```

---

## 18. 一句话记忆

- `项目放 ~/workspace`
- `先 uv venv`
- `再 source .venv/bin/activate`
- `依赖用 uv add`
- `.env 不提交`
- `.env.example 要提交`
- `Docker 只跑中间件`
