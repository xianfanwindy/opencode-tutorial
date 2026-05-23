# OpenCode 教程 · 初级篇：你好，OpenCode

> **适合读者：** 第一次接触 OpenCode，零基础
> **目标：** 从安装到完成第一次代码修改

---

## 1. OpenCode 是什么？

一句话：**OpenCode 是一个在终端里帮你写代码的 AI 助手。**

它是开源项目（GitHub 160K+ Stars），运行在命令行中，能理解你的整个项目代码库，帮你读代码、改代码、加功能、找 Bug。

**不是什么？** 不是 IDE 插件（虽然有），不是网页聊天框，不是 Copilot 替代品。它是一个**自主行动的 AI Agent**——给它一个任务，它会自己读代码、写代码、运行命令。

---

## 2. 安装

### 一键安装（推荐）

```bash
curl -fsSL https://opencode.ai/install | bash
```

### 其他方式

| 方式 | 命令 |
|------|------|
| npm | `npm install -g opencode-ai` |
| Homebrew (macOS/Linux) | `brew install anomalyco/tap/opencode` |
| Scoop (Windows) | `scoop install opencode` |
| Chocolatey (Windows) | `choco install opencode` |
| Pacman (Arch Linux) | `sudo pacman -S opencode` |
| Docker | `docker run -it --rm ghcr.io/anomalyco/opencode` |

安装完成后，终端输入 `opencode` 验证：

```bash
opencode --version
```

---

## 3. 首次启动

### 第一步：进到项目目录

```bash
cd /your/project
opencode
```

你会看到一个终端界面（TUI），顶部有输入框，底部有状态栏。

### 第二步：连接模型

输入 `/connect`，选择提供商。

**如果你是第一次用 AI 编程，推荐 OpenCode Zen**：

1. 输入 `/connect` 并回车
2. 选择 `opencode`
3. 浏览器打开 [opencode.ai/auth](https://opencode.ai/auth)
4. 注册、添加支付方式、复制 API Key
5. 粘贴到终端

> Zen 是 OpenCode 团队精选的模型列表，经过测试和验证，开箱即用。

**如果你已经有 Claude / GPT / Gemini 等账号**：
选择对应的提供商，输入你的 API Key 即可。

### 第三步：初始化项目

```bash
/init
```

OpenCode 会自动分析项目结构，生成一个 `AGENTS.md` 文件。

这个文件记录了项目的技术栈、目录结构、编码规范等信息。**建议提交到 Git**——这样以后每次打开 OpenCode，AI 都能快速了解你的项目。

```
项目根目录/
├── src/
├── package.json
├── AGENTS.md   ← 新生成的
└── ...

### 第四步：退出与帮助

知道如何退出和求助同样重要：

| 操作 | 作用 |
|------|------|
| `Ctrl+C` | 中断当前 AI 响应 |
| `/exit` | 退出 OpenCode |
| `/help` | 查看所有可用命令 |

> 任何时候遇到问题，先试 `/help`，它会列出当前会话所有可用命令。

---

## 4. 第一次对话

### 提问

用 `@` 引用文件，让 AI 精准定位：

```
@src/main.ts 这个文件是做什么的？
```

AI 会读取文件内容并给你解释。

### 修 Bug

```
@src/utils/format.ts 里的 formatDate 函数有问题，
当传入 null 时会报错，请修复。
```

AI 会：
1. 读取代码理解上下文
2. 修改代码
3. 告诉你改了什么

### 不满意？撤销！

```bash
/undo
```

> 可以多次 `/undo` 撤销多步修改，也可以用 `/redo` 重做。

---

## 5. Plan 模式 vs Build 模式

这是 OpenCode 最核心的概念之一。

| 模式 | 作用 | 切换方式 |
|------|------|----------|
| **Build** | 直接读代码、改代码 | 默认模式 |
| **Plan** | 只讨论方案，不动代码 | 按 `Tab` 键 |

**工作流建议：**

```
你：按 Tab 进入 Plan 模式
你："帮我加一个用户注册功能"
AI：输出实施方案，不改代码
你："可以，加一条：用邮箱验证"
AI：更新方案
你：按 Tab 回到 Build 模式
你："开始实现"
AI：动手写代码
```

这让 AI 像一个靠谱的队友——先对齐方案，再动手执行。

---

## 6. 会话与历史

OpenCode 会自动保存你的对话历史，每次启动都能看到之前的上下文。

### 撤销与重做

```bash
/undo   # 撤销上一步修改（可多次执行）
/redo   # 重做被撤销的修改
```

`/undo` 不只撤销对话，而是**撤销文件修改**。改错了随手 `/undo`，不用手动回滚代码。

### 查看历史

```bash
/history     # 查看当前会话命令历史
/transcript  # 查看完整对话记录
```

### 多会话管理

你可以在不同终端窗口启动多个独立的 OpenCode 会话，互不干扰：

```bash
# 终端 1 — 开发功能
opencode

# 终端 2 — 做 Code Review
opencode --session "review"
```

每个会话有独立的上下文和修改记录，适合同时处理多个任务。

> 会话历史保存在 `~/.opencode/sessions/` 目录下，可以随时回溯。

---

## 7. 完整实战：改第一行代码

让我们用一个真实场景走一遍完整流程。

### 场景

项目里有一个 `greet.ts` 文件，内容是：

```typescript
function greet(name: string) {
  return "Hello, " + name
}
```

我们希望改成支持可选的语言参数。

### 操作

**Step 1**：启动 OpenCode

```bash
cd /path/to/project
opencode
```

**Step 2**：按 `Tab` 进入 Plan 模式

```
我想给 greet 函数加一个 language 参数，
当 language 为 "zh" 时返回中文问候。
先给个方案看看。
```

AI 会给出修改方案。

**Step 3**：按 `Tab` 回到 Build 模式

```
方案可以，开始实现。
```

AI 会自动修改代码。

**Step 4**：验证

```
greet("张三", "zh") 应该返回什么？
```

AI 会解释执行结果。

**Step 5**：如果不对，撤销

```bash
/undo
```

---

## 8. 初学者常见问题

### Q: 需要 GPU 吗？
不需要。AI 模型跑在云端，你的电脑只需要终端。

### Q: 代码会泄露吗？
OpenCode 不存储你的代码。代码发送给模型提供商处理，选择可信的提供商即可。

### Q: 为什么 AI 不理解我的项目？
先运行 `/init` 生成 AGENTS.md。如果还不满意，可以手动编辑 AGENTS.md 补充项目信息。

### Q: 可以多个项目切换吗？
可以。在项目 A 中退出（`/exit`），进入项目 B 目录再运行 `opencode`。

### Q: 可以在无网络环境使用吗？
可以，需配合本地模型（如 llama.cpp、Ollama）。在 `/connect` 中选择本地提供商即可。

### Q: 支持中文对话吗？
完全支持。用中文描述需求，AI 用中文回复。

---

## 9. 下篇预告

你已经学会了 OpenCode 的基本操作。下一步：

- **中级篇**：AGENTS.md 编写、自定义命令、MCP 服务器、高效 Prompt 技巧
- **高级篇**：自定义工具、Plugin 开发、多 Agent 协作、企业级配置

继续学习 → [中级篇](opencode-guide-part2-intermediate.md)

> 也可以直接跳转到 [高级篇](opencode-guide-part3-advanced.md)，但建议按顺序阅读。

---

> **小贴士：** 遇到问题可以去 [OpenCode Discord](https://opencode.ai/discord) 社区求助，或者在 GitHub 提 Issue。