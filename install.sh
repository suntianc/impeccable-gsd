#!/bin/bash

# GSD × Impeccable 整合安装脚本
# 使用方法: bash install.sh

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD × Impeccable Integration Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查依赖
echo "🔍 检查依赖..."

# 检查 GSD
if [ ! -d "$HOME/.claude/get-shit-done" ]; then
    echo -e "${RED}❌ GSD 未安装${NC}"
    echo "请先安装 GSD: https://github.com/nicepkg/gsd"
    exit 1
fi
echo -e "${GREEN}✓ GSD 已安装${NC}"

# 检查 Claude Code skills 目录
if [ ! -d "$HOME/.claude/skills" ]; then
    echo -e "${YELLOW}⚠ 创建 Claude skills 目录${NC}"
    mkdir -p "$HOME/.claude/skills"
fi

# 检查 cc-switch skills 目录
if [ ! -d "$HOME/.cc-switch/skills" ]; then
    echo -e "${YELLOW}⚠ 创建 cc-switch skills 目录${NC}"
    mkdir -p "$HOME/.cc-switch/skills"
fi

echo ""
echo "📦 安装 Impeccable..."

# 安装 Impeccable
if [ -d "$HOME/.claude/skills/impeccable" ]; then
    echo -e "${YELLOW}⚠ Impeccable 已存在，跳过安装${NC}"
else
    # 从源码目录复制
    if [ -d "$HOME/.codebuddy/skills-marketplace/skills/impeccable" ]; then
        cp -r "$HOME/.codebuddy/skills-marketplace/skills/impeccable" "$HOME/.cc-switch/skills/"
        ln -sf "$HOME/.cc-switch/skills/impeccable" "$HOME/.claude/skills/impeccable"
        echo -e "${GREEN}✓ Impeccable 安装成功${NC}"
    else
        echo -e "${RED}❌ 找不到 Impeccable 源码${NC}"
        echo "请确保 ~/.codebuddy/skills-marketplace/skills/impeccable 存在"
        exit 1
    fi
fi

echo ""
echo "🤖 安装 Impeccable 代理..."

# 安装代理
cp agents/gsd-impeccable-executor.md "$HOME/.claude/agents/"
cp agents/gsd-impeccable-reviewer.md "$HOME/.claude/agents/"
echo -e "${GREEN}✓ gsd-impeccable-executor 安装成功${NC}"
echo -e "${GREEN}✓ gsd-impeccable-reviewer 安装成功${NC}"

echo ""
echo "🔧 更新 GSD 技能..."

# 更新 gsd-execute-phase
cp skills/gsd-execute-phase/SKILL.md "$HOME/.cc-switch/skills/gsd-execute-phase/"
echo -e "${GREEN}✓ gsd-execute-phase 已更新${NC}"

# 更新 gsd-code-review
cp skills/gsd-code-review/SKILL.md "$HOME/.cc-switch/skills/gsd-code-review/"
echo -e "${GREEN}✓ gsd-code-review 已更新${NC}"

# 更新 gsd-sketch
cp skills/gsd-sketch/SKILL.md "$HOME/.cc-switch/skills/gsd-sketch/"
echo -e "${GREEN}✓ gsd-sketch 已更新${NC}"

echo ""
echo "📋 更新 GSD 工作流..."

# 更新 execute-phase.md
cp workflows/execute-phase.md "$HOME/.claude/get-shit-done/workflows/"
echo -e "${GREEN}✓ execute-phase.md 已更新${NC}"

# 更新 code-review.md
cp workflows/code-review.md "$HOME/.claude/get-shit-done/workflows/"
echo -e "${GREEN}✓ code-review.md 已更新${NC}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ 安装完成！${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 下一步："
echo "1. 在项目中运行 'gsd-ui-phase <phase>' 初始化设计上下文"
echo "2. 运行 'gsd-execute-phase <phase>' 执行包含 UI 的阶段"
echo "3. 运行 'gsd-code-review <phase>' 审查代码（自动分流前端/后端）"
echo ""
echo "📚 详细文档："
echo "- README.md - 项目介绍"
echo "- CONFIG-GUIDE.md - 配置指南"
echo "- INTEGRATION-DESIGN.md - 架构设计"
echo ""
echo "🎨 祝您使用愉快！"
