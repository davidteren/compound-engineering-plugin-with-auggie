---
name: sync-upstream
description: Sync this fork with the upstream EveryInc/compound-engineering-plugin repository while preserving auggie-mcp (codebase-retrieval) integration. Use when upstream has new changes to pull in.
argument-hint: "[optional: --dry-run to preview without merging]"
---

# Sync Upstream

Merge changes from the upstream `EveryInc/compound-engineering-plugin` repository into this fork while preserving all `mcp__auggie-mcp__codebase-retrieval` enhancements.

## Context

This repository is a fork of `EveryInc/compound-engineering-plugin` with one key addition: **Augment Code's codebase-retrieval MCP tool** is integrated across agents, skills, and documentation as a semantic search enhancement. The upstream does not have this integration.

**Remotes:**
- `origin` — `davidteren/compound-engineering-plugin-with-auggie` (this fork)
- `upstream` — `EveryInc/compound-engineering-plugin` (source of truth)

## Fork-Specific Changes to Preserve

The following files contain auggie-mcp/codebase-retrieval additions that must survive every upstream merge. Use these as the canonical list for post-merge verification.

### Review Agents (10 files) — "Codebase Search Strategy" section

Each adds a Primary/Secondary search pattern block:

- `plugins/compound-engineering/agents/review/architecture-strategist.md`
- `plugins/compound-engineering/agents/review/code-simplicity-reviewer.md`
- `plugins/compound-engineering/agents/review/dhh-rails-reviewer.md`
- `plugins/compound-engineering/agents/review/kieran-rails-reviewer.md`
- `plugins/compound-engineering/agents/review/kieran-python-reviewer.md`
- `plugins/compound-engineering/agents/review/kieran-typescript-reviewer.md`
- `plugins/compound-engineering/agents/review/pattern-recognition-specialist.md`
- `plugins/compound-engineering/agents/review/performance-oracle.md`
- `plugins/compound-engineering/agents/review/security-sentinel.md`
- `plugins/compound-engineering/agents/review/agent-native-reviewer.md`

### Research Agents (2 files) — PRIMARY search tool

- `plugins/compound-engineering/agents/research/repo-research-analyst.md`
- `plugins/compound-engineering/agents/research/best-practices-researcher.md`

### Workflow Agents (2 files) — contextual semantic search

- `plugins/compound-engineering/agents/workflow/pr-comment-resolver.md`
- `plugins/compound-engineering/agents/workflow/bug-reproduction-validator.md`

### Skills (6 files) — inline codebase-retrieval references

- `plugins/compound-engineering/skills/ce-review/SKILL.md` — "Pre-Agent Codebase Scan"
- `plugins/compound-engineering/skills/ce-plan/SKILL.md` — "Codebase Context" step
- `plugins/compound-engineering/skills/ce-work/SKILL.md` — "find similar patterns"
- `plugins/compound-engineering/skills/brainstorming/SKILL.md` — "Existing Patterns" row
- `plugins/compound-engineering/skills/deepen-plan/SKILL.md` — code-specific context
- `plugins/compound-engineering/skills/reproduce-bug/SKILL.md` — "Codebase Context First"
- `plugins/compound-engineering/skills/agent-native-architecture/SKILL.md` — Architecture Checklist

### Documentation (3 files)

- `plugins/compound-engineering/CLAUDE.md` — "Codebase Search Best Practices" section
- `plugins/compound-engineering/README.md` — "Optional: Augment Codebase Retrieval" section
- `plugins/compound-engineering/CHANGELOG.md` — v2.30.1 entry

## Sync Procedure

### Step 1: Pre-Flight Check

```bash
# Verify clean working tree
git status

# Verify remotes
git remote -v
# Expect: origin → davidteren/..., upstream → EveryInc/...
```

If `upstream` remote is missing:
```bash
git remote add upstream git@github.com:EveryInc/compound-engineering-plugin.git
```

If working tree is dirty, ask the user to commit or stash before proceeding.

### Step 2: Fetch and Assess

```bash
# Fetch latest upstream
git fetch upstream

# Find divergence point
git merge-base main upstream/main

# Count upstream commits since divergence
git log --oneline $(git merge-base main upstream/main)..upstream/main | wc -l

# Show our fork-only commits since divergence
git log --oneline $(git merge-base main upstream/main)..HEAD
```

Present the user with a summary:
- How many upstream commits to merge
- What areas changed upstream (use `git diff --stat` with the merge base)
- Whether any of our auggie-mcp files were also changed upstream (potential conflicts)

**If `--dry-run` was passed:** Stop here. Report findings without merging.

### Step 3: Identify Likely Conflicts

```bash
# Files changed in both fork and upstream since divergence
MERGE_BASE=$(git merge-base main upstream/main)
comm -12 \
  <(git diff --name-only $MERGE_BASE..HEAD | sort) \
  <(git diff --name-only $MERGE_BASE..upstream/main | sort)
```

Report which files have changes from both sides. Pay special attention to:
- `plugins/compound-engineering/.claude-plugin/plugin.json` (version numbers)
- `plugins/compound-engineering/CHANGELOG.md` (always conflicts)
- `plugins/compound-engineering/README.md` (our auggie-mcp section)
- `.claude-plugin/marketplace.json` (version numbers)
- Any agent or skill files that upstream also modified

### Step 4: Merge

```bash
git merge --no-commit --no-ff upstream/main
```

If conflicts occur, resolve each one following these rules:

#### Conflict Resolution Rules

1. **Version numbers** (`plugin.json`, `marketplace.json`): Take upstream version — it tracks the authoritative release line.

2. **Component counts** (descriptions with "X agents, Y skills"): Take upstream counts — they reflect the actual component inventory.

3. **CHANGELOG.md**: Keep BOTH upstream entries AND our v2.30.1 auggie-mcp entry. Upstream entries go above ours chronologically.

4. **README.md**: Keep upstream content AND preserve the "Optional: Augment Codebase Retrieval" section. If upstream added content near our section, include both.

5. **Skills that moved** (e.g., commands → skills migration): If upstream moved a file we modified, apply our auggie-mcp additions to the new location. The pattern to add:
   ```markdown
   **Primary (if available)**: Use `mcp__auggie-mcp__codebase-retrieval` for semantic code understanding:
   - Set `directory_path` to the project root
   - Use natural language `information_request` (e.g., "Find [relevant query]")

   **Secondary**: Use Grep for exact identifiers, Glob for file patterns.
   ```

6. **Agent files with conflicts**: Keep upstream structural changes AND our "Codebase Search Strategy" section. If upstream reorganized the file, insert our section in a logical position (after the agent's role description, before the workflow steps).

7. **Any other conflict**: Take upstream changes, then manually re-apply our auggie-mcp additions.

### Step 5: Verify auggie-mcp Integrity

After resolving all conflicts, run these verification checks:

```bash
# Check no conflict markers remain
grep -r "<<<<<<" plugins/compound-engineering/ && echo "CONFLICT MARKERS FOUND" || echo "Clean"

# Count auggie-mcp references in agents (expect 14 files)
grep -rl "auggie-mcp\|codebase-retrieval" plugins/compound-engineering/agents/ | wc -l

# Count auggie-mcp references in skills (expect 7 files)
grep -rl "auggie-mcp\|codebase-retrieval" plugins/compound-engineering/skills/ | wc -l

# Count auggie-mcp references in docs (expect 3 files: CLAUDE.md, README.md, CHANGELOG.md)
grep -l "auggie-mcp\|codebase-retrieval" plugins/compound-engineering/CLAUDE.md plugins/compound-engineering/README.md plugins/compound-engineering/CHANGELOG.md | wc -l

# Total should be 24 files
grep -rl "auggie-mcp\|codebase-retrieval" plugins/compound-engineering/ | wc -l

# Validate JSON
cat .claude-plugin/marketplace.json | python3 -m json.tool > /dev/null && echo "marketplace.json: OK"
cat plugins/compound-engineering/.claude-plugin/plugin.json | python3 -m json.tool > /dev/null && echo "plugin.json: OK"
```

If any auggie-mcp file is missing references, re-apply the integration using the patterns documented in the "Fork-Specific Changes to Preserve" section above.

### Step 6: Handle New Files from Upstream

Check if upstream added new agents or skills that should also get auggie-mcp integration:

```bash
# New agent files from upstream that we haven't touched
MERGE_BASE=$(git merge-base main upstream/main)
git diff --name-only --diff-filter=A $MERGE_BASE..upstream/main -- 'plugins/compound-engineering/agents/**/*.md'

# New skill files from upstream
git diff --name-only --diff-filter=A $MERGE_BASE..upstream/main -- 'plugins/compound-engineering/skills/**/SKILL.md'
```

For each new agent/skill that performs code analysis:
- Review whether it would benefit from semantic search
- If yes, add the standard "Codebase Search Strategy" section
- If no (e.g., pure documentation skills), skip it

### Step 7: Commit

```bash
git add -A
git commit -m "Merge upstream/main: sync with upstream vX.Y.Z, preserve auggie-mcp integration

Incorporates N upstream commits (vOLD→vNEW) including:
- [summarize key upstream changes]

All auggie-mcp/codebase-retrieval references preserved across M files.
Conflicts resolved preserving both upstream features and codebase-retrieval integration.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

### Step 8: Push

Ask the user before pushing:

```
Merge complete. Push to origin/main? (y/n)
```

If yes:
```bash
git push origin main
```

## Handling Specific Upstream Changes

### Commands Migrated to Skills

Upstream migrated commands to `skills/` directory (v2.39.0). If this happens again:

1. Our `commands/workflows/*.md` auggie-mcp additions need to move to `skills/ce-*/SKILL.md`
2. Check the new SKILL.md files for where our Pre-Agent Codebase Scan / Codebase Context sections should go
3. Insert after the prerequisites/setup section, before the main workflow steps

### Agent Removed or Renamed

If upstream removes or renames an agent we enhanced:

1. Check if the functionality moved to a different file
2. If moved: apply auggie-mcp additions to the new location
3. If deleted: remove from our tracking list (no action needed)

### Upstream Adds Its Own Semantic Search

If upstream adopts semantic search guidance (e.g., our upstream proposal is accepted):

1. Compare their approach with ours
2. If compatible: remove our additions and use theirs (reduces merge conflicts)
3. If ours is more specific: keep ours but align with their naming conventions

## Quick Reference

```bash
# Full sync (interactive)
/sync-upstream

# Preview only (no merge)
/sync-upstream --dry-run

# After sync, verify integrity
grep -rl "codebase-retrieval" plugins/compound-engineering/ | wc -l
# Expected: 24 files
```
