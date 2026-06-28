# 更新日志

每次代码、数据处理、文档或自动化相关更新都必须记录在这里，方便后续维护者追踪更新时间、更新内容和受影响路径。记录统一使用中文。

日期写在 `## YYYY-MM-DD` 标题中；同一天内有多条更新时，必须在日期标题下用 `### HH:MM - 更新标题` 分隔。条目正文不再重复日期和时间。

每条更新必须包含以下字段：

- 更新者：说明本次更新由谁发起或执行；如果由 Codex 代操作，写清楚对应维护者和 Codex。
- 更新内容：列出实际改动。
- 验证：说明运行过的检查；如果没有验证，写明未验证原因。
- 影响路径：列出本次改动影响到的主要文件或目录。

## 2026-06-28

### 16:53 - 提交 Godot AI 项目配置

更新者：KowComical（Codex 代操作）

更新内容：
- 将 Godot 自动写入的 `_mcp_game_helper` autoload 保留到 `project.godot`，用于项目级 Godot AI 运行辅助。
- 规范化 `project.godot` 的配置文件注释和末尾换行。
- 本次变更属于仓库内 Godot 项目配置，不包含用户级 Codex/MCP 配置、个人 token 或本机绝对路径。

验证：
- 使用 Godot 4.7 stable 控制台版执行 `--headless --path . --scene res://scenes/main.tscn --quit-after 2`，主场景短时运行通过。

影响路径：
- `project.godot`
- `UPDATE_LOG.md`

### 16:49 - 修正更新日志记录格式

更新者：KowComical（Codex 代操作）

更新内容：
- 将同一天内的更新日志条目调整为新时间在上、旧时间在下。
- 将横板小队跑酷 demo 条目的更新者从泛称改为 `KowComical（Codex 代操作）`。

验证：
- 检查 `## 2026-06-28` 下的条目已按时间倒序排列。
- 检查 demo 条目的更新者已指向具体维护者。

影响路径：
- `UPDATE_LOG.md`

### 16:03 - 新增横板小队跑酷 demo

更新者：KowComical（Codex 代操作）

更新内容：
- 从 `local_assets/Tiny Swords.zip` 中抽取少量 PNG 到项目内 `assets/tiny_swords/`，用于 demo 角色、敌人和场景装饰。
- 新增 `scripts/main.gd`，实现横板自动前进、上下换道、小队人数显示、加减/倍增门、队友拾取、敌人扣人数和终点结算。
- 将 `scenes/main.tscn` 改为 `Node2D` 主场景并绑定 demo 脚本。

验证：
- 使用 Godot 4.7 stable 控制台版执行 `--headless --path . --quit`，项目加载和脚本解析通过。
- 使用 Godot 4.7 stable 控制台版执行 `--headless --path . --scene res://scenes/main.tscn --quit-after 2`，主场景短时运行通过。

影响路径：
- `assets/tiny_swords/`
- `scripts/main.gd`
- `scenes/main.tscn`
- `UPDATE_LOG.md`

### 15:48 - 新增本地素材忽略目录

更新者：KowComical（Codex 代操作）

更新内容：
- 新增本地素材目录 `local_assets/`，用于存放不需要同步到 GitHub 的本地素材、参考图或源文件。
- 在 `.gitignore` 中加入 `local_assets/`，确保该目录及其内容不会被 Git 跟踪。
- 在 `local_assets/README_LOCAL.txt` 中写入本地用途说明；该说明文件同样被忽略，不会提交到仓库。

验证：
- 使用 `git check-ignore` 验证 `local_assets/README_LOCAL.txt` 命中 `.gitignore` 规则。
- 使用 `git status` 确认 `local_assets/` 不出现在待提交列表中。

影响路径：
- `.gitignore`
- `UPDATE_LOG.md`
- `local_assets/`

### 14:17 - 优化项目协作和 Godot 状态说明

更新者：KowComical（Codex 代操作）

更新内容：
- 重写 `AGENTS.md` 的项目定位、Git 协作规则、更新日志规则、Godot 约定和 Codex / MCP / Godot AI 约定。
- 将目标 Godot 版本从“待确认”更新为 `4.7 stable`。
- 补充 `Kow:` PR 标题前缀、Godot 标准版/GDScript 默认选择、`.godot/` 缓存不提交、Godot AI 与用户级 MCP 配置边界等说明。
- 强调修改代码、文档、自动化或配置时必须同步维护 `UPDATE_LOG.md`。

验证：
- 检查 `AGENTS.md` 不再包含 Godot 版本未确认的旧规则。
- 检查 `AGENTS.md` 已包含 Godot `4.7 stable`、PR 前缀、更新日志和 MCP 配置边界说明。

影响路径：
- `AGENTS.md`
- `UPDATE_LOG.md`

### 14:11 - 新增更新日志规范

更新者：KowComical（Codex 代操作）

更新内容：
- 新增 `UPDATE_LOG.md`，用于记录后续代码、数据处理、文档和自动化相关更新。
- 明确更新日志统一使用中文，并按 `## YYYY-MM-DD` 与 `### HH:MM - 更新标题` 分层记录。
- 规定每条记录必须写明更新者、更新内容、验证和影响路径。
- 在 `AGENTS.md` 中补充更新日志维护规则，要求后续相关改动同步更新本文件。

验证：
- 检查 `UPDATE_LOG.md` 使用约定的日期和时间标题格式。
- 检查 `AGENTS.md` 已包含更新日志规则和更新者记录要求。

影响路径：
- `UPDATE_LOG.md`
- `AGENTS.md`
