# AGENTS.md

## 项目定位

- 这是 `Game_coop_dev` 游戏项目，计划使用 Godot 开发。
- 默认使用中文和项目维护者沟通；代码、资源命名优先保持英文、清晰、可搜索。
- 在确认 Godot 主版本前，不要提交依赖特定 Godot 版本的项目结构或插件配置。

## Git 协作规则

- `main` 是受保护分支，不能直接 push；所有改动必须先推到功能分支，再通过 Pull Request 合并。
- PR 至少需要另一位维护者 approval 后才能合并；PR 作者不能把自己的改动当作已审查。
- `KowComical` 发起的 PR 标题默认使用 `Kow:` 前缀，方便区分提交来源。
- 开始改动前先运行 `git status`，确认当前分支和未提交改动；不要覆盖他人的本地改动。
- 新工作从最新 `main` 创建分支，例如 `feature/player-controller`、`fix/input-mapping`、`docs/update-workflow`。
- 拉取远端更新时，优先使用 `git fetch` 查看差异，再按当前分支策略执行 `git pull --rebase` 或普通 merge。
- `pull` 本身不要求互相审查，但需要阅读远端新增改动；如果出现冲突，先停止并说明冲突文件和建议处理方式。
- `push` 前必须检查 `git diff` / `git diff --staged`，确认只包含本次任务相关内容。
- 推送共享分支前先运行项目约定的检查；如果检查命令尚未建立，至少说明未运行的原因。
- 不要直接强推共享分支。需要改历史时，先征得维护者确认。
- 主要功能、资源管线、存档格式、联网/协作逻辑、构建发布配置，必须通过 PR 审查后合并。
- 小的文档、配置或空项目初始化改动也走 PR，除非维护者临时解除保护规则。

## Godot 约定

- 创建 Godot 项目前，先确认目标 Godot 版本；当前参考 `godot-ai` 要求 Godot 4.3+，推荐 4.7+。
- Godot 自动生成的临时目录和导入缓存不要手动维护；提交前检查是否把本机缓存、导出产物或临时文件误加进 Git。
- 场景、脚本、资源路径要稳定，避免无理由重命名导致场景引用断裂。
- 修改 `.tscn`、`.tres`、`.godot` 相关文件后，优先用 Godot 打开项目验证没有资源缺失或导入错误。
- 游戏逻辑优先放在清晰的脚本和场景边界里，不把大量核心逻辑塞进一次性编辑器操作生成的文件。

## Codex / MCP / Godot AI

- `hi-godot/godot-ai` 是 Godot 编辑器插件加本地 MCP server，用来让 Codex 等 MCP 客户端控制正在运行的 Godot 编辑器；它不是普通的 Godot 游戏运行时依赖。
- 等仓库中已有 Godot 项目后，再安装插件到 `addons/godot_ai/`，并在 Godot 的 `Project > Project Settings > Plugins` 启用。
- `godot-ai` 服务地址通常是 `http://127.0.0.1:8000/mcp`。Codex 连接方式应放在用户级 `~/.codex/config.toml`，除非团队明确决定提交项目级 `.codex/config.toml`。
- 不要把个人 token、绝对路径、机器专属 MCP 配置提交到仓库。