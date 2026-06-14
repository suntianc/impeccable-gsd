---
name: gsd-sketch
description: "Sketch UI/design ideas with throwaway HTML mockups, or propose what to sketch next (frontier mode)"
argument-hint: "[design idea to explore] [--quick] [--text] [--wrap-up] or [frontier]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
  - WebFetch
  - mcp__context7__resolve-library-id
  - mcp__context7__query-docs
---

<objective>
Explore design directions through throwaway HTML mockups before committing to implementation.
Each sketch produces 2-3 variants for comparison. Sketches live in `.planning/sketches/` and
integrate with GSD commit patterns, state tracking, and handoff workflows. Loads spike
findings to ground mockups in real data shapes and validated interaction patterns.

Two modes:
- **Idea mode** (default) — describe a design idea to sketch
- **Frontier mode** (no argument or "frontier") — analyzes existing sketch landscape and proposes consistency and frontier sketches

Does not require prior new-project setup — auto-creates `.planning/sketches/` if needed.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/sketch.md
@$HOME/.claude/get-shit-done/workflows/sketch-wrap-up.md
@$HOME/.claude/get-shit-done/references/ui-brand.md
@$HOME/.claude/get-shit-done/references/sketch-theme-system.md
@$HOME/.claude/get-shit-done/references/sketch-interactivity.md
@$HOME/.claude/get-shit-done/references/sketch-tooling.md
@$HOME/.claude/get-shit-done/references/sketch-variant-patterns.md
@$HOME/.claude/skills/impeccable/SKILL.md
@$HOME/.claude/skills/impeccable/references/teach-impeccable.md
@$HOME/.claude/skills/impeccable/references/typography.md
@$HOME/.claude/skills/impeccable/references/color-and-contrast.md
@$HOME/.claude/skills/impeccable/references/spatial-design.md
</execution_context>

<impeccable_integration>
## Impeccable Design Principles for Sketches

When generating UI sketches, apply Impeccable design principles:

1. **Check for `.impeccable.md`** in the project root:
   - **If it exists**: silently read it to understand the project's design context (target audience, brand tone, aesthetic direction). Do not narrate the check — just apply its contents.
   - **If it does not exist**: run the full `teach-impeccable.md` context-gathering flow first (explore codebase, ask UX-focused questions, write `.impeccable.md`). Only after `.impeccable.md` is written, continue with the sketch mood intake and build steps.

2. **Avoid AI Slop:**
   - ❌ No Inter/Roboto/Arial/Open Sans fonts
   - ❌ No default dark mode with glow effects
   - ❌ No purple-blue gradients
   - ❌ No neon accent colors
   - ❌ No generic card layouts
   - ❌ No centered hero sections with icon + heading + subtext

3. **Apply Impeccable Aesthetics:**
   - ✅ Unique display fonts + refined body fonts
   - ✅ Fluid typography with clamp()
   - ✅ Intentional color palette using oklch/color-mix
   - ✅ Varied spacing for visual rhythm
   - ✅ Purposeful animations with proper easing
   - ✅ Progressive disclosure and meaningful empty states

4. **Design Intent:** Every design choice should have purpose and meaning. Make the sketch distinctive and memorable.

5. **If .impeccable.md exists:** Align the sketch with the specified design direction, brand personality, and aesthetic.
</impeccable_integration>

<runtime_note>
**Copilot (VS Code):** Use `vscode_askquestions` wherever this workflow calls `AskUserQuestion`.
</runtime_note>

<context>
Design idea: $ARGUMENTS

**Available flags:**
- `--quick` — Skip mood/direction intake, jump straight to decomposition and building. Use when the design direction is already clear.
- `--wrap-up` — Package sketch design findings into a persistent project skill for future build conversations. Runs the sketch-wrap-up workflow.
</context>

<process>
Parse the first token of $ARGUMENTS:
- If it is `--wrap-up`: strip the flag, execute the sketch-wrap-up workflow end-to-end.
- Otherwise: execute the sketch workflow end-to-end.

Preserve all workflow gates (intake, decomposition, target stack research, variant evaluation, MANIFEST updates, commit patterns).
</process>
