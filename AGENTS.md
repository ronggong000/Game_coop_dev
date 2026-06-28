# AGENTS.md

## 项目定位

- 这是 `Game_coop_dev` 游戏项目，使用 Godot 开发。
- 目标 Godot 版本已确定为 `4.7 stable`；不要引入依赖其他 Godot 主版本或实验版本的项目配置。
- 默认使用中文和项目维护者沟通；代码、脚本、场景、资源命名优先使用英文，保持清晰、可搜索。
- 当前阶段以可运行原型为优先，避免过早引入复杂资源管线、联网架构或大范围目录重构。

## Git 协作规则

- `main` 是受保护分支，不能直接 push；所有改动必须先推到功能分支，再通过 Pull Request 合并。
- PR 至少需要另一位维护者 approval 后才能合并；PR 作者不能把自己的改动当作已审查。
- `KowComical` 发起的 PR 标题默认使用 `Kow:` 前缀，方便区分提交来源。
- 开始改动前先运行 `git status`，确认当前分支和未提交改动；不要覆盖他人的本地改动。
- 新工作从最新 `main` 创建分支，例如 `feature/player-controller`、`fix/input-mapping`、`docs/update-workflow`、`tooling/install-godot-ai`。
- 拉取远端更新时，优先使用 `git fetch` 查看差异，再按当前分支策略执行 `git pull --rebase` 或普通 merge。
- `pull` 本身不要求互相审查，但需要阅读远端新增改动；如果出现冲突，先停止并说明冲突文件和建议处理方式。
- `push` 前必须检查 `git diff` / `git diff --staged`，确认只包含本次任务相关内容。
- 推送共享分支前先运行项目约定的检查；如果检查命令尚未建立，至少说明未运行的原因。
- 不要直接强推共享分支。需要改历史时，先征得维护者确认。
- 主要功能、资源管线、存档格式、联网/协作逻辑、构建发布配置，必须通过 PR 审查后合并。
- 小的文档、配置或空项目初始化改动也走 PR，除非维护者临时解除保护规则。

## 更新日志规则

- 每次代码、数据处理、文档或自动化相关更新都必须同步更新 `UPDATE_LOG.md`。
- 更新日志统一使用中文，日期标题使用 `## YYYY-MM-DD`，同一天内的多条更新使用 `### HH:MM - 更新标题`。
- 每条更新必须包含 `更新者`、`更新内容`、`验证` 和 `影响路径`。
- `更新者` 必须说明本次更新由谁发起或执行；如果由 Codex 代操作，写成 `维护者（Codex 代操作）`。
- 条目正文不要重复日期和时间；日期与时间只写在标题中。
- 如果某次改动没有运行验证，必须在 `验证` 字段写明未验证原因。

## Godot 约定

- 使用 Godot `4.7 stable` 打开和验证项目；本机当前安装路径为 `F:\Tools\Godot\4.7-stable`，但不要把个人绝对路径写入项目配置。
- 默认使用 Godot 标准版和 GDScript；除非维护者明确决定，否则不要切换到 C# / Mono 方案。
- Godot 自动生成的 `.godot/`、导入缓存、编辑器临时文件和导出产物不要提交。
- 场景、脚本、资源路径要稳定，避免无理由重命名导致场景引用断裂。
- 修改 `.tscn`、`.tres`、`.godot`、`project.godot` 或插件配置后，优先用 Godot 打开项目验证没有资源缺失、导入错误或主场景启动错误。
- 游戏逻辑优先放在清晰的脚本和场景边界里，不把大量核心逻辑塞进一次性编辑器操作生成的文件。
- 第一阶段优先实现小范围可玩原型；玩法方向未定前，不要提交大规模美术资源或复杂系统框架。

## Codex / MCP / Godot AI

- `hi-godot/godot-ai` 是 Godot 编辑器插件加本地 MCP server，用来让 Codex 等 MCP 客户端控制正在运行的 Godot 编辑器；它不是普通的 Godot 游戏运行时依赖。
- `godot-ai` 依赖 `uv` 启动 Python MCP server；本机已安装 `uv`，新终端中应可直接使用 `uv --version` 验证。
- 如果仓库中存在 `addons/godot_ai/`，应通过 Godot 的 `Project > Project Settings > Plugins` 启用或检查插件状态。
- `godot-ai` 服务地址通常是 `http://127.0.0.1:8000/mcp`。Codex 连接方式应放在用户级 `~/.codex/config.toml`，除非团队明确决定提交项目级 `.codex/config.toml`。
- 不要把个人 token、绝对路径、机器专属 MCP 配置提交到仓库。
- 修改 Codex、MCP、GitHub CLI、Godot AI 相关配置时，要在 PR 描述和 `UPDATE_LOG.md` 中说明哪些是仓库配置，哪些只是本机环境配置。
