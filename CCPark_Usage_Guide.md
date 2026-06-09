# CCPark 使用指南

## 📦 安装状态
✅ **已安装** - `npm install -g ccpark` (v0.0.46)

---

## 🚀 快速启动

### 最简单的方式（推荐）
```bash
ccpark
```
- 启动 Claude 本地模式
- 交互式终端 + web 同步
- 无需配置，开箱即用

### 其他 Agent
```bash
ccpark copilot      # Copilot 远程模式
ccpark opencode     # OpenCode
ccpark codex        # Codex
ccpark gemini       # Gemini
ccpark hermes       # Hermes
ccpark openclaw     # OpenClaw
```

---

## 📋 常用命令

| 命令 | 功能 | 示例 |
|------|------|------|
| `ccpark` | 启动 Claude 默认模式 | `ccpark` |
| `ccpark <agent>` | 启动指定 agent | `ccpark copilot` |
| `ccpark run <agent> -p <prompt>` | 远程运行（无交互） | `ccpark run claude -p "解释这个项目"` |
| `ccpark pair` | 配对新设备（二维码 + PIN） | `ccpark pair` |
| `ccpark status` | 检查后台进程状态 | `ccpark status` |
| `ccpark stats` | 查看 AI agent 使用统计 | `ccpark stats` |
| `ccpark stats --json` | 导出 JSON 格式统计 | `ccpark stats --json` |
| `ccpark stop` | 停止后台守护进程 | `ccpark stop` |
| `ccpark debug on\|off` | 启用/禁用调试模式 | `ccpark debug on` |
| `ccpark upgrade` | 升级到最新版本 | `ccpark upgrade` |

---

## ⚙️ 高级选项

### 会话配置
```bash
# 自定义会话名称
ccpark --name "my-session"

# 指定模型
ccpark --model gpt-4

# 恢复之前的会话
ccpark --resume <session-id>

# 使用配置文件
ccpark --profile production
```

### 远程运行（Headless）
```bash
# 运行 n 轮对话后自动停止
ccpark run claude -p "fix bugs" --max-turns 5

# 指定工作目录
ccpark run claude -p "audit code" --cwd /path/to/project

# 追加系统提示
ccpark run claude -p "task" --append-system-prompt "Be concise"
```

### 权限和服务器
```bash
# 修改权限模式
ccpark --permission-mode restricted

# 使用自定义服务器
ccpark --server https://custom-server.com

# 提供认证令牌
ccpark --token YOUR_TOKEN_HERE
```

---

## 🔐 配置文件位置

所有配置和状态数据存储在：
```
~/.ccpark/
```

使用 `--profile` 时，配置存储在：
```
~/.ccpark/profiles/<profile-name>/
```

---

## 💡 使用场景

### 场景 1: 快速启动分析代码
```bash
ccpark
# 在交互式终端中输入任务
```

### 场景 2: 自动化任务（CI/CD）
```bash
ccpark run claude -p "Run tests and report results" --max-turns 3
```

### 场景 3: 特定 Agent 任务
```bash
ccpark copilot
# 使用 Copilot 进行编码辅助
```

### 场景 4: 多设备协作
```bash
ccpark pair     # 在一个设备上配对
ccpark          # 在其他设备上启动，自动同步
```

---

## 📊 查看状态和统计

```bash
# 检查后台进程
ccpark status

# 查看使用统计
ccpark stats

# 查看详细的 JSON 统计
ccpark stats --json | jq .
```

---

## 🛑 停止和管理

```bash
# 停止后台守护进程
ccpark stop

# 启用调试模式排查问题
ccpark debug on

# 查看调试日志
cat ~/.ccpark/debug.log

# 禁用调试
ccpark debug off
```

---

## 🔄 更新和维护

```bash
# 查看当前版本
ccpark --version

# 升级到最新版本
ccpark upgrade

# 卸载
npm uninstall -g ccpark
```

---

## 📌 最常用的启动方式

根据使用场景选择：

### 开发/探索
```bash
ccpark
```
按回车启动，交互式输入任务

### 自动化运行
```bash
ccpark run claude -p "your task here" --max-turns 5
```

### 使用特定 Agent
```bash
ccpark copilot --name "coding-session"
```

---

## 🆘 故障排除

```bash
# 启用调试模式
ccpark debug on

# 停止并重启
ccpark stop
ccpark

# 检查配置
ls -la ~/.ccpark/

# 重新配置设备
ccpark pair
```

---

## 📍 更新于
2026-06-09

## 📦 版本
ccpark@0.0.46
