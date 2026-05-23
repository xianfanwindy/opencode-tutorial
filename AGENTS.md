# OpenCode 教程仓库

纯文档仓库：不构建、不测试、无需运行任何命令。

## 文件结构

| 文件 | 用途 |
|------|------|
| `opencode-guide-part1-beginner.md` | 初阶教程 |
| `opencode-guide-part2-intermediate.md` | 进阶教程 |
| `opencode-guide-part3-advanced.md` | 高阶教程 |
| `improve-loop.sh` | 定时检查循环脚本 |
| `opencode.json` | OpenCode 配置（包含自定义命令 improve / improve-check） |
| `opencode.json.bak` | 旧版备份 — 不要修改或使用 |

## 写作规则

- **三篇有顺序依赖**：初级 → 中级 → 高级，文末有指向下一篇的链接
- 篇间互有交叉引用（`opencode-guide-part2-intermediate.md` → `opencode-guide-part3-advanced.md` 等）
- 每个文件独立完整，不做文件间拆分
- 不添加额外的 README、索引文件或配置文件
- 保持 Markdown 格式一致，中文为主，代码块用英文

## 自定义命令

所有修改直接编辑 `.md` 文件。OpenCode 配置了以下自定义命令：

- `/improve` — 对项目进行全面检查并执行改进
- `/improve-check` — 仅检查输出建议，不修改

## 持续改进

- `bash improve-loop.sh [分钟]` — 定时循环执行检查（默认间隔 30 分钟）
- `opencode --agent improver` — 启动专用的持续改进 Agent 会话