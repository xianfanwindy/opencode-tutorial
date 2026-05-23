# OpenCode 教程 · 高级篇：成为老手

> **适合读者：** OpenCode 日常重度用户
> **目标：** 掌握扩展开发、多 Agent 协作、企业级配置

---

## 1. 自定义工具（Custom Tools）

当内置工具不够用时，你可以创建自己的工具。自定义工具是 OpenCode 的"插件系统"核心。

### 快速开始

创建一个可执行脚本，比如 `tools/get-weather.sh`：

```bash
#!/bin/bash
# 接收两个参数：city, date
curl -s "wttr.in/$1?format=%C+%t"
```

在 `opencode.json` 中注册：

```json
{
  "customTools": [
    {
      "name": "get_weather",
      "description": "查询指定城市的天气。参数：city（城市名，必填），date（日期，可选）",
      "command": "bash",
      "args": ["./tools/get-weather.sh", "$city", "$date"]
    }
  ]
}
```

现在 AI 可以调用它：

```
明天北京天气怎么样？
```

AI 会自动调用 `get_weather` 工具并返回结果。

### 工具开发最佳实践

| 原则 | 说明 |
|------|------|
| 单一职责 | 一个工具只做一件事 |
| 输入校验 | 检查参数合法性，返回清晰错误 |
| 带描述 | `description` 字段写清楚用途和参数，AI 靠它决定何时调用 |
| 输出结构化 | 返回 JSON 或 Markdown，便于 AI 理解 |
| 幂等性 | 读操作不应产生副作用 |

### 实战：数据库查询工具

```json
{
  "customTools": [
    {
      "name": "query_database",
      "description": "对 PostgreSQL 数据库执行只读 SQL 查询。参数：sql（SQL 语句）",
      "command": "psql",
      "args": [
        "-d", "mydb",
        "-c", "$sql",
        "--tuples-only"
      ]
    }
  ]
}
```

> **安全提示：** 自定义工具有执行命令的能力。建议在 permissions 中限制工具的使用范围（见下文）。

---

## 2. Agent Skills

Skills 是 OpenCode 的"技能包"——让 AI 学会特定类型任务的工作流。

### 创建 Skill

在项目 `.opencode/skills/` 目录下创建文件，例如 `skills/add-api-route.md`：

```markdown
# Add API Route
**Description:** 添加一个新的 API 路由
**Triggers:** "添加API路由", "新建接口", "add api route"

## 步骤
1. 在 `src/app/api/` 下创建新路由目录
2. 创建 `route.ts` 文件
3. 实现 HTTP 方法处理函数（GET, POST, PUT, DELETE）
4. 添加请求参数校验（使用 zod）
5. 在 Swagger 文档中注册（`src/docs/api.ts`）
6. 添加单元测试（`__tests__/api/`）

## 示例
```typescript
// src/app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

export async function POST(req: NextRequest) {
  const body = await req.json()
  const parsed = CreateUserSchema.safeParse(body)
  if (!parsed.success) {
    return NextResponse.json(
      { success: false, error: parsed.error.flatten() },
      { status: 400 }
    )
  }
  // ...
}
```

Skill 触发后，AI 会自动按步骤执行，保证一致性。

---

## 3. Plugin & SDK 开发

对于更复杂的需求，可以开发正式插件。

### Plugin 架构

```
my-plugin/
├── package.json
├── src/
│   ├── index.ts          # 插件入口
│   ├── tools.ts          # 注册自定义工具
│   └── hooks.ts          # 生命周期钩子
└── opencode-plugin.json  # 插件清单
```

### 插件清单

```json
{
  "name": "opencode-plugin-sentry",
  "version": "1.0.0",
  "description": "Sentry 错误监控集成",
  "tools": [
    {
      "name": "sentry_issues",
      "description": "查询 Sentry 最近错误",
      "handler": "./src/tools.ts#sentryIssues"
    }
  ],
  "hooks": {
    "onError": "./src/hooks.ts#onError"
  }
}
```

### SDK 快速开发

OpenCode SDK 提供了插件开发的完整工具链：

```typescript
import { defineTool, definePlugin } from 'opencode/sdk'

const analyzeDeps = defineTool({
  name: 'analyze_deps',
  description: '分析项目依赖健康状况',
  handler: async (args) => {
    // 检查过时依赖、安全漏洞等
    return { outdated: 3, vulnerable: 1 }
  },
})

export default definePlugin({
  name: 'deps-analyzer',
  tools: [analyzeDeps],
})
```

---

## 4. 多 Agent 并行协作

大型项目的一个高效策略：**多个 Agent 同时工作。**

### 手动启动多会话

```bash
# 终端 1：重构用户模块
opencode --session "refactor-users"

# 终端 2：编写测试
opencode --session "write-tests"

# 终端 3：写文档
opencode --session "write-docs"
```

每个会话独立工作，互不干扰。

### 分工策略

| Agent | 任务 | 输出 |
|-------|------|------|
| Agent A | 重构核心逻辑 | 修改 `src/core/` |
| Agent B | 更新类型定义 | 修改 `src/types/` |
| Agent C | 修复已有测试 | 修改 `__tests__/` |
| 你（协调者） | Review 合并 | 逐个 Review |

### 注意事项

- **锁文件：** 不要让两个 Agent 同时修改同一个文件
- **先对齐接口：** 多个 Agent 工作前，先确定好接口定义
- **分治原则：** 按模块/功能拆分，不按文件拆分

---

## 5. 权限规则（Permissions）

企业环境中需要精细控制 AI 能做什么、不能做什么。

```json
{
  "permissions": [
    {
      "path": "src/db/schema.prisma",
      "allow": ["read"],
      "reason": "数据库 Schema 只能读不能改"
    },
    {
      "path": "src/config/production.json",
      "deny": ["read", "write"],
      "reason": "生产配置需要手动审核"
    },
    {
      "path": ".env*",
      "deny": ["read", "write"],
      "reason": "环境变量包含密钥"
    },
    {
      "command": ["git push"],
      "deny": true,
      "reason": "不允许 AI 直接推送"
    }
  ]
}
```

权限规则帮助敏感项目安全地使用 AI。

---

## 6. 网络模式 & 企业级配置

### Network Mode

企业内网环境或有代理限制时，配置网络模式：

```json
{
  "network": {
    "proxy": "http://proxy.company.com:8080",
    "allowedHosts": ["api.opencode.ai", "*.openai.com"],
    "blockedHosts": ["*.malicious.com"],
    "timeout": 30000
  }
}
```

### 企业配置

```json
{
  "enterprise": {
    "logLevel": "debug",
    "auditLog": "/var/log/opencode/audit.json",
    "allowedProviders": ["zen", "anthropic", "openai"],
    "maxConcurrentSessions": 10,
    "sessionTimeout": 3600000,
    "dataRetention": "7d"
  }
}
```

---

## 7. GitHub/GitLab 深度集成

### GitHub 集成

```bash
/connect github
```

配置后 AI 可以：
- 读取 Issues / PRs
- 创建 / Review PRs
- 触发 CI / CD

```
查看 Issue #42，实现它，然后创建 PR
```

### GitLab 集成

```bash
/connect gitlab
```

AI 可以操作 GitLab Merge Requests、CI pipelines 等。

### CI/CD 自动化工作流

```yaml
# .github/workflows/opencode-review.yml
name: OpenCode Code Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: AI Review
        run: opencode review --diff --github-token ${{ secrets.GITHUB_TOKEN }}
```

---

## 8. 分享链接 & 团队协作

### 生成分享链接

```bash
/share
```

这会生成一个 URL，复制到剪贴板。其他人打开后可以看到完整的对话历史。

分享链接默认 7 天有效，适合临时协作。需要长期保存可以导出会话文件：

```bash
/transcript  # 导出当前会话完整记录
```

### 协作工作流

```
1. 开发者 A 用 OpenCode 排查 Bug
2. 发现问题后，/share 生成链接
3. 把链接发到团队群
4. 开发者 B 打开链接，看到完整排查过程
5. 开发者 B 直接在链接基础上继续分析
```

### 导出与存档

会话文件存储在本地 `~/.opencode/sessions/` 目录，可以备份或迁移：

| 用途 | 操作 |
|------|------|
| 分享当前会话 | `/share` 生成链接 |
| 导出到本地 | 复制 `~/.opencode/sessions/` 下对应文件 |
| 恢复历史会话 | 将备份的会话文件放回同一目录 |

### 协作工作流

```
1. 开发者 A 用 OpenCode 排查 Bug
2. 发现问题后，/share 生成链接
3. 把链接发到团队群
4. 开发者 B 打开链接，看到完整排查过程
5. 开发者 B 直接在链接基础上继续分析
```

### 适用场景

- Code Review 讨论
- Bug 排查过程记录
- 架构设计决策记录
- 新人培训素材

---

## 9. ACP 支持 & 自定义模型

### ACP（Agent Communication Protocol）

ACP 允许不同 AI Agent 之间通信。OpenCode 支持 ACP，可以和其他 ACP 兼容的 Agent 协作。

```json
{
  "acp": {
    "enabled": true,
    "port": 9090,
    "allowedPeers": ["opencode://team-agent-1", "opencode://team-agent-2"]
  }
}
```

### 自定义模型

配置企业自建模型或任何兼容 OpenAI API 的模型：

```json
{
  "models": {
    "my-custom-model": {
      "provider": "openai-compatible",
      "baseUrl": "https://internal-llm.company.com/v1",
      "apiKey": "$INTERNAL_LLM_KEY",
      "models": {
        "default": "company-llm-v2",
        "fast": "company-llm-lite"
      }
    }
  }
}
```

---

## 10. 性能调优与疑难排查

### 常用调试命令

| 命令 | 作用 |
|------|------|
| `/status` | 查看当前会话状态（模型、上下文用量、文件修改） |
| `/reload` | 重新加载所有配置文件 |
| `/debug` | 进入调试模式，显示 AI 内部推理过程 |
| `/log` | 查看当前会话日志 |
| `/history` | 查看对话历史 |
| `/transcript` | 导出完整会话记录 |

> 启动时加 `--verbose` 可以看到更详细的配置加载和 API 调用日志。

### 常见问题排查

**AI 响应太慢？**

```json
{
  "models": {
    "default": {
      "model": "claude-sonnet-4-20250515",
      "maxTokens": 4096,
      "temperature": 0
    }
  }
}
```
- 调低 `maxTokens`
- 使用 `fast` 模型做简单任务
- 检查网络延迟

**AI 频繁产生幻觉？**

- 在 AGENTS.md 中提供更多上下文和示例
- 降低 `temperature` 参数（推荐 0）
- 使用 LSP 让 AI 理解代码类型

**配置不生效？**

```bash
opencode --verbose  # 启动详细日志
```

查看输出中的配置加载路径，确认修改的文件位置正确。

---

## 11. 社区与资源

| 资源 | 链接 |
|------|------|
| GitHub | [github.com/anomalyco/opencode](https://github.com/anomalyco/opencode) |
| 官方文档 | [opencode.ai/docs](https://opencode.ai/docs) |
| Discord | [opencode.ai/discord](https://opencode.ai/discord) |
| 官方博客 | [opencode.ai/blog](https://opencode.ai/blog) |

### 贡献指南

OpenCode 是开源项目，欢迎贡献：

```bash
git clone https://github.com/anomalyco/opencode.git
cd opencode
npm install
npm run dev
```

查看 [CONTRIBUTING.md](https://github.com/anomalyco/opencode/blob/main/CONTRIBUTING.md) 了解贡献流程。

---

## 结语

从初级篇的"第一次对话"，到中级篇的"AGENTS.md 与 MCP 配置"，再到高级篇的"自定义工具与企业级部署"——你已经完整掌握了 OpenCode 的使用之道。

**回顾三篇的核心思想：**

- **初级：** 把他当队友，用自然语言交流
- **中级：** 给他配装备，用配置文件武装 AI
- **高级：** 让他学会你的规范，用工具和技能扩展能力

OpenCode 最强大的地方不是它现在能做什么，而是**你可以不断扩展它能做什么**。

> 📖 想温习基础？回到 [初级篇](opencode-guide-part1-beginner.md) 或 [中级篇](opencode-guide-part2-intermediate.md)。