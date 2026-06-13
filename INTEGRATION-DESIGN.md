# GSD × Impeccable 整合架构设计

## 设计日期
2026-06-12

## 设计目标

**核心需求：**
- GSD 负责：项目管理、开发工作流、后端开发规则
- Impeccable 负责：UI/前端设计、实现、审查
- 当 GSD 遇到前端任务时，自动委托给 Impeccable

---

## 整合架构

### 架构选择：模式切换架构（状态机）

```
┌────────────────────────────────────────┐
│        GSD 模式（默认状态）             │
│  • 项目管理、后端开发                   │
│  • 工作流编排、测试部署                 │
└────────────────────────────────────────┘
            ↓ 检测 UI 任务
    ┌───────────────────┐
    │  模式切换触发器    │
    │  • 保存 GSD 状态  │
    │  • 准备切换上下文  │
    └───────────────────┘
            ↓
┌────────────────────────────────────────┐
│      Impeccable 模式（UI 专用）         │
│  • 完全接管 UI 设计、实现、审查          │
│  • 独立的设计上下文和规则               │
│  • 使用 Impeccable 全部能力             │
└────────────────────────────────────────┘
            ↓ UI 工作完成
    ┌───────────────────┐
    │   回流到 GSD      │
    │  • 交付成果       │
    │  • 恢复 GSD 状态  │
    │  • 更新进度       │
    └───────────────────┘
            ↓
┌────────────────────────────────────────┐
│      回到 GSD 模式                     │
│  • 验证集成                            │
│  • 继续其他任务                        │
└────────────────────────────────────────┘
```

**理由：**
- ✅ 职责完全分离：GSD = 编排，Impeccable = UI 执行
- ✅ Impeccable 完全自治，不受 GSD 规则干扰
- ✅ 清晰的进入和退出机制，状态可追踪
- ✅ 回流机制确保 GSD 能继续后续流程

### 状态机定义

```yaml
States:
  - GSD_MODE: 
      default: true
      handles: [project_management, backend, testing, deployment]
      transitions:
        - trigger: detect_ui_task
          target: IMPECCABLE_MODE
          
  - IMPECCABLE_MODE:
      default: false
      handles: [ui_design, ui_implementation, ui_review]
      transitions:
        - trigger: ui_work_complete
          target: GSD_MODE

Transitions:
  - GSD → IMPECCABLE:
      conditions: is_ui_task()
      actions: [save_gsd_state, load_impeccable_context]
      
  - IMPECCABLE → GSD:
      conditions: impeccable_complete()
      actions: [save_ui_artifacts, restore_gsd_state, integrate_results]
```

---

## 技术决策

### 1. 前端任务检测规则

```yaml
文件特征:
  - 扩展名: ['.tsx', '.jsx', '.vue', '.svelte', '.css', '.scss', '.sass', '.html']
  - 路径模式: ['components/', 'pages/', 'styles/', 'ui/', 'views/', 'layouts/']

任务特征:
  - 关键词: ['component', 'interface', 'UI', 'layout', 'styling', 'animation', 'responsive']
  - PLAN.md 标记: ['[UI]', '[Frontend]', '[Design]']

项目特征:
  - package.json 依赖: ['react', 'vue', 'svelte', 'angular', '@emotion', 'styled-components']
```

### 2. 设计上下文管理

**采用双文件策略：**

```
.impeccable.md
├── 完整的 Impeccable 设计上下文
├── target audience, use cases, brand personality
└── 由 Impeccable 技能直接读取

.planning/PROJECT.md
├── GSD 项目总览
├── 包含 "Design Context" 章节
└── 引用 .impeccable.md，包含简要摘要
```

**同步机制：**
- 首次检测到前端任务时，如果 .impeccable.md 不存在：
  - 从 .planning/ 推断设计上下文
  - 询问缺失的关键信息（target audience, brand tone）
  - 生成 .impeccable.md
  - 在 .planning/PROJECT.md 添加引用章节

### 3. 模式切换实现

**A. 进入 Impeccable 模式（GSD → Impeccable）**

```python
def enter_impeccable_mode(ui_task, gsd_context):
    """从 GSD 模式切换到 Impeccable 模式"""
    
    # 1. 保存 GSD 状态
    gsd_state = {
        'phase': current_phase,
        'task': ui_task,
        'next_step': next_gsd_step,
        'context': gsd_context
    }
    save_to('.planning/.gsd-state.json', gsd_state)
    
    # 2. 准备 Impeccable 上下文
    ensure_impeccable_context_exists()  # 确保 .impeccable.md 存在
    
    # 3. 调用 Impeccable（完全独立执行）
    result = invoke_impeccable_skill(
        task=ui_task,
        design_context='.impeccable.md',
        mode='full_autonomy'  # Impeccable 完全自主
    )
    
    return result
```

**B. Impeccable 模式执行**

```markdown
Impeccable 在独立模式中：
✓ 只读取 .impeccable.md 作为设计上下文
✓ 使用所有 30+ 参考文档
✓ 按照 Impeccable 标准生成/审查代码
✓ 不受 GSD 的任务格式、命名约定约束
✓ 产出：代码 + 设计质量报告
```

**C. 回流到 GSD 模式（Impeccable → GSD）**

```python
def return_to_gsd_mode(impeccable_result):
    """从 Impeccable 模式回到 GSD 模式"""
    
    # 1. 读取保存的 GSD 状态
    gsd_state = load_from('.planning/.gsd-state.json')
    
    # 2. 整合 Impeccable 成果
    artifacts = impeccable_result['artifacts']  # 生成的文件
    quality_report = impeccable_result['report']  # 设计质量评分
    
    # 3. 更新 GSD 进度
    update_phase_progress(gsd_state['phase'], {
        'ui_task_completed': True,
        'artifacts': artifacts,
        'quality_score': quality_report['score']
    })
    
    # 4. 继续 GSD 流程
    next_step = gsd_state['next_step']  # 例如: gsd-verify-work
    return next_step
```

**D. Handoff 协议**

```markdown
## IMPECCABLE → GSD HANDOFF

**Mode**: Impeccable → GSD
**Status**: UI work completed
**Artifacts**:
  - src/components/LoginForm.tsx (new)
  - src/styles/login.module.css (new)
**Design Quality**:
  - Overall Score: 8.5/10
  - AI Slop Test: PASS
  - Accessibility: A (WCAG AAA)
**Next GSD Step**: gsd-verify-work {phase_number}
**Notes**: Component follows Impeccable principles, typography scales fluidly
```

---

## 需要修改的 GSD 技能

### 核心修改：实现模式切换机制

#### 1. gsd-execute-phase（模式切换入口）

**修改策略：添加模式切换逻辑**

```markdown
<process>
## 执行前检查

对于每个任务：
1. 检测任务类型
2. 如果是 UI 任务 → 切换到 Impeccable 模式
3. 如果是后端任务 → 正常执行

## 模式切换实现

### 检测 UI 任务
```python
def is_ui_task(task):
    """判断是否为 UI 任务"""
    # 文件检测
    if task mentions files matching ['.tsx', '.jsx', '.vue', '.css']:
        return True
    # 关键词检测
    if task contains ['component', 'UI', 'interface', 'layout', 'styling']:
        return True
    # 明确标记
    if task has tag '[UI]' or '[Frontend]':
        return True
    return False
```

### 切换到 Impeccable 模式
```markdown
<impeccable_mode_switch>

## 进入 Impeccable 模式

1. 保存当前 GSD 状态到 .planning/.gsd-state.json
2. 确保 .impeccable.md 存在（不存在则初始化）
3. 调用 Impeccable skill：

```
Skill(
    name="impeccable",
    args={
        "task": task_description,
        "context": "from_gsd",
        "gsd_phase": current_phase,
        "return_to": "gsd-execute-phase"
    }
)
```

4. 等待 Impeccable 完成并返回

5. 接收 Impeccable handoff：
   - 读取生成的文件列表
   - 读取设计质量报告
   - 更新任务状态为 completed

6. 恢复 GSD 流程，继续下一个任务

</impeccable_mode_switch>
```

**实际修改：**
在 gsd-execute-phase/SKILL.md 中添加：

```markdown
## Task Execution Loop

For each task in PLAN.md:
  
  # 添加 UI 任务检测
  if is_ui_task(task):
      # 切换到 Impeccable 模式
      result = execute_in_impeccable_mode(task)
      update_task_status(task, result)
      continue  # 继续下一个任务
  
  # 原有的后端任务执行逻辑
  execute_backend_task(task)
```

#### 2. gsd-code-review（模式切换审查）

**修改策略：UI 代码自动委托给 Impeccable**

```markdown
## Code Review Process

1. 收集变更的文件
2. 分类文件：
   - frontend_files = [f for f in files if is_frontend_file(f)]
   - backend_files = [f for f in files if not is_frontend_file(f)]

3. 如果有 frontend_files：
   
   # 切换到 Impeccable 审查模式
   Skill(
       name="impeccable",
       args={
           "action": "review",
           "files": frontend_files,
           "context": "from_gsd_code_review"
       }
   )
   
   等待 Impeccable 返回审查报告

4. 如果有 backend_files：
   执行 GSD 标准代码审查

5. 合并审查结果
```

#### 3. gsd-sketch（直接进入 Impeccable 模式）

**修改策略：gsd-sketch 成为 Impeccable 的快捷入口**

```markdown
<objective>
快速进入 Impeccable 模式生成 UI 草图。
这是一个轻量级的 UI 探索工具。
</objective>

<process>
直接调用 Impeccable skill：

Skill(
    name="impeccable",
    args={
        "action": "sketch",
        "description": user_input,
        "output": "throwaway HTML mockup"
    }
)

Impeccable 返回后，展示草图，不需要回流到 GSD
（因为这是独立的探索性工作）
</process>
```

---

## 配置和约定

### 模式切换配置

**在 .planning/config.json 中添加：**
```json
{
  "mode_switching": {
    "enabled": true,
    "impeccable_mode": {
      "auto_enter": true,
      "detection_rules": {
        "file_extensions": [".tsx", ".jsx", ".vue", ".svelte", ".css", ".scss"],
        "path_patterns": ["components/", "pages/", "styles/", "ui/"],
        "keywords": ["component", "UI", "interface", "layout", "styling"],
        "task_tags": ["[UI]", "[Frontend]", "[Design]"]
      },
      "state_file": ".planning/.gsd-state.json",
      "design_context": ".impeccable.md"
    }
  }
}
```

### GSD 状态保存格式

**.planning/.gsd-state.json（模式切换时保存）：**
```json
{
  "mode": "impeccable",
  "entered_at": "2026-06-12T10:30:00Z",
  "gsd_context": {
    "phase": "3",
    "phase_name": "Build User Dashboard",
    "current_task": "Create dashboard layout component",
    "next_gsd_step": "gsd-verify-work 3",
    "plan_file": ".planning/phases/03-build-dashboard/03-PLAN.md",
    "task_index": 5
  },
  "trigger": "gsd-execute-phase",
  "ui_task": {
    "description": "Create responsive dashboard layout with sidebar",
    "files": ["src/components/DashboardLayout.tsx", "src/styles/dashboard.module.css"],
    "requirements": ["responsive", "accessible", "dark mode support"]
  }
}
```

### Impeccable Handoff 格式

**Impeccable 完成后返回的标准格式：**
```markdown
## IMPECCABLE → GSD HANDOFF

**Mode Transition**: Impeccable → GSD
**Status**: ✅ UI work completed
**Duration**: 12 minutes

### Artifacts Created
- `src/components/DashboardLayout.tsx` (new, 156 lines)
- `src/components/Sidebar.tsx` (new, 89 lines)
- `src/styles/dashboard.module.css` (new, 234 lines)
- `src/hooks/useBreakpoint.ts` (new, 42 lines)

### Design Quality Report
- **Overall Score**: 8.7/10
- **AI Slop Test**: ✅ PASS (unique design, intentional choices)
- **Typography**: 9/10 (fluid scaling, clear hierarchy)
- **Color & Contrast**: 8/10 (WCAG AA compliant, dark mode ready)
- **Responsiveness**: 9/10 (container queries, mobile-first)
- **Accessibility**: 8.5/10 (semantic HTML, keyboard nav, ARIA labels)

### Impeccable References Applied
- typography.md - fluid type scale with clamp()
- color-and-contrast.md - light-dark() for theme switching
- spatial-design.md - consistent spacing rhythm
- responsive-design.md - container queries for sidebar
- interaction-design.md - progressive disclosure

### Next GSD Step
**Command**: `gsd-verify-work 3`
**Notes**: 
- Components follow project naming conventions
- Tests not included (add via gsd-add-tests if needed)
- Ready for integration with existing dashboard page

### Design Context Used
- Target Audience: Data analysts, daily users
- Brand Tone: Professional but approachable
- Aesthetic: Clean minimalism with functional accents
- Source: `.impeccable.md` (last updated 2026-06-10)
```

---

## 实施步骤

### Phase 1: 安装和准备
1. 将 Impeccable 安装到 ~/.cc-switch/skills/
2. 创建符号链接到 ~/.claude/skills/
3. 验证 Impeccable 可以独立工作

### Phase 2: 修改核心技能
1. 修改 gsd-execute-phase
2. 修改 gsd-code-review
3. 修改 gsd-sketch

### Phase 3: 配置和测试
1. 在 .planning/config.json 添加 Impeccable 配置
2. 创建测试项目
3. 验证前端任务自动路由到 Impeccable

### Phase 4: 文档和优化
1. 编写整合使用文档
2. 优化检测规则
3. 收集反馈并迭代

---

## 测试场景

### 测试 1：GSD → Impeccable 模式切换

**场景：执行包含 UI 任务的阶段**

```bash
# 准备
创建 .planning/phases/03-dashboard/03-PLAN.md
包含任务：
  - Task 1: 实现后端 API (后端任务)
  - Task 2: 创建 Dashboard 组件 (UI 任务)
  - Task 3: 编写单元测试 (后端任务)

# 执行
gsd-execute-phase 3

# 预期行为
1. Task 1 正常执行（GSD 模式）
2. Task 2 检测到 UI 关键词，自动切换到 Impeccable 模式
   - 保存 GSD 状态到 .gsd-state.json
   - 调用 Impeccable skill
   - 等待 Impeccable 完成
3. Impeccable 返回 handoff
   - 显示生成的文件
   - 显示设计质量报告
4. 自动回流到 GSD 模式
   - 恢复 GSD 状态
   - 标记 Task 2 完成
5. Task 3 继续执行（GSD 模式）

# 验证
✓ .planning/.gsd-state.json 被创建和清理
✓ Impeccable 生成的文件存在且符合设计标准
✓ 任务状态正确更新
✓ 后端任务不受影响
```

### 测试 2：Impeccable → GSD 回流

**场景：Impeccable 完成 UI 工作后回到 GSD**

```bash
# Impeccable 模式完成后
验证 handoff 消息包含：
  ✓ Status: completed
  ✓ Artifacts: 文件列表
  ✓ Design Quality: 评分和报告
  ✓ Next GSD Step: 明确的下一步命令

# GSD 接收 handoff 后
验证行为：
  ✓ 读取 .gsd-state.json 恢复上下文
  ✓ 更新任务进度
  ✓ 继续执行剩余任务
  ✓ 或进入下一个 GSD 步骤（如 gsd-verify-work）
```

### 测试 3：前端代码审查模式切换

**场景：审查包含前端代码的提交**

```bash
# 准备
创建包含前端和后端文件的提交：
  - src/api/users.ts (后端)
  - src/components/UserCard.tsx (前端)
  - src/styles/user-card.css (前端)

# 执行
gsd-code-review

# 预期行为
1. 检测到前端文件
2. 前端文件切换到 Impeccable 审查模式
   - 应用 Impeccable 审查清单
   - 评分：typography, color, accessibility 等
3. 后端文件使用 GSD 标准审查
4. 合并两份审查报告

# 验证
✓ 审查报告包含两部分
✓ 前端部分有设计质量评分
✓ 后端部分有代码质量评分
✓ 两者使用不同的标准
```

### 测试 4：gsd-sketch 快捷入口

**场景：快速生成 UI 草图**

```bash
# 执行
gsd-sketch "创建一个现代风格的登录表单"

# 预期行为
1. 直接进入 Impeccable 模式（无需保存 GSD 状态）
2. Impeccable 生成 HTML 草图
3. 返回草图，不回流到 GSD（因为是独立探索）

# 验证
✓ 生成的 HTML 遵循 Impeccable 设计原则
✓ 避免 AI Slop（不使用 Inter/Roboto，无毛玻璃等）
✓ 有明确的设计意图和美学方向
✓ 不创建 .gsd-state.json（因为不需要回流）
```

### 测试 5：纯后端任务不触发模式切换

**场景：执行纯后端阶段**

```bash
# 准备
创建纯后端 PLAN.md：
  - 实现用户认证 API
  - 添加数据库迁移
  - 编写集成测试

# 执行
gsd-execute-phase

# 预期行为
全程保持 GSD 模式，不切换到 Impeccable

# 验证
✓ 不创建 .gsd-state.json
✓ 不调用 Impeccable skill
✓ 所有任务按 GSD 标准执行
```

### 测试 6：.impeccable.md 自动初始化

**场景：首次遇到 UI 任务但没有设计上下文**

```bash
# 准备
项目没有 .impeccable.md 文件

# 执行
gsd-execute-phase（包含 UI 任务）

# 预期行为
1. 检测到 UI 任务
2. 发现 .impeccable.md 不存在
3. 自动初始化设计上下文：
   - 从 .planning/PROJECT.md 推断
   - 询问缺失的关键信息（target audience, brand tone）
   - 创建 .impeccable.md
4. 继续切换到 Impeccable 模式

# 验证
✓ .impeccable.md 被创建
✓ 包含完整的设计上下文
✓ Impeccable 模式正常工作
```

### 测试 7：模式切换状态持久化

**场景：验证状态在切换过程中不丢失**

```bash
# 场景设置
执行阶段，切换到 Impeccable 模式

# 验证点
1. 切换前：
   ✓ 当前 phase、task、进度被保存
   
2. Impeccable 模式中：
   ✓ 可以读取 .gsd-state.json
   ✓ 知道来自哪个 GSD 阶段
   
3. 回流后：
   ✓ 准确恢复到正确的位置
   ✓ 继续下一个任务，不重复也不跳过
```

---

## 风险和缓解

### 风险 1：检测误判
- **问题：** 可能将非前端任务误判为前端任务
- **缓解：** 
  - 使用多重检测条件（文件 + 路径 + 关键词）
  - 在配置中允许手动覆盖
  - 提供明确的日志输出

### 风险 2：性能影响
- **问题：** 每次执行任务都检测，可能影响性能
- **缓解：**
  - 检测逻辑简单快速（正则匹配）
  - 只在必要时读取 Impeccable 文档
  - 缓存设计上下文

### 风险 3：配置冲突
- **问题：** .impeccable.md 和 .planning/PROJECT.md 可能不同步
- **缓解：**
  - .impeccable.md 为权威源
  - 自动检测并提示同步
  - 提供手动同步命令

---

## 成功标准

### 安装和配置
✅ Impeccable 成功安装到 ~/.cc-switch/skills/
✅ 符号链接创建到 ~/.claude/skills/
✅ Impeccable 可以独立使用（不依赖 GSD）
✅ .planning/config.json 包含模式切换配置

### 模式切换机制
✅ GSD 检测到 UI 任务时自动切换到 Impeccable 模式
✅ 切换前正确保存 GSD 状态到 .gsd-state.json
✅ Impeccable 在独立模式下完全自主运行
✅ Impeccable 完成后自动回流到 GSD 模式
✅ 回流时正确恢复 GSD 状态和上下文
✅ 后端任务不触发模式切换，保持 GSD 模式

### Impeccable 独立性
✅ Impeccable 模式只读取 .impeccable.md 作为设计上下文
✅ 使用 Impeccable 的所有 30+ 参考文档
✅ 不受 GSD 规则约束，完全按 Impeccable 标准执行
✅ 生成的代码遵循 Impeccable 设计原则，避免 AI Slop
✅ 返回标准化的 handoff 消息给 GSD

### 任务分流
✅ 前端文件（.tsx/.css等）自动路由到 Impeccable
✅ 前端关键词（component/UI等）触发模式切换
✅ PLAN.md 的 [UI] 标记触发模式切换
✅ 后端任务在 GSD 模式正常执行

### 代码审查
✅ 混合提交时，前端文件用 Impeccable 审查
✅ 后端文件用 GSD 标准审查
✅ 审查报告合并两者，清晰区分
✅ Impeccable 审查包含设计质量评分

### 设计上下文
✅ .impeccable.md 作为权威设计上下文存在
✅ .planning/PROJECT.md 包含指向 .impeccable.md 的引用
✅ 首次遇到 UI 任务时自动初始化 .impeccable.md
✅ 两个文件保持同步但不重复

### 用户体验
✅ 用户从 GSD 入口开始，无需手动切换
✅ 模式切换对用户透明，流程连贯
✅ 清晰的日志显示当前处于哪个模式
✅ Handoff 消息提供明确的下一步指引
✅ 通过所有 7 个测试场景

### 错误处理
✅ .impeccable.md 缺失时自动初始化或提示
✅ Impeccable 执行失败时有清晰的错误消息
✅ 回流失败时能恢复 GSD 状态
✅ 模式切换不会导致任务丢失或重复

---

## 附录：目录结构

```
~/.cc-switch/skills/
├── impeccable/                    ← 新增
│   ├── SKILL.md
│   └── references/
│       ├── teach-impeccable.md
│       ├── typography.md
│       ├── color-and-contrast.md
│       └── ... (30+ 个参考文档)
├── gsd-execute-phase/             ← 修改
│   └── SKILL.md (添加前端检测)
├── gsd-code-review/               ← 修改
│   └── SKILL.md (添加 Impeccable 审查)
├── gsd-sketch/                    ← 修改
│   └── SKILL.md (调用 Impeccable)
└── ... (其他 GSD 技能)

项目目录:
project/
├── .impeccable.md                 ← 新增（由 Impeccable 管理）
└── .planning/
    ├── PROJECT.md                 ← 修改（添加设计上下文引用）
    └── config.json                ← 修改（添加 Impeccable 配置）
```
