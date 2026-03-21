# Auggie-MCP File Tracking

Canonical list of files containing `mcp__auggie-mcp__codebase-retrieval` or `codebase-retrieval` references that must survive every upstream merge.

## Review Agents (10 files) — "Codebase Search Strategy" section

Each adds a Primary/Secondary search pattern block:

- `agents/review/architecture-strategist.md`
- `agents/review/code-simplicity-reviewer.md`
- `agents/review/dhh-rails-reviewer.md`
- `agents/review/kieran-rails-reviewer.md`
- `agents/review/kieran-python-reviewer.md`
- `agents/review/kieran-typescript-reviewer.md`
- `agents/review/pattern-recognition-specialist.md`
- `agents/review/performance-oracle.md`
- `agents/review/security-sentinel.md`
- `agents/review/agent-native-reviewer.md`

## Research Agents (2 files) — PRIMARY search tool

- `agents/research/repo-research-analyst.md`
- `agents/research/best-practices-researcher.md`

## Workflow Agents (2 files) — contextual semantic search

- `agents/workflow/pr-comment-resolver.md`
- `agents/workflow/bug-reproduction-validator.md`

## Skills (9 files) — inline codebase-retrieval references

- `skills/ce-review/SKILL.md` — "Pre-Agent Codebase Scan"
- `skills/ce-plan/SKILL.md` — "Codebase Context" step
- `skills/ce-work/SKILL.md` — "find similar patterns"
- `skills/ce-brainstorm/SKILL.md` — "Topic Scan" step
- `skills/deepen-plan/SKILL.md` — code-specific context
- `skills/reproduce-bug/SKILL.md` — "Codebase Context First"
- `skills/agent-native-architecture/SKILL.md` — Architecture Checklist
- `skills/ce-compound-refresh/SKILL.md` — codebase verification
- `skills/ce-ideate/SKILL.md` — quick context scan

## Documentation (3 files)

- `AGENTS.md` — "Codebase Search Best Practices" section
- `README.md` — "Optional: Augment Codebase Retrieval" section
- `CHANGELOG.md` — v2.30.1 entry

## Standard auggie-mcp Pattern for Agents

Insert after the agent's role description, before workflow steps:

```markdown
### Codebase Search Strategy

**Primary (if available)**: Use `mcp__auggie-mcp__codebase-retrieval` for semantic code understanding:
- Set `directory_path` to the project root
- Use natural language `information_request` (e.g., "Find [relevant query]")

**Secondary**: Use native content-search (e.g., Grep) for exact identifiers, native file-search/glob (e.g., Glob) for file patterns.
```

## Standard auggie-mcp Pattern for Skills

Insert contextually — typically near existing search/scan instructions:

```markdown
Use `mcp__auggie-mcp__codebase-retrieval` (if available) for semantic code understanding; fall back to native file-search/glob and content-search tools.
```

## Historical Notes

- v2.30.1: Initial integration across 23 files
- v2.40.0 sync: brainstorming/SKILL.md moved to ce-brainstorm/SKILL.md
- v2.47.0 sync: CLAUDE.md became @AGENTS.md pointer; Codebase Search Best Practices moved to AGENTS.md; added ce-compound-refresh and ce-ideate (total: 26 files)
