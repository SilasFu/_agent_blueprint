# Windows + WSL Ubuntu 开发环境完整教材

适用场景：
- 你在 `Windows` 上做开发
- 希望尽量不污染原系统
- 希望适配 `Python`、`Node.js`、`pnpm`、`git`、AI agent 工具
- 希望下次换一台电脑也能照着一步步完成配置

本文目标：
- 用最稳的方式搭建 `Windows + WSL2 + Ubuntu`
- 把开发环境尽量放到 `WSL Ubuntu` 中
- 让 `Windows` 只做宿主机，减少系统污染和性能影响
- 总结一次完整安装流程和常见坑

---

## 一、推荐架构

最推荐的开发架构：

- `Windows`：只保留桌面软件、浏览器、IDE、终端
- `WSL2 + Ubuntu`：放开发工具链
- `Docker`：按需运行数据库、Redis、消息队列等中间件
- `项目目录`：统一放在 `WSL` 的 Linux 文件系统中

核心原则：

- 不在 Windows 本机混装很多语言运行时
- 不把数据库直接安装成 Windows 常驻服务
- 每个项目独立依赖环境
- 项目代码优先放在 `~/workspace`

推荐结果：

- Python 在 `WSL Ubuntu` 中使用 `pyenv + uv`
- Node.js 在 `WSL Ubuntu` 中使用 `nvm + Node LTS + pnpm`
- Git 在 `WSL Ubuntu` 中使用 Linux 的 `git`

---

## 二、环境层次说明

搭建完成后，你会同时接触两种终端环境。

### 1. Windows 终端

提示符通常类似：

```powershell
PS C:\Users\你的用户名>
```

这个环境里主要做：

- 安装 WSL
- 管理 Windows 配置
- 编辑 `.wslconfig`
- 启动 Ubuntu

### 2. Ubuntu 终端

提示符通常类似：

```bash
fugui@DESKTOP-XXXX:~$
```

这个环境里主要做：

- 安装 Python、Node.js、pnpm、git
- 创建项目
- 运行开发命令
- 使用 AI agent CLI 工具

重要结论：

- 看到 `PS C:\...>`，说明你还在 Windows
- 看到 `用户名@主机名:~$`，说明你已经进入 Ubuntu
- 大多数开发命令，都应该在 Ubuntu 里执行

---

## 三、安装前准备

### 1. Windows 建议安装的软件

建议安装：

- `Windows Terminal`
- `VS Code`
- `Docker Desktop`，按需安装，不急

不建议先装：

- Windows 本机全局 `Python`
- Windows 本机全局 `Node.js`
- Windows 本机的 `MySQL`、`Redis`、`PostgreSQL`

### 2. 检查 Windows 虚拟化支持

用管理员 `PowerShell` 执行：

```powershell
systeminfo | findstr /i "Hyper-V"
```

如果看到：

- `虚拟机监视器模式扩展: 是`

通常说明虚拟化能力具备。

如果 WSL 安装失败，有可能是 BIOS/UEFI 中没开虚拟化，需要开启：

- `SVM Mode`
- `Virtualization`
- `AMD-V`
- `Intel VT-x`

---

## 四、安装 WSL2 和 Ubuntu

### 1. 安装 WSL 和 Ubuntu

以管理员身份打开 `PowerShell`，执行：

```powershell
wsl --install -d Ubuntu
```

说明：

- 这条命令会安装 `WSL`
- 同时下载并安装 `Ubuntu`

安装完成后，通常需要重启电脑。

### 2. 检查 WSL 状态

重启后，在 `PowerShell` 执行：

```powershell
wsl --status
wsl -l -v
```

正常情况下你会看到类似：

```text
NAME      STATE           VERSION
Ubuntu    Stopped         2
```

说明：

- `Ubuntu` 已安装
- 版本是 `2`，即 `WSL2`

### 3. 启动 Ubuntu

如果开始菜单里暂时搜不到 `Ubuntu`，不要慌，直接用命令启动：

```powershell
wsl -d Ubuntu
```

---

## 五、首次进入 Ubuntu 的正确操作

第一次启动 `Ubuntu` 时，系统会提示：

```text
Create a default Unix user account:
```

这时你需要：

1. 输入一个 Linux 用户名
2. 输入一个 Linux 密码
3. 再输入一次确认密码

建议：

- 用户名只用小写字母和数字
- 密码自己记住即可

注意：

- 输入密码时，屏幕上不会显示字符
- 不会显示 `*`
- 这是正常现象

如果成功，终端会变成类似：

```bash
fugui@HW-936:~$
```

这说明：

- Ubuntu 已经初始化完成
- 你已经真正进入 Linux 环境

---

## 六、初始化 Ubuntu

进入 Ubuntu 后，先更新系统并安装基础工具。

### 1. 更新系统

在 Ubuntu 中执行：

```bash
sudo apt update && sudo apt upgrade -y
```

说明：

- `sudo` 会要求你输入刚才设置的 Linux 密码
- 输入密码时不会显示字符，正常输入后回车即可

### 2. 安装基础工具

继续执行：

```bash
sudo apt install -y build-essential curl wget git unzip zip ca-certificates pkg-config software-properties-common
```

这会安装：

- `build-essential`：编译环境
- `curl`、`wget`：下载工具
- `git`：版本管理
- `unzip`、`zip`：压缩解压
- `ca-certificates`：HTTPS 证书支持

### 3. 创建统一工作目录

执行：

```bash
mkdir -p ~/workspace
cd ~/workspace
pwd
```

正常输出类似：

```bash
/home/你的用户名/workspace
```

以后所有项目都建议放在这里，比如：

- `~/workspace/project-a`
- `~/workspace/project-b`

不要长期把项目放在 `/mnt/c/...` 下开发。

---

## 七、安装 Python 开发环境

推荐方案：

- `pyenv`：管理 Python 版本
- `uv`：创建虚拟环境和管理依赖

### 1. 安装 Python 编译依赖

执行：

```bash
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

### 2. 安装 pyenv

执行：

```bash
curl https://pyenv.run | bash
```

### 3. 配置 pyenv 到 `~/.bashrc`

执行：

```bash
cat >> ~/.bashrc <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
EOF
```

然后执行：

```bash
source ~/.bashrc
```

检查是否成功：

```bash
pyenv --version
```

正常会看到类似：

```bash
pyenv 2.x.x
```

### 4. 安装指定版本 Python

执行：

```bash
pyenv install 3.12.9
pyenv global 3.12.9
pyenv rehash
```

然后检查：

```bash
python --version
which python
```

正常输出类似：

```bash
Python 3.12.9
/home/你的用户名/.pyenv/shims/python
```

### 5. 安装 uv

执行：

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

让当前 shell 立刻生效：

```bash
source ~/.bashrc
source $HOME/.local/bin/env
```

检查：

```bash
uv --version
which uv
```

正常输出类似：

```bash
uv 0.x.x
/home/你的用户名/.local/bin/uv
```

### 6. 新建一个 Python 项目

执行：

```bash
cd ~/workspace
mkdir demo-py && cd demo-py
uv venv
source .venv/bin/activate
uv add fastapi
python --version
```

说明：

- `uv venv`：创建虚拟环境
- `source .venv/bin/activate`：激活虚拟环境
- `uv add fastapi`：安装依赖

---

## 八、安装 Node.js 开发环境

推荐方案：

- `nvm`：管理 Node.js 版本
- `Node LTS`：稳定版
- `pnpm`：包管理器

### 1. 安装 nvm

执行：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

然后执行：

```bash
source ~/.bashrc
```

检查：

```bash
nvm --version
```

### 2. 安装 Node LTS

执行：

```bash
nvm install --lts
nvm use --lts
```

检查：

```bash
node -v
npm -v
```

### 3. 安装 pnpm

执行：

```bash
corepack enable
corepack prepare pnpm@latest --activate
pnpm -v
```

### 4. 新建一个 Node 项目

执行：

```bash
cd ~/workspace
mkdir demo-node && cd demo-node
pnpm init
node -v
pnpm -v
```

---

## 九、VS Code 连接 WSL

推荐方式：

- Windows 上安装 `VS Code`
- 安装扩展：`Remote - WSL`

### 1. 从 Ubuntu 打开项目

在 Ubuntu 项目目录中执行：

```bash
code .
```

如果第一次还不能用 `code` 命令：

- 先确认你已经安装 `VS Code`
- 再安装 `Remote - WSL`

### 2. 推荐扩展

建议安装：

- `Remote - WSL`
- `Python`
- `ESLint`
- `Prettier`
- `Docker`

---

## 十、给 WSL 限制资源

这一步非常重要，可以避免 `WSL` 抢太多资源，拖慢 Windows。

### 1. 创建 `.wslconfig`

在 Windows `PowerShell` 执行：

```powershell
notepad $env:USERPROFILE\.wslconfig
```

填入以下内容：

```ini
[wsl2]
memory=4GB
processors=3
swap=1GB
localhostForwarding=true
```

### 2. 让配置生效

保存后执行：

```powershell
wsl --shutdown
```

重新打开 Ubuntu 即可。

### 3. 推荐配置参考

#### 8GB 内存机器

```ini
[wsl2]
memory=3GB
processors=2
swap=1GB
localhostForwarding=true
```

#### 16GB 内存机器

```ini
[wsl2]
memory=4GB
processors=3
swap=1GB
localhostForwarding=true
```

#### 32GB 及以上机器

```ini
[wsl2]
memory=6GB
processors=4
swap=2GB
localhostForwarding=true
```

---

## 十一、Docker 的正确使用方式

如果你要跑数据库、中间件，建议安装：

- `Docker Desktop`

但原则是：

- 按需启动
- 不要常驻一堆容器
- 不要把数据库直接装进 Windows

### 1. Docker 适合跑什么

适合：

- `PostgreSQL`
- `MySQL`
- `Redis`
- `MinIO`
- `RabbitMQ`

### 2. 安装后需要确认

在 Docker Desktop 中确认：

- 启用 `Use the WSL 2 based engine`
- 在 `WSL Integration` 中勾选 `Ubuntu`

### 3. 验证 Docker

在 Ubuntu 执行：

```bash
docker version
docker compose version
```

---

## 十二、推荐目录结构

建议统一使用：

```text
~/workspace
├─ python
├─ node
├─ fullstack
└─ playground
```

也可以简化为：

```text
~/workspace
├─ project-a
├─ project-b
└─ project-c
```

原则：

- 所有项目放在 `WSL` 内
- 不要长期把开发目录放在 `C:\...`

---

## 十三、日常开发流程建议

推荐日常流程：

1. 打开 `Ubuntu`
2. 进入项目目录
3. 在项目目录执行 `code .`
4. 在 Ubuntu 终端里运行 `git`、`python`、`node`、`pnpm`
5. 需要数据库时再启动 Docker

适合长期保持流畅的习惯：

- 不长期后台运行 Docker
- 不同时开太多大型 Electron 应用
- 不在 Windows 和 Ubuntu 两边各装一套相同开发环境混用

---

## 十四、常见命令速查

### 1. WSL 相关

查看状态：

```powershell
wsl --status
wsl -l -v
```

启动 Ubuntu：

```powershell
wsl -d Ubuntu
```

关闭 WSL：

```powershell
wsl --shutdown
```

### 2. Ubuntu 初始化

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget git unzip zip ca-certificates pkg-config software-properties-common
mkdir -p ~/workspace
cd ~/workspace
```

### 3. Python 相关

```bash
pyenv --version
pyenv install 3.12.9
pyenv global 3.12.9
pyenv rehash
python --version
uv --version
```

### 4. Node.js 相关

```bash
nvm --version
nvm install --lts
nvm use --lts
node -v
npm -v
pnpm -v
```

---

## 十五、常见坑和解决办法

### 1. 开始菜单搜不到 Ubuntu

现象：

- 搜索里没有 `Ubuntu`

解决：

在 `PowerShell` 里直接执行：

```powershell
wsl -d Ubuntu
```

### 2. `wsl -l -v` 提示没有分发

现象：

```text
适用于 Linux 的 Windows 子系统没有已安装的分发
```

说明：

- `WSL` 平台已安装
- 但 `Ubuntu` 分发还没装

解决：

```powershell
wsl --install -d Ubuntu
```

### 3. 密码输入后没有显示字符

现象：

- 输入密码时屏幕无反应

说明：

- 正常现象

做法：

- 直接输入密码并按回车

### 4. 把密码当成命令输入了

现象：

```bash
123456: command not found
```

说明：

- 你不是在 `sudo` 提示下输入密码
- 而是直接把密码当成命令执行了

正确做法：

```bash
sudo -v
```

然后在密码提示状态下输入密码。

### 5. 在错误的终端里执行了 Ubuntu 命令

现象：

- 你以为自己在 Ubuntu
- 但实际上提示符还是 Windows 或某个包装器终端

判断方法：

- Windows 常见提示符：`PS C:\...>`
- Ubuntu 常见提示符：`用户名@主机名:~$`

### 6. URL 外面误加了反引号

错误示例：

```bash
curl -o- `https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh` | bash
```

正确示例：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

原则：

- 普通 URL 不要加反引号
- 直接写原始 URL 即可

### 7. `python` 找不到

现象：

```bash
pyenv: python: command not found
```

解决：

```bash
pyenv global 3.12.9
pyenv rehash
source ~/.bashrc
```

### 8. `uv` 装好了但命令找不到

解决：

```bash
source ~/.bashrc
source $HOME/.local/bin/env
```

### 9. `nvm` 装好了但命令找不到

解决：

```bash
source ~/.bashrc
nvm --version
```

### 10. 代理导致 WSL 里网络异常

现象：

- 下载失败
- Git 克隆失败
- 提示与 `localhost 代理` 相关

可尝试清理当前终端代理：

```bash
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy
git config --global --unset http.proxy
git config --global --unset https.proxy
```

然后重新执行下载命令。

---

## 十六、安装完成后的验收清单

在 Ubuntu 中执行下面这些命令，全部正常就说明环境可用了：

```bash
git --version
curl --version
wget --version
pyenv --version
python --version
uv --version
nvm --version
node -v
npm -v
pnpm -v
pwd
```

理想结果：

- `git` 正常
- `python` 是 `3.12.9`
- `uv` 正常
- `node` 正常
- `pnpm` 正常
- 当前工作目录是 `~/workspace`

---

## 十七、推荐的长期使用规则

为了保持系统干净、流畅、稳定，建议长期遵守这些规则：

- 开发项目统一放在 `~/workspace`
- Python 一律用 `pyenv + uv`
- Node.js 一律用 `nvm + pnpm`
- Git 一律在 Ubuntu 中使用
- 数据库和缓存尽量用 Docker
- 不要在 Windows 本机和 Ubuntu 中混装同类环境
- 不要把 `.env`、密钥、私密配置提交到 Git

---

## 十八、一份最短复现流程

下次换电脑时，如果你已经熟悉了流程，可以直接按这个最短版本操作。

### Windows 中执行

```powershell
wsl --install -d Ubuntu
```

重启后：

```powershell
wsl -d Ubuntu
```

### Ubuntu 中执行

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget git unzip zip ca-certificates pkg-config software-properties-common
mkdir -p ~/workspace
cd ~/workspace
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
curl https://pyenv.run | bash
cat >> ~/.bashrc <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
EOF
source ~/.bashrc
pyenv install 3.12.9
pyenv global 3.12.9
pyenv rehash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
source $HOME/.local/bin/env
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts
corepack enable
corepack prepare pnpm@latest --activate
```

### 验证

```bash
python --version
uv --version
node -v
pnpm -v
```

---

## 十九、适合 AI agent 工具的使用建议

如果你使用：

- `opencode`
- 其他终端型 AI agent
- CLI 代码助手

推荐做法：

- 尽量在 `WSL Ubuntu` 中运行
- 让代码、Git、Python、Node、pnpm 都在同一个 Linux 环境里
- 减少 Windows 路径和 Linux 路径混用问题

推荐环境：

- 仓库放在 `~/workspace`
- agent 从 Ubuntu 终端启动
- IDE 使用 `VS Code Remote WSL`

---

## 二十、最后的建议

如果你只记住一件事，那就是：

- `Windows 做宿主机`
- `Ubuntu 做开发环境`
- `Docker 按需运行中间件`

这样最不容易把系统搞乱，也最适合长期维护。

如果你以后换电脑，按本文从头执行，一般都能稳定复现。
