#!/usr/bin/env bash
# verify-auggie-integrity.sh
# Verifies auggie-mcp/codebase-retrieval references are intact after an upstream merge.
# Exit codes: 0 = all checks pass, 1 = verification failures found
#
# Usage:
#   ./verify-auggie-integrity.sh [--json]    # --json outputs machine-readable results

set -euo pipefail

PLUGIN_DIR="plugins/compound-engineering"
JSON_MODE=false
ERRORS=0
WARNINGS=0

[[ "${1:-}" == "--json" ]] && JSON_MODE=true

# --- Helpers ---

pass() { $JSON_MODE || echo "  PASS: $1"; }
fail() { $JSON_MODE || echo "  FAIL: $1"; ERRORS=$((ERRORS + 1)); }
warn() { $JSON_MODE || echo "  WARN: $1"; WARNINGS=$((WARNINGS + 1)); }
section() { $JSON_MODE || echo ""; $JSON_MODE || echo "=== $1 ==="; }

# --- Check 1: No conflict markers ---

section "Conflict Markers"
if grep -rn "^<<<<<<<\|^>>>>>>>\|^=======$" "$PLUGIN_DIR/" 2>/dev/null; then
  fail "Conflict markers found in plugin directory"
else
  pass "No conflict markers"
fi

# --- Check 2: Agent references ---

section "Agent References"
AGENT_COUNT=$(grep -rl "auggie-mcp\|codebase-retrieval" "$PLUGIN_DIR/agents/" 2>/dev/null | wc -l | tr -d ' ')
AGENT_FILES=$(grep -rl "auggie-mcp\|codebase-retrieval" "$PLUGIN_DIR/agents/" 2>/dev/null | sort)

if [[ "$AGENT_COUNT" -ge 14 ]]; then
  pass "Agent files with auggie-mcp references: $AGENT_COUNT (expected >= 14)"
else
  fail "Agent files with auggie-mcp references: $AGENT_COUNT (expected >= 14)"
fi

# Verify specific required agents
REQUIRED_AGENTS=(
  "agents/review/architecture-strategist.md"
  "agents/review/code-simplicity-reviewer.md"
  "agents/review/dhh-rails-reviewer.md"
  "agents/review/kieran-rails-reviewer.md"
  "agents/review/kieran-python-reviewer.md"
  "agents/review/kieran-typescript-reviewer.md"
  "agents/review/pattern-recognition-specialist.md"
  "agents/review/performance-oracle.md"
  "agents/review/security-sentinel.md"
  "agents/review/agent-native-reviewer.md"
  "agents/research/repo-research-analyst.md"
  "agents/research/best-practices-researcher.md"
  "agents/workflow/pr-comment-resolver.md"
  "agents/workflow/bug-reproduction-validator.md"
)

for agent in "${REQUIRED_AGENTS[@]}"; do
  filepath="$PLUGIN_DIR/$agent"
  if [[ -f "$filepath" ]] && grep -q "auggie-mcp\|codebase-retrieval" "$filepath" 2>/dev/null; then
    pass "$agent"
  elif [[ ! -f "$filepath" ]]; then
    fail "$agent — file missing (may have been renamed/moved upstream)"
  else
    fail "$agent — missing auggie-mcp reference"
  fi
done

# --- Check 3: Skill references ---

section "Skill References"
SKILL_COUNT=$(grep -rl "auggie-mcp\|codebase-retrieval" "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')

if [[ "$SKILL_COUNT" -ge 7 ]]; then
  pass "Skill files with auggie-mcp references: $SKILL_COUNT (expected >= 7)"
else
  fail "Skill files with auggie-mcp references: $SKILL_COUNT (expected >= 7)"
fi

REQUIRED_SKILLS=(
  "skills/ce-review/SKILL.md"
  "skills/ce-plan/SKILL.md"
  "skills/ce-work/SKILL.md"
  "skills/ce-brainstorm/SKILL.md"
  "skills/deepen-plan/SKILL.md"
  "skills/reproduce-bug/SKILL.md"
  "skills/agent-native-architecture/SKILL.md"
)

for skill in "${REQUIRED_SKILLS[@]}"; do
  filepath="$PLUGIN_DIR/$skill"
  if [[ -f "$filepath" ]] && grep -q "auggie-mcp\|codebase-retrieval" "$filepath" 2>/dev/null; then
    pass "$skill"
  elif [[ ! -f "$filepath" ]]; then
    fail "$skill — file missing (may have been renamed/moved upstream)"
  else
    fail "$skill — missing auggie-mcp reference"
  fi
done

# --- Check 4: Documentation references ---

section "Documentation References"

# AGENTS.md holds the Codebase Search Best Practices (moved from CLAUDE.md)
if [[ -f "$PLUGIN_DIR/AGENTS.md" ]] && grep -q "auggie-mcp\|codebase-retrieval" "$PLUGIN_DIR/AGENTS.md" 2>/dev/null; then
  pass "AGENTS.md — Codebase Search Best Practices present"
else
  fail "AGENTS.md — missing Codebase Search Best Practices section"
fi

# CLAUDE.md should be @AGENTS.md pointer (or contain auggie-mcp references directly)
if [[ -f "$PLUGIN_DIR/CLAUDE.md" ]]; then
  if grep -q "^@AGENTS.md" "$PLUGIN_DIR/CLAUDE.md" 2>/dev/null; then
    pass "CLAUDE.md — @AGENTS.md pointer (content lives in AGENTS.md)"
  elif grep -q "auggie-mcp\|codebase-retrieval" "$PLUGIN_DIR/CLAUDE.md" 2>/dev/null; then
    pass "CLAUDE.md — contains auggie-mcp references directly"
  else
    fail "CLAUDE.md — missing auggie-mcp reference or @AGENTS.md pointer"
  fi
fi

for doc in README.md CHANGELOG.md; do
  filepath="$PLUGIN_DIR/$doc"
  if [[ -f "$filepath" ]] && grep -q "auggie-mcp\|codebase-retrieval" "$filepath" 2>/dev/null; then
    pass "$doc"
  else
    fail "$doc — missing auggie-mcp reference"
  fi
done

# --- Check 5: Total count ---

section "Total Count"
TOTAL=$(grep -rl "auggie-mcp\|codebase-retrieval" "$PLUGIN_DIR/" 2>/dev/null | wc -l | tr -d ' ')
pass "Total files with auggie-mcp references: $TOTAL"

if [[ "$TOTAL" -lt 24 ]]; then
  fail "Total count below minimum threshold of 24"
fi

# --- Check 6: JSON validity ---

section "JSON Validation"
for json_file in .claude-plugin/marketplace.json "$PLUGIN_DIR/.claude-plugin/plugin.json"; do
  if [[ -f "$json_file" ]]; then
    if python3 -m json.tool "$json_file" > /dev/null 2>&1; then
      pass "$json_file — valid JSON"
    else
      fail "$json_file — invalid JSON"
    fi
  fi
done

# --- Check 7: List all files (for reporting) ---

section "All auggie-mcp Files"
grep -rl "auggie-mcp\|codebase-retrieval" "$PLUGIN_DIR/" 2>/dev/null | sort | while read -r f; do
  $JSON_MODE || echo "  $f"
done

# --- Summary ---

section "Summary"
if [[ "$ERRORS" -eq 0 ]]; then
  $JSON_MODE || echo "  All checks passed ($WARNINGS warnings)"
  if $JSON_MODE; then
    echo "{\"status\":\"pass\",\"errors\":$ERRORS,\"warnings\":$WARNINGS,\"total_files\":$TOTAL}"
  fi
  exit 0
else
  $JSON_MODE || echo "  $ERRORS errors, $WARNINGS warnings"
  if $JSON_MODE; then
    echo "{\"status\":\"fail\",\"errors\":$ERRORS,\"warnings\":$WARNINGS,\"total_files\":$TOTAL}"
  fi
  exit 1
fi
