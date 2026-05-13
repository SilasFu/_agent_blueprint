# Agent 项目协作规则

本文件用于指导 Agent CLI 在一个全新项目中如何理解环境、读取需求、做出技术选型，并自动完成配置的完善与搭建。

这套仓库当前阶段的核心定位不是"包办所有开发问题"，而是优先把下面这件事做稳：

- 用统一规则、模板和脚本，稳定完成新项目初始化、环境准备和基础协作落地

## 1. 总目标

你需要把当前仓库视为一个"待初始化的新项目"，而不是假设它已经有完整技术栈。

你的首要任务不是直接写代码，而是先判断：

- 项目需求是什么
- 当前环境是否满足要求
- 最适合的技术栈是什么
- 哪些配置需要生成
- 哪些基础设施需要启动

默认目标用户是个人开发者或 1 到 5 人的小团队。

当前阶段默认不承诺：

- 完整 CI/CD 和自动部署
- 所有操作系统上的一致自动安装能力
- 覆盖所有语言和框架
- 从需求到上线完全无人值守

## 2. 固定环境约束

除非项目需求明确要求变更，否则默认遵循以下规则：

- 宿主环境是 `Windows + WSL2 Ubuntu`，脚本在 Windows 原生 PowerShell 下需通过 WSL 执行
- Python 使用 `pyenv + uv`
- Node.js 使用 `nvm + pnpm`
- 数据库、缓存、消息队列等中间件统一使用 `Docker`
- 本地项目目录默认建议位于 `~/workspace`，但可根据团队或个人习惯调整
- `.env` 不提交 Git，但要保留 `.env.example`
- 代码必须纳入 Git 管理，并建议尽早推送远程仓库

## 2.1 示例路径与命名的解释规则

阅读本仓库中的文档、配置和脚本时，请遵循以下解释规则：

- 示例项目名、目录名、服务名、容器名、数据库名都只是默认值
- `~/workspace`、`my-new-project`、`appdb`、`app-postgres` 这类名称并不是强制要求
- 如果用户没有明确指定路径，可把这些值作为推荐默认值
- 如果用户已经有自己的路径、命名规则、团队规范，应优先适配用户的实际情况
- 生成文档和注释时，应尽量写成可迁移、可复用、可替换的形式，不要绑定某一台电脑

## 3. 读取顺序

开始工作前，按以下顺序读取并理解项目上下文：

1. `AGENTS.md`
2. `project-spec.yaml`，如果存在
3. `README.md`
4. `doc/02-workflow/任务输入模板.md`，如果存在且当前任务描述不够结构化
5. `doc/02-workflow/任务执行与交付验收准则.md`，如果存在
6. `doc/02-workflow/任务结果输出模板.md`，如果存在
7. `doc/task-playbooks/README.md`，如果当前任务属于明确类型且该目录存在
8. `.env.example`
9. `compose.yaml`
10. `Makefile`
11. `scripts/lib.sh`（共享函数库）
12. `scripts/check-env.sh`
13. `scripts/bootstrap.sh`
14. `scripts/dev.sh`
15. `scripts/test.sh`
16. `scripts/init-project.sh`（模板→项目转换）

如果某些文件还不存在，你应根据需求创建它们。

如果当前任务是帮助用户理解这套体系、选择阅读路径或判断先看哪份文档，可以优先参考 `doc/01-onboarding/使用总览导航.md`。

如果当前任务是新增或整理文档，应优先参考 `doc/04-maintenance/文档命名与目录规范.md`，尽量保持命名和目录分层一致。

如果当前任务涉及统一表述、整理高频概念或减少近义词混用，应优先参考 `doc/04-maintenance/术语使用规范.md`。

如果当前任务是维护这套体系本身，而不是补业务内容，应优先参考 `doc/04-maintenance/最小维护说明.md`，先保护稳定入口和引用链路。

如果用户任务描述比较简略、边界不清或验收标准缺失，应参考 `doc/02-workflow/任务输入模板.md` 提炼出目标、范围、限制和完成标准，再继续执行。

如果当前任务属于新增接口、改表迁移、第三方集成、验证回归等高频类型，应优先寻找并遵循 `doc/task-playbooks/` 下的对应手册。

在输出最终结果前，应参考 `doc/02-workflow/任务结果输出模板.md` 组织交付内容，确保结果、验证、边界和下一步建议表达完整。

## 3.1 模板隔离规则

为避免样例代码污染当前任务判断，请遵循以下规则：

- 默认不要把 `templates/` 目录加入主上下文
- 只有用户明确要求"基于某个模板开始"或当前项目已确认复制自某个模板时，才读取对应模板
- 如果只是做规则梳理、需求澄清、技术选型或流程完善，应只基于根目录文档与当前项目文件工作
- 如果模板与根目录规则、`project-spec.yaml` 或用户当前要求冲突，以当前要求为最高优先级
- 引用模板时，应把它当成样例和加速器，而不是不可变标准答案

## 4. 技术选型原则

如果用户只给出需求，没有明确指定技术栈，你应优先做"简单、稳定、便于单人维护"的推荐。

默认推荐规则如下：

- 纯后端 API、AI 服务、自动化任务：优先推荐 `Python + FastAPI`
- 前端单页应用：优先推荐 `React + Vite + pnpm`
- 中小型全栈应用：优先推荐 `FastAPI + React + PostgreSQL + Redis`
- 只需要本地原型和轻量存储：可考虑 `SQLite`
- 需要结构化关系数据：优先推荐 `PostgreSQL`
- 需要缓存、会话、队列或临时数据：优先推荐 `Redis`
- 需要 AI 功能：优先保留清晰的服务边界、环境变量和模型接入点

如果用户提出明确偏好，以用户偏好为准。

## 5. 工作流程

每次接到新项目需求时，按以下顺序推进：

1. 读取 `project-spec.yaml`
2. 判断项目类型、目标用户、核心功能、约束和偏好
3. 给出技术选型建议
4. 将建议落实为项目结构、配置文件、依赖文件和脚本
5. 默认优先运行 `scripts/bootstrap.sh`
6. 如果当前只适合做环境体检，再单独运行 `scripts/check-env.sh`
7. 必要时启动 `Docker` 基础设施
8. 在 `README.md` 中写清运行与测试方式

关于第 4 步，项目创建有三条路径：

- **路径 A**：已确定模板 → 运行 `bash scripts/init-project.sh <模板名> <目录> [项目名]`
- **路径 B**：已有 project-spec.yaml → 运行 `make validate` 校验后，再运行 `make scaffold` 生成骨架
- **路径 C**：需要 Agent 实时判断 → Agent 根据规则推荐技术栈并生成

关于第 5、6 步，必须遵循下面规则：

- `scripts/bootstrap.sh` 是默认主入口，适合大多数新手用户
- `scripts/check-env.sh` 是辅助入口，适合只想先检查环境时使用
- 如果发现缺失工具，应先用中文说明缺什么、会影响什么
- 在执行自动安装前，应先征求用户确认
- 如果自动安装不适用当前环境，应明确告诉用户推荐环境和替代处理方式

如果用户已确定要使用某个模板，可以推荐使用 `scripts/init-project.sh` 一键创建项目：

- `bash scripts/init-project.sh <模板名> <目标目录> [项目名]`
- 此脚本会自动复制模板、替换项目名/容器名/数据库名/密码占位符、初始化 Git
- 然后进入项目目录执行 `make bootstrap` 即可

如果当前任务只是完善规范、约束和协作规则，不要提前生成大量业务代码，也不要默认套用现成模板实现。

## 6. 何时提问

只有在下列情况才需要向用户提问：

- 需求存在关键冲突
- 多种架构都合理，但对结果影响很大
- 涉及明显成本或部署差异
- 用户没有给出数据库、前后端分离、认证等关键方向，且自动推荐风险较高

如果可以基于现有需求做出合理默认值，应先采用默认值并说明理由。

## 7. 自动生成的优先内容

当项目尚未初始化时，优先补全这些内容：

- `README.md`
- `.gitignore`
- `.env.example`
- `compose.yaml`
- `Makefile`
- `scripts/lib.sh`
- `scripts/check-env.sh`
- `scripts/bootstrap.sh`
- `scripts/dev.sh`
- `scripts/test.sh`
- `scripts/init-project.sh`（如果需要模板转换）
- `scripts/scaffold.sh`（如果需要从需求生成）
- `scripts/sync-lib.sh`（维护时同步 lib.sh）
- `scripts/lint.sh`（脚本质量检查）
- `scripts/smoke-test.sh`（冒烟测试）
- 语言对应的依赖和入口文件

## 8. 输出要求

在完成技术选型或初始化后，你应明确告诉用户：

- 你为项目选择了什么技术栈
- 为什么这样选
- 下一步如何运行
- 哪些配置仍需要用户补充，比如 API Key、OAuth 配置、部署参数等
- 示例路径和命名哪些是可调整项，避免用户误以为必须照抄

## 9. 长期原则

- 优先让仓库"自解释"
- 优先让脚本成为统一入口
- 优先让配置可复制、可恢复、可审查
- 不假设用户机器上已经有全局环境
- 不把本地环境当唯一备份
- 如果仓库文档、脚本和模板表达不一致，优先修复一致性，再继续扩展功能

## 10. 脚本架构

所有脚本共享 `scripts/lib.sh` 函数库，包含：

- 工具检测与安装：`is_installed`、`install_tool`、`run_env_check`
- Docker 相关：`check_docker_daemon`、`check_port_in_use`、`start_docker_services`
- 交互辅助：`confirm_install`、`append_line_if_missing`
- 版本输出：`print_version`、`tool_label`

修改这些函数时，只需更新 `scripts/lib.sh`，然后运行 `make sync-lib` 同步到各模板。

模板脚本通过 `source "$SCRIPT_DIR/lib.sh"` 引入共享函数，自身只保留模板特定的逻辑。

### 脚本清单

| 脚本 | 用途 | 入口命令 |
|------|------|----------|
| `scripts/lib.sh` | 共享函数库 | 其他脚本 source 引入 |
| `scripts/bootstrap.sh` | 环境检查 + 项目初始化 | `make bootstrap` |
| `scripts/check-env.sh` | 独立环境检查 | `make check` |
| `scripts/init-project.sh` | 从模板创建项目 | 手动调用 |
| `scripts/scaffold.sh` | 基于 project-spec.yaml 生成骨架 | `make scaffold` |
| `scripts/validate-spec.sh` | 校验 project-spec.yaml | `make validate` |
| `scripts/sync-lib.sh` | 同步 lib.sh 到所有模板 | `make sync-lib` |
| `scripts/setup.sh` | Ubuntu 一键安装开发环境 | `make setup` |
| `scripts/dev.sh` | 开发入口识别 | `make dev` |
| `scripts/test.sh` | 测试入口识别 | `make test` |
| `scripts/lint.sh` | 脚本质量检查 | `make lint` |
| `scripts/smoke-test.sh` | 冒烟测试 | `make smoke-test` |

## 11. 安全约定

- `compose.yaml` 中的密码和配置项必须引用 `.env` 环境变量（带默认值兜底）
- `.env.example` 中的密码必须是明显的占位符（如 `change_me_in_production`）
- `DATABASE_URL` 等组合连接串需填写完整值（Docker Compose 不会展开 `.env` 中的 `${VAR}` 引用）
- `COMPOSE_PROJECT_NAME` 用于区分不同项目的 Docker 资源
- `project-spec.yaml` 已加入 `.gitignore`，可能包含项目敏感信息
- `init-project.sh` 生成随机密码后缀，避免可预测的默认密码

## 12. 项目创建方式

项目有两种确定性创建方式和一种 Agent 辅助方式：

1. **从模板创建**（`init-project.sh`）：已验证的模板，替换占位符即可运行
2. **从需求生成**（`scaffold.sh`）：基于 `project-spec.yaml` 的类型和偏好自动生成骨架
3. **Agent 辅助生成**：Agent 读取规则和需求后实时生成，确定性取决于 Agent 能力

优先推荐方式 1（最快最稳），方式 2 适合需求不匹配已有模板的场景。
