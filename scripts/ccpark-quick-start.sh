#!/bin/bash

# CCPark 快速启动脚本
# 用法: ./ccpark-quick-start.sh [agent] [options]

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  CCPark AI Agent 远程控制台${NC}"
echo -e "${BLUE}========================================${NC}\n"

# 检查 ccpark 是否安装
if ! command -v ccpark &> /dev/null; then
    echo -e "${YELLOW}❌ ccpark 未安装${NC}"
    echo "正在全局安装 ccpark..."
    npm install -g ccpark
    echo -e "${GREEN}✅ ccpark 安装完成${NC}\n"
fi

# 显示当前版本
echo -e "${BLUE}📦 版本信息:${NC}"
ccpark --version
echo ""

# 检查守护进程状态
echo -e "${BLUE}🔍 检查守护进程状态:${NC}"
if ccpark status 2>&1 | grep -q "not running"; then
    echo -e "${YELLOW}ℹ️  后台进程未启动（首次启动时自动启动）${NC}"
else
    echo -e "${GREEN}✅ 后台进程正在运行${NC}"
fi
echo ""

# 显示可用的 agent
echo -e "${BLUE}🤖 可用的 Agent:${NC}"
echo "  • claude (默认 - 本地模式)"
echo "  • copilot (远程模式)"
echo "  • opencode"
echo "  • codex"
echo "  • gemini"
echo "  • hermes"
echo "  • openclaw"
echo ""

# 处理参数
if [ $# -eq 0 ]; then
    # 没有参数，启动默认的 Claude
    echo -e "${GREEN}🚀 启动 Claude (本地模式)...${NC}\n"
    ccpark
elif [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "用法: ./ccpark-quick-start.sh [agent] [options]"
    echo ""
    echo "示例:"
    echo "  ./ccpark-quick-start.sh              # 启动 Claude"
    echo "  ./ccpark-quick-start.sh copilot     # 启动 Copilot"
    echo "  ./ccpark-quick-start.sh status      # 检查状态"
    echo "  ./ccpark-quick-start.sh stats       # 查看统计"
    echo "  ./ccpark-quick-start.sh stop        # 停止守护进程"
    echo ""
    ccpark help
elif [ "$1" == "status" ] || [ "$1" == "stats" ] || [ "$1" == "stop" ] || [ "$1" == "upgrade" ] || [ "$1" == "debug" ] || [ "$1" == "pair" ]; then
    # 直接传递给 ccpark
    echo -e "${GREEN}🔄 执行: ccpark $@${NC}\n"
    ccpark "$@"
else
    # 启动指定的 agent 或运行指定命令
    echo -e "${GREEN}🚀 启动: ccpark $@${NC}\n"
    ccpark "$@"
fi
