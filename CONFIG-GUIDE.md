# GSD × Impeccable 整合配置指南

## 快速开始

### 1. 确保 Impeccable 已安装

```bash
# 检查 Impeccable 是否已安装
ls -la ~/.claude/skills/impeccable/

# 如果没有安装，从源码安装
cp -r ~/.codebuddy/skills-marketplace/skills/impeccable ~/.cc-switch/skills/
ln -s ~/.cc-switch/skills/impeccable ~/.claude/skills/impeccable
```

### 2. 初始化项目设计上下文

在项目根目录运行：

```bash
# 如果项目还没有 .impeccable.md
gsd-ui-phase <phase-number>
```

这会自动创建 `.impeccable.md` 并收集设计上下文。

### 3. 配置 GSD 项目

在 `.planning/config.json` 中添加以下配置：

```json
{
  "impeccable": {
    "enabled": true,
    "auto_detect_ui_tasks": true,
    "design_context_path": ".impeccable.md",
    "detection_rules": {
      "file_extensions": [
        ".tsx", ".jsx", ".vue", ".svelte",
        ".css", ".scss", ".sass", ".less",
        ".html", ".astro"
      ],
      "path_patterns": [
        "components/", "pages/", "views/",
        "layouts/", "styles/", "ui/"
      ],
      "keywords": [
        "component", "UI", "interface",
        "layout", "styling", "frontend",
        "responsive", "animation", "page",
        "view", "template", "design"
      ],
      "plan_types": ["ui", "frontend", "design"]
    }
  }
}
```

---

## 配置详解

### impeccable.enabled

**类型:** boolean
**默认值:** true
**说明:** 启用/禁用 GSD-Impeccable 整合

```json
{
  "impeccable": {
    "enabled": true  // false 则禁用整合，所有任务使用 gsd-executor
  }
}
```

### impeccable.auto_detect_ui_tasks

**类型:** boolean
**默认值:** true
**说明:** 是否自动检测 UI 任务

```json
{
  "impeccable": {
    "auto_detect_ui_tasks": true  // false 则需要手动标记 UI 任务
  }
}
```

当设为 `false` 时，需要在 PLAN.md 中明确标记：

```yaml
---
phase: 3
plan: 01
type: ui  # 必须明确标记
---
```

### impeccable.design_context_path

**类型:** string
**默认值:** ".impeccable.md"
**说明:** 设计上下文文件路径

```json
{
  "impeccable": {
    "design_context_path": ".impeccable.md"  // 可以自定义路径
  }
}
```

### impeccable.detection_rules

**类型:** object
**说明:** UI 任务检测规则

#### file_extensions

**类型:** string[]
**说明:** 前端文件扩展名列表

```json
{
  "detection_rules": {
    "file_extensions": [
      ".tsx", ".jsx", ".vue", ".svelte",  // 组件
      ".css", ".scss", ".sass", ".less",   // 样式
      ".html", ".astro"                    // 模板
    ]
  }
}
```

#### path_patterns

**类型:** string[]
**说明:** 前端文件路径模式

```json
{
  "detection_rules": {
    "path_patterns": [
      "components/",  // React/Vue 组件
      "pages/",       // Next.js 页面
      "views/",       // Vue 视图
      "layouts/",     // 布局组件
      "styles/",      // 样式文件
      "ui/"           // UI 组件库
    ]
  }
}
```

#### keywords

**类型:** string[]
**说明:** UI 任务关键词（不区分大小写）

```json
{
  "detection_rules": {
    "keywords": [
      "component", "UI", "interface",
      "layout", "styling", "frontend",
      "responsive", "animation", "page",
      "view", "template", "design"
    ]
  }
}
```

#### plan_types

**类型:** string[]
**说明:** 计划类型标记

```json
{
  "detection_rules": {
    "plan_types": ["ui", "frontend", "design"]
  }
}
```

在 PLAN.md 的 frontmatter 中使用：

```yaml
---
type: ui  # 匹配此类型的计划会派生 Impeccable 代理
---
```

---

## 使用示例

### 示例 1：标准 Web 应用项目

```json
{
  "impeccable": {
    "enabled": true,
    "auto_detect_ui_tasks": true,
    "design_context_path": ".impeccable.md",
    "detection_rules": {
      "file_extensions": [".tsx", ".jsx", ".css", ".scss"],
      "path_patterns": ["src/components/", "src/pages/", "src/styles/"],
      "keywords": ["component", "UI", "page", "layout"],
      "plan_types": ["ui", "frontend"]
    }
  }
}
```

### 示例 2：Vue.js 项目

```json
{
  "impeccable": {
    "enabled": true,
    "auto_detect_ui_tasks": true,
    "design_context_path": ".impeccable.md",
    "detection_rules": {
      "file_extensions": [".vue", ".css", ".scss"],
      "path_patterns": ["src/components/", "src/views/", "src/layouts/"],
      "keywords": ["component", "view", "page", "interface"],
      "plan_types": ["ui", "frontend"]
    }
  }
}
```

### 示例 3：手动控制模式

```json
{
  "impeccable": {
    "enabled": true,
    "auto_detect_ui_tasks": false,  // 禁用自动检测
    "design_context_path": ".impeccable.md"
  }
}
```

需要在 PLAN.md 中明确标记 UI 任务：

```yaml
---
phase: 3
plan: 01
type: ui  # 必须明确标记
---
```

---

## 工作流程

### 自动模式（推荐）

```
1. 用户运行 gsd-execute-phase
   ↓
2. GSD 发现计划并分析类型
   ↓
3. 检测规则自动识别 UI 计划
   ↓
4. UI 计划 → 派生 gsd-impeccable-executor
   后端计划 → 派生 gsd-executor
   ↓
5. 两个代理独立执行
   ↓
6. 结果汇总，继续流程
```

### 手动标记模式

```
1. 用户在 PLAN.md 中标记 type: ui
   ↓
2. 用户运行 gsd-execute-phase
   ↓
3. GSD 根据 type 字段派生对应代理
   ↓
4. 其余流程相同
```

---

## .impeccable.md 示例

```markdown
# Design Context

## Target Audience
- **Primary:** 25-45岁专业用户
- **使用场景:** 日常办公、数据分析
- **技术水平:** 中高级

## Use Cases
- 快速查看和分析数据
- 管理用户账户和权限
- 生成报告和可视化图表

## Brand Personality
- **Tone:** 专业但友好
- **Style:** 现代简约
- **Emotion:** 可信赖、高效

## Aesthetic Direction
- **风格:** 功能主义极简
- **色彩:** 中性色调 + 品牌蓝点缀
- **排版:** 清晰的层次，充足的留白
- **避免:** 过度装饰、毛玻璃滥用

## Design Tokens

### Typography
- **Display:** Clash Display (独特但专业)
- **Body:** DM Sans (清晰易读)
- **Mono:** JetBrains Mono (代码)

### Colors
- **Primary:** oklch(65% 0.15 250) (品牌蓝)
- **Neutral:** oklch(20% 0.02 250) (深色文本)
- **Background:** oklch(98% 0.005 250) (浅灰背景)

### Spacing
- **Unit:** 8px
- **Scale:** 0.5, 1, 1.5, 2, 3, 4, 6, 8, 12

## References
- 详细设计规范见 `references/` 目录
```

---

## 故障排查

### 问题：UI 计划没有派生 Impeccable 代理

**检查清单：**

1. **配置是否启用？**
   ```bash
   # 检查 config.json
   cat .planning/config.json | grep -A 5 "impeccable"
   ```

2. **.impeccable.md 是否存在？**
   ```bash
   ls -la .impeccable.md
   ```

3. **计划是否匹配检测规则？**
   - 检查文件扩展名是否在 `file_extensions` 中
   - 检查路径是否匹配 `path_patterns`
   - 检查目标或关键词是否包含 `keywords` 中的词
   - 检查 frontmatter 的 `type` 是否在 `plan_types` 中

4. **查看日志输出**
   ```
   🎨 Plan {id} identified as UI work — delegating to Impeccable executor
   ```
   如果没有看到这行日志，说明计划没有被识别为 UI 计划。

### 问题：Impeccable 代理执行失败

**常见原因：**

1. **.impeccable.md 不存在或格式错误**
   ```bash
   # 重新初始化
   gsd-ui-phase <phase-number>
   ```

2. **Impeccable 参考文档缺失**
   ```bash
   # 检查参考文档
   ls ~/.claude/skills/impeccable/references/
   ```

3. **权限问题**
   ```bash
   # 检查代理定义
   ls -la ~/.claude/agents/gsd-impeccable-executor.md
   ls -la ~/.claude/agents/gsd-impeccable-reviewer.md
   ```

### 问题：代码审查没有使用 Impeccable

**检查清单：**

1. **前端文件是否被正确分类？**
   查看日志：
   ```
   File Classification:
     Frontend: X files
     Backend: Y files
   ```

2. **.impeccable.md 是否存在？**
   ```
   ✅ Design context found: .impeccable.md
   ```

3. **是否派生了正确的代理？**
   ```
   🎨 Frontend files detected — delegating to Impeccable reviewer
   ```

---

## 最佳实践

### 1. 保持 .impeccable.md 更新

定期更新设计上下文，确保它反映当前的设计方向：

```bash
# 编辑 .impeccable.md
vim .impeccable.md

# 或使用 UI 阶段重新生成
gsd-ui-phase <phase-number>
```

### 2. 混合任务的处理

当一个计划同时包含前端和后端任务时：

**方案 A：拆分计划**
```yaml
# 将混合计划拆分为两个独立计划
01-backend-api.yaml  # type: backend
02-frontend-ui.yaml  # type: ui
```

**方案 B：保持混合**
- execute-phase 会根据检测规则判断主要类型
- code-review 会派生两个代理分别审查

### 3. 设计质量阈值

在 `.planning/config.json` 中设置设计质量阈值：

```json
{
  "impeccable": {
    "quality_thresholds": {
      "min_overall_score": 7,
      "min_accessibility_score": 8,
      "require_ai_slop_pass": true
    }
  }
}
```

如果 Impeccable 代理返回的分数低于阈值，执行会暂停并提示用户。

---

## 高级配置

### 自定义代理模型

为 Impeccable 代理指定专用模型：

```json
{
  "agents": {
    "gsd-impeccable-executor": {
      "model": "claude-opus-4-6"  // 使用更强大的模型
    },
    "gsd-impeccable-reviewer": {
      "model": "claude-opus-4-6"
    }
  }
}
```

### 工作树隔离

Impeccable 代理默认使用工作树隔离，配置与 GSD 相同：

```json
{
  "workflow": {
    "use_worktrees": true  // false 则在主工作树执行
  }
}
```

### 并行执行

Impeccable 代理支持并行执行，配置与 GSD 相同：

```json
{
  "workflow": {
    "parallelization": true  // false 则顺序执行
  }
}
```

---

## 附录：检测规则详解

### 检测优先级

1. **计划 frontmatter 的 type 字段**（最高优先级）
   ```yaml
   type: ui  # 立即判定为 UI 计划
   ```

2. **计划目标中的关键词**
   ```
   objective: "Create responsive dashboard component"
   # 检测到 "component" 和 "responsive"
   ```

3. **文件扩展名**
   ```
   files_modified:
     - src/components/Dashboard.tsx  # .tsx 匹配
     - src/styles/dashboard.css      # .css 匹配
   ```

4. **文件路径模式**
   ```
   files_modified:
     - src/components/Button.tsx  # components/ 匹配
   ```

### 检测逻辑伪代码

```python
def is_ui_plan(plan):
    # 1. 检查 type 字段
    if plan.type in config.detection_rules.plan_types:
        return True
    
    # 2. 检查关键词
    objective_lower = plan.objective.lower()
    for keyword in config.detection_rules.keywords:
        if keyword.lower() in objective_lower:
            return True
    
    # 3. 检查文件扩展名
    for file in plan.files_modified:
        ext = get_extension(file)
        if ext in config.detection_rules.file_extensions:
            return True
    
    # 4. 检查路径模式
    for file in plan.files_modified:
        for pattern in config.detection_rules.path_patterns:
            if pattern in file:
                return True
    
    # 5. 检查标签
    if plan.tags and any(tag in ['[UI]', '[Frontend]', '[Design]'] for tag in plan.tags):
        return True
    
    return False
```

---

## 版本历史

- **v1.0.0** (2026-06-13): 初始版本
  - 支持自动 UI 任务检测
  - 支持计划级别模式切换
  - 支持代码审查前端/后端分离
  - 支持草图生成 Impeccable 集成
