# 🎨 GSD × Impeccable 整合项目

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Impeccable v2.0.0](https://img.shields.io/badge/Impeccable-v2.0.0-purple.svg)](https://github.com/pbakaus/impeccable)

> **GSD 为项目管理主入口，Impeccable 完全接管 UI/前端工作**

一个将 [Get Shit Done (GSD)](https://github.com/nicepkg/gsd) 项目管理系统与 [Impeccable](https://github.com/pbakaus/impeccable) 高品质前端设计工具集深度融合的整合方案。

---

## ✨ 核心特性

### 🎯 模式切换架构

```
GSD 主流程
    ↓
检测 UI 任务
    ↓
切换到 Impeccable 模式
    ↓
Impeccable 完全接管
    ↓
回流到 GSD 继续
```

### 🤖 智能代理系统

- **gsd-impeccable-executor** - 使用 Impeccable 设计原则执行 UI 计划
- **gsd-impeccable-reviewer** - 使用 Impeccable 标准审查前端代码

### 🔍 自动任务检测

**检测规则（可配置）：**
- 文件扩展名：`.tsx`, `.jsx`, `.vue`, `.css`, `.scss` 等
- 路径模式：`components/`, `pages/`, `styles/` 等
- 关键词：`component`, `UI`, `interface`, `layout` 等
- 计划类型：`ui`, `frontend`, `design`

### 📊 设计质量评估

- 排版系统评分 (Typography)
- 色彩与对比度评分 (Color & Contrast)
- 布局与空间评分 (Layout & Spacing)
- 响应式设计评分 (Responsiveness)
- 动效与交互评分 (Animation & Motion)
- 无障碍评分 (Accessibility)
- **AI Slop 测试** (PASS/FAIL)

---

## 🚀 快速开始

### 1. 安装依赖

**GSD:** 参考 [GSD 安装指南](https://github.com/nicepkg/gsd)

**Impeccable:** 已包含在本项目中，自动安装到 `~/.claude/skills/impeccable/`

### 2. 初始化项目设计上下文

```bash
# 在项目根目录运行
gsd-ui-phase <phase-number>
```

这会创建 `.impeccable.md` 并收集设计上下文（目标用户、品牌调性、美学方向等）。

### 3. 执行包含 UI 的阶段

```bash
gsd-execute-phase <phase-number>
```

系统会自动：
- ✅ 检测 UI 计划（基于文件、关键词、标签）
- ✅ 派生 `gsd-impeccable-executor` 代理执行 UI 计划
- ✅ 继续使用 `gsd-executor` 执行后端计划
- ✅ 汇总结果并更新进度

### 4. 代码审查自动分流

```bash
gsd-code-review <phase-number>
```

系统会自动：
- ✅ 分类前端/后端文件
- ✅ 前端文件使用 `gsd-impeccable-reviewer` 审查
- ✅ 后端文件使用 `gsd-code-reviewer` 审查
- ✅ 合并审查报告

---

## 📁 项目结构

```
gsd-impeccable/
├── README.md                      # 本文件
├── LICENSE                        # Apache 2.0 许可证
├── INTEGRATION-DESIGN.md          # 完整架构设计文档
└── CONFIG-GUIDE.md                # 详细配置指南

~/.claude/agents/
├── gsd-impeccable-executor.md     # Impeccable 执行代理
└── gsd-impeccable-reviewer.md     # Impeccable 审查代理

~/.claude/skills/
└── impeccable/                    # Impeccable 技能（30+ 参考文档）
    ├── SKILL.md
    └── references/
        ├── typography.md          # 排版系统
        ├── color-and-contrast.md  # 色彩与对比度
        ├── spatial-design.md      # 空间设计
        ├── motion-design.md       # 动效设计
        ├── accessibility.md       # 无障碍设计
        └── ... (25+ 更多参考文档)

~/.claude/get-shit-done/workflows/
├── execute-phase.md               # 修改：添加 Impeccable 委托
└── code-review.md                 # 修改：添加前端/后端分离

~/.cc-switch/skills/
├── gsd-execute-phase/SKILL.md     # 修改：添加 UI 计划检测
├── gsd-code-review/SKILL.md       # 修改：添加文件分类
└── gsd-sketch/SKILL.md            # 修改：集成 Impeccable 原则
```

---

## 🔧 配置

### 基础配置

在 `.planning/config.json` 中添加：

```json
{
  "impeccable": {
    "enabled": true,
    "auto_detect_ui_tasks": true,
    "design_context_path": ".impeccable.md"
  }
}
```

### 自定义检测规则

```json
{
  "impeccable": {
    "detection_rules": {
      "file_extensions": [".tsx", ".jsx", ".vue", ".css"],
      "path_patterns": ["src/components/", "src/pages/"],
      "keywords": ["component", "UI", "interface"],
      "plan_types": ["ui", "frontend", "design"]
    }
  }
}
```

详细配置请参考 [CONFIG-GUIDE.md](CONFIG-GUIDE.md)

---

## 🎨 Impeccable 设计原则

### 核心理念

❌ **避免 AI Slop:**
- 不使用 Inter/Roboto/Arial 字体
- 不使用默认深色模式 + 发光效果
- 不使用紫蓝渐变
- 不使用霓虹点缀色

✅ **Impeccable 美学:**
- 独特的展示字体 + 精致的正文字体
- 使用 `clamp()` 的流体排版
- 使用 `oklch`/`color-mix` 的色彩系统
- 变化的间距创造视觉节奏
- 有目的性的动画和微交互

### 设计上下文

每个项目都需要 `.impeccable.md` 文件定义：

- **Target Audience** - 谁使用这个产品？
- **Use Cases** - 他们要完成什么任务？
- **Brand Personality** - 界面应该给人什么感觉？
- **Aesthetic Direction** - 选择什么美学方向？

---

## 📚 文档

- **[INTEGRATION-DESIGN.md](INTEGRATION-DESIGN.md)** - 完整架构设计
  - 状态机设计
  - 模式切换协议
  - 检测规则详解
  - 测试场景

- **[CONFIG-GUIDE.md](CONFIG-GUIDE.md)** - 配置指南
  - 快速开始
  - 配置详解
  - 使用示例
  - 故障排查
  - 最佳实践

---

## 🧪 测试

### 测试 UI 计划自动检测

```bash
# 创建包含 UI 任务的阶段
gsd-execute-phase 3

# 观察日志输出
# 🎨 Plan 01-02 identified as UI work — delegating to Impeccable executor
```

### 测试前端代码审查

```bash
# 审查包含前端文件的阶段
gsd-code-review 3

# 观察日志输出
# 🎨 Frontend files detected — delegating to Impeccable reviewer
# File Classification:
#   Frontend: 5 files
#   Backend: 3 files
```

### 测试 UI 草图生成

```bash
# 使用 gsd-sketch 生成草图
gsd-sketch "创建一个现代风格的登录表单"

# 观察是否应用了 Impeccable 设计原则
```

---

## 🤝 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

---

## 📄 许可证

本项目基于 [Apache License 2.0](LICENSE) 许可证。

**Impeccable** 基于 [Apache 2.0](https://github.com/pbakaus/impeccable/blob/main/LICENSE) 许可证，由 Paul Bakaus 创建。

**GSD** 基于其原有许可证。

---

## 🙏 致谢

- [Impeccable](https://github.com/pbakaus/impeccable) - 高品质前端设计工具集
- [Get Shit Done (GSD)](https://github.com/nicepkg/gsd) - 项目管理系统
- [Anthropic](https://www.anthropic.com/) - Claude AI 技术支持

---

## 📧 联系方式

- GitHub: [@suntianc](https://github.com/suntianc)
- 项目链接: [https://github.com/suntianc/impeccable-gsd](https://github.com/suntianc/impeccable-gsd)

---

**Made with ❤️ by Suntc**
