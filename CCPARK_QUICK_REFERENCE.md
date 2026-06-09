# CCPark 快速参考卡

## ⚡ 最常用命令（复制粘贴）

### 启动（最简单）
```bash
ccpark
```

### 启动特定 Agent
```bash
ccpark copilot    # Copilot
ccpark gemini     # Gemini
ccpark opencode   # OpenCode
```

### 无交互运行（自动化）
```bash
ccpark run claude -p "你的任务" --max-turns 5
```

### 管理
```bash
ccpark status      # 检查状态
ccpark stop        # 停止后台进程
ccpark stats       # 查看使用统计
ccpark upgrade     # 升级
```

---

## 📍 快速启动脚本

已创建启动脚本在 `scripts/ccpark-quick-start.sh`

```bash
# 最简单的启动方式
./scripts/ccpark-quick-start.sh

# 启动 Copilot
./scripts/ccpark-quick-start.sh copilot

# 检查状态
./scripts/ccpark-quick-start.sh status
```

---

## 🔨 配置别名（可选）

在 `~/.bashrc` 或 `~/.zshrc` 中添加：

```bash
# CCPark 别名
alias cc='ccpark'
alias cc:claude='ccpark'
alias cc:copilot='ccpark copilot'
alias cc:status='ccpark status'
alias cc:stop='ccpark stop'
```

然后刷新配置：
```bash
source ~/.bashrc  # or source ~/.zshrc
```

现在可以这样使用：
```bash
cc                    # 启动 Claude
cc:copilot           # 启动 Copilot
cc:status            # 检查状态
```

---

## 📊 配置文件位置

```
~/.ccpark/          # 主配置目录
~/.ccpark/debug.log # 调试日志
```

---

## 💡 一行启动命令

| 目的 | 命令 |
|------|------|
| 启动 Claude | `ccpark` |
| 运行任务 | `ccpark run claude -p "task"` |
| 启动 Copilot | `ccpark copilot` |
| 查看状态 | `ccpark status` |
| 停止服务 | `ccpark stop` |
| 查看帮助 | `ccpark help` |

---

## 🎯 使用流程

### 场景 1: 代码分析
```bash
ccpark
# 输入: "分析 src/ 目录的代码质量"
# 获得反馈
```

### 场景 2: 自动化任务
```bash
ccpark run claude -p "运行测试并报告结果" --max-turns 3
```

### 场景 3: 编码辅助（Copilot）
```bash
ccpark copilot
# 输入: "为这个函数添加类型注解"
```

---

## 🚨 常见问题

**Q: 如何停止正在运行的会话？**
```bash
# 在交互式会话中按 Ctrl+C
# 或在另一个终端运行
ccpark stop
```

**Q: 如何查看之前的会话？**
```bash
# 恢复之前的会话（如果知道 session ID）
ccpark --resume <session-id>

# 查看统计（包括历史会话）
ccpark stats
```

**Q: 如何启用调试模式？**
```bash
ccpark debug on
# 查看日志
tail -f ~/.ccpark/debug.log
```

**Q: 如何更新 CCPark？**
```bash
ccpark upgrade
# 或手动更新
npm install -g ccpark@latest
```

---

## 📌 记住这 3 个命令

最基本的三个命令：

```bash
ccpark                    # 启动（最常用）
ccpark status             # 检查状态
ccpark stop               # 停止服务
```

---

**安装时间**: 2026-06-09  
**版本**: 0.0.46  
**状态**: ✅ 已安装并就绪
