# OpenCode 教程 · 中级篇：熟练工进阶

> **适合读者：** 已经用过 OpenCode，想提升效率和精度
> **目标：** 掌握高级配置、自定义工作流、高效 Prompt 技巧

---

## 1. AGENTS.md — 让 AI 真正懂你的项目

`AGENTS.md` 是 OpenCode 的项目说明书。每次启动时 AI 都会读它。写得好，AI 表现提升一个档次。

### 自动生成

```bash
/init
```

OpenCode 会自动扫描项目结构并生成初始版本。

### 手动优化

一个好的 AGENTS.md 应该包含：

```markdown
# 项目概述
商城后台管理系统，基于 Next.js 14 + Prisma + PostgreSQL

# 技术栈
- 前端：React 18, Tailwind CSS, shadcn/ui
- 后端：Next.js API Routes
- 数据库：PostgreSQL + Prisma ORM
- 测试：Vitest + Playwright

# 目录结构
- src/app — Next.js App Router 页面
- src/components — 可复用组件
- src/lib — 工具函数
- src/server — 服务端逻辑
- prisma — 数据库 schema 和迁移

# 编码规范
- 使用命名导出，不使用默认导出
- 组件文件使用 PascalCase，工具函数使用 camelCase
- API 路由统一返回 { success, data, error } 格式
- 所有数据库查询通过 Prisma 完成
- 错误处理使用自定义 AppError 类
```

### 最佳实践

| 做法 | 说明 |
|------|------|
| 提交到 Git | 团队成员共享，CI 中也可用 |
| 定期更新 | 项目演化后记得同步 |
| 附上示例 | 提供代码片段作为参考 |
| 明确约定 | 命名规范、错误处理、测试要求 |

---

## 2. @ 引用：精准定位文件

用 `@` 模糊搜索文件，是让 AI 理解上下文的最有效方式。

### 基础用法

```
@src/utils/auth.ts 里的验证逻辑需要修改
```

输入 `@` 后，会弹出文件搜索框，支持模糊匹配。

### 进阶技巧

**多个文件同时引用：**

```
对比 @src/utils/format.ts 和 @src/utils/parse.ts，
它们的功能有重复，请合并。
```

**引用目录：**

```
@src/api/ 里所有路由都加上请求日志
```

AI 会读取目录下所有相关文件。

**引用大文件中的某一段：**

如果文件很长，可以先问：

```
@src/server/handler.ts 里 processOrder 函数在第几行？
```

得到行号后再精确提问。

---

## 3. 图片输入：拖拽即用

UI 相关的需求，截图比文字描述高效 100 倍。

**操作方式：** 直接把图片拖进终端窗口。

```
参考这张截图，实现同样的登录页面
```

（拖拽图片到终端）

AI 会识别图片内容并生成代码。

> 支持常见的图片格式：PNG, JPG, WebP, SVG

---

## 4. 多文件修改与重构

### 场景：重命名并拆分函数

假设 `src/utils.ts` 里有一个 200 行的 `processData` 函数，想拆成多个小函数。

**错误做法：**

```
把 processData 优化一下
```

（太模糊，AI 可能改得不对）

**正确做法：**

```
@src/utils.ts 里的 processData 函数太长了，
我想把它拆成 validateInput、transformData、formatOutput 三个函数，
每个不超过 30 行。保持原有导出接口不变。
```

### 跨文件重构

```
@src/api/users.ts 和 @src/api/orders.ts 里
都有一段相同的权限校验逻辑，抽到 @src/lib/auth.ts 里，
然后引用它。
```

AI 会自动创建新文件、修改旧文件、更新所有 import。

---

## 5. 自定义命令

把高频操作变成快捷命令。编辑 `~/.config/opencode/commands.json`：

```json
{
  "commands": [
    {
      "name": "review",
      "description": "代码审查：检查最近修改的代码",
      "prompt": "请审查我当前分支上最近修改的代码，检查潜在 Bug、安全问题和性能问题。"
    },
    {
      "name": "test",
      "description": "为当前文件生成测试",
      "prompt": "为 @{file} 生成单元测试，使用项目已有的测试框架。覆盖正常路径和边界情况。"
    },
    {
      "name": "docs",
      "description": "为当前文件生成文档注释",
      "prompt": "为 @{file} 中的每个导出函数和类型添加 JSDoc 注释。"
    }
  ]
}
```

使用方式：在终端输入 `/review`、`/test`、`/docs`。

---

## 6. 主题 & 快捷键

### 切换主题

编辑 `~/.config/opencode/opencode.json`：

```json
{
  "theme": {
    "name": "catppuccin-mocha"
  }
}
```

内置主题包括：`catppuccin-*`、`solarized-*`、`dracula`、`nord`、`monokai` 等。

### 自定义快捷键

编辑 `~/.config/opencode/keybinds.json`：

```json
{
  "keybinds": [
    {
      "key": "ctrl+p",
      "command": "search:file"
    },
    {
      "key": "ctrl+shift+p",
      "command": "search:command"
    },
    {
      "key": "ctrl+y",
      "command": "editor:undo"
    }
  ]
}
```

---

## 7. MCP 服务器入门

MCP（Model Context Protocol）让 AI 能调用外部工具——数据库、API、文件系统等。

### 配置示例：连接 SQLite

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "./data.db"]
    }
  }
}
```

配置后，AI 就能：

```
查询数据库里最近 10 条订单记录
```

AI 会直接执行 SQL 查询并返回结果。

### 常用 MCP 服务器

| 服务 | 用途 |
|------|------|
| `mcp-server-sqlite` | SQLite 数据库操作 |
| `mcp-server-postgres` | PostgreSQL 数据库操作 |
| `mcp-server-filesystem` | 文件系统操作 |
| `mcp-server-github` | GitHub API 操作 |
| `mcp-server-docker` | Docker 容器管理 |

---

## 8. LSP & 格式化器

### LSP 自动加载

OpenCode 会自动检测项目中的 LSP 服务器（TypeScript、Python、Rust 等），让 AI 理解代码的语义，减少幻觉。

```json
{
  "lsp": {
    "servers": ["typescript", "rust-analyzer", "pyright"]
  }
}
```

### 代码格式化

配置格式化器，让 AI 生成的代码自动符合项目风格：

```json
{
  "formatters": [
    {
      "language": "typescript",
      "command": "prettier",
      "args": ["--write"]
    },
    {
      "language": "python",
      "command": "ruff",
      "args": ["format"]
    },
    {
      "language": "rust",
      "command": "rustfmt"
    }
  ]
}
```

---

## 9. 高质量 Prompt 技巧

### 好 Prompt 的 4 个要素

| 要素 | 说明 | 示例 |
|------|------|------|
| 上下文 | 引用相关文件 | `@src/auth.ts` |
| 目标 | 要做什么 | 加上邮箱验证 |
| 约束 | 不能做什么 | 不要改数据库 schema |
| 参考 | 风格参考 | 跟 `@src/user.ts` 保持一致的写法 |

### 反例 vs 正例

```
❌ 帮我加个登录功能
```

```
✅ @src/api/auth.ts 里加一个邮箱密码登录接口，
   验证逻辑参考 @src/api/users.ts 里的 validateEmail 函数，
   返回格式保持 { success, data, error }。
   当前数据库有 users 表，字段见 @prisma/schema.prisma
```

### 迭代式沟通

不要期望一次说清。AI 的惯用流程：

```
你：按 Tab 进 Plan 模式
你："我想加一个用户通知功能"
AI：给出方案
你："再加一条：支持邮件和站内信两种方式"
AI：更新方案
你：按 Tab 切 Build 模式
你："开始实现"
```

---

## 10. 常见问题

### AGENTS.md 不生效？
检查文件是否在项目根目录，文件名必须完全匹配 `AGENTS.md`。

### 自定义命令不出现？
检查 `commands.json` 格式是否正确，运行 `/reload` 重新加载配置。

### MCP 服务器连接失败？
确认命令已安装且在 PATH 中，检查终端中手动运行是否正常。

### AI 生成的代码风格不一致？
配置格式化器后 AI 会自动格式化。也可以在 AGENTS.md 中明确编码风格。

---

## 11. 下篇预告

你已经掌握了 OpenCode 的中级用法。进阶之路：

- **高级篇**：自定义工具开发、Plugin/SDK、多 Agent 并行、企业级配置

继续学习 → [高级篇](opencode-guide-part3-advanced.md)