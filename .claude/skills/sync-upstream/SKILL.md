---
name: sync-upstream
description: Sync this fork with the upstream EveryInc/compound-engineering-plugin repository while preserving auggie-mcp (codebase-retrieval) integration. Use when upstream has new changes to pull in.
argument-hint: "[optional: --dry-run to preview without merging]"
---

# Sync Upstream

Merge upstream `EveryInc/compound-engineering-plugin` into this fork, preserving all `mcp__auggie-mcp__codebase-retrieval` enhancements.

**Remotes:** `origin` = this fork, `upstream` = EveryInc source of truth.

**References:**
- [auggie-mcp-files.md](./references/auggie-mcp-files.md) — canonical tracking list of all auggie-mcp files
- [conflict-resolution.md](./references/conflict-resolution.md) — rules for resolving merge conflicts
- [verify-auggie-integrity.sh](./scripts/verify-auggie-integrity.sh) — automated verification script

## Step 1: Pre-Flight

```bash
git status                # Must be clean
git remote -v             # Expect: origin → davidteren/..., upstream → EveryInc/...
```

If `upstream` is missing: `git remote add upstream git@github.com:EveryInc/compound-engineering-plugin.git`

If working tree is dirty, ask the user to commit or stash.

## Step 2: Fetch and Assess

```bash
git fetch upstream
MERGE_BASE=$(git merge-base main upstream/main)
git log --oneline $MERGE_BASE..upstream/main | wc -l          # Upstream commit count
git log --oneline $MERGE_BASE..HEAD                            # Fork-only commits
git diff --stat $MERGE_BASE..upstream/main | tail -5           # Change summary
```

Present: upstream commit count, areas changed, upstream version (from `plugin.json`).

**If `--dry-run`:** Stop here.

## Step 3: Identify Conflicts

```bash
comm -12 \
  <(git diff --name-only $MERGE_BASE..HEAD | sort) \
  <(git diff --name-only $MERGE_BASE..upstream/main | sort)
```

Report which files changed on both sides. Read [conflict-resolution.md](./references/conflict-resolution.md) for resolution rules.

## Step 4: Merge

```bash
git merge --no-commit --no-ff upstream/main
```

Resolve conflicts using rules in [conflict-resolution.md](./references/conflict-resolution.md). Key principles:
- Take upstream structural changes
- Re-apply auggie-mcp additions to their new locations
- Version numbers and component counts: always take upstream

## Step 5: Verify Integrity

Run the verification script:

```bash
.claude/skills/sync-upstream/scripts/verify-auggie-integrity.sh
```

All checks must pass. If any fail, re-apply auggie-mcp references using the patterns in [auggie-mcp-files.md](./references/auggie-mcp-files.md).

## Step 6: New Upstream Files

Check for new agents/skills that should get auggie-mcp integration:

```bash
git diff --name-only --diff-filter=A $MERGE_BASE..upstream/main -- 'plugins/compound-engineering/agents/**/*.md'
git diff --name-only --diff-filter=A $MERGE_BASE..upstream/main -- 'plugins/compound-engineering/skills/**/SKILL.md'
```

For each new file that performs code analysis, add auggie-mcp integration using the standard patterns from [auggie-mcp-files.md](./references/auggie-mcp-files.md). Skip pure documentation, configuration, or task-management files.

## Step 7: Commit

```bash
git add -A
git commit -m "Merge upstream/main: sync with upstream vX.Y.Z, preserve auggie-mcp integration

Incorporates N upstream commits (vOLD->vNEW) including:
- [key changes]

All auggie-mcp/codebase-retrieval references preserved across M files.

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Step 8: Push

Ask before pushing: "Merge complete. Push to origin/main? (y/n)"

## Quick Reference

```bash
/sync-upstream              # Full interactive sync
/sync-upstream --dry-run    # Preview only

# Verify integrity anytime
.claude/skills/sync-upstream/scripts/verify-auggie-integrity.sh
.claude/skills/sync-upstream/scripts/verify-auggie-integrity.sh --json
```
