# OpenCode 教程仓库

纯文档仓库：不构建、不测试、无需运行任何命令。

## 文件体系

| 文件 | 说明 |
|------|------|
| `opencode-guide-part1-beginner.md` | 初级篇（~295 行） |
| `opencode-guide-part2-intermediate.md` | 中级篇（~435 行） |
| `opencode-guide-part3-advanced.md` | 高级篇（~512 行） |
| `improve-loop.sh` | 定时循环检查脚本 |
| `opencode.json` | OpenCode 配置（自定义命令 `/improve`、`/improve-check`） |
| `opencode.json.bak` | **旧版备份 — 不要修改或使用** |

## 写作规则

- **顺序依赖**：初级 → 中级 → 高级，文末有指向下一篇的链接
- **交叉引用**：每篇文末链接到下一篇；高级篇同时链接回初级和中级
- **每个文件独立完整**，不做文件间拆分或共享内容
- **不添加** README、索引文件或额外配置文件
- **语言**：中文为主，代码块用英文，全文件无 emoji
- **不要改 `opencode.json.bak`** — 它是旧版备份，已弃用

## 自定义命令

所有修改直接编辑 `.md` 文件。OpenCode 配置了两个自定义命令：

| 命令 | 行为 |
|------|------|
| `/improve` | 全面检查项目并执行改进（读写） |
| `/improve-check` | 仅检查输出改进建议，不修改任何文件（只读） |

## 持续改进

- `bash improve-loop.sh [分钟]` — 定时循环执行 `/improve-check`（默认 30 分钟）
- `opencode --agent improver` — 启动专用的持续改进 Agent 会话
- `opencode --execute "/improve-check" --headless` — 无头模式下执行检查（用于 `improve-loop.sh`）