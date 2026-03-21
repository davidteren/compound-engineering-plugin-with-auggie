# Conflict Resolution Rules

When upstream changes conflict with our auggie-mcp additions, resolve using these rules.

## General Principle

Take upstream changes, then re-apply our auggie-mcp additions in the appropriate location.

## Specific Rules

### Version Numbers (`plugin.json`, `marketplace.json`)
Take upstream version — it tracks the authoritative release line.

### Component Counts (descriptions with "X agents, Y skills")
Take upstream counts — they reflect the actual component inventory.

### CHANGELOG.md
Keep BOTH upstream entries AND our v2.30.1 auggie-mcp entry. Upstream entries go above ours chronologically.

### README.md
Keep upstream content AND preserve the "Optional: Augment Codebase Retrieval" section. If upstream added content near our section, include both.

### AGENTS.md / CLAUDE.md
If upstream restructures these files (e.g., CLAUDE.md becomes `@AGENTS.md` pointer), move our "Codebase Search Best Practices" section to whichever file holds the actual content.

### Skills That Moved
If upstream moved a file we modified, apply our auggie-mcp additions to the new location using the standard pattern from [auggie-mcp-files.md](./auggie-mcp-files.md).

### Agent Files with Conflicts
Keep upstream structural changes AND our "Codebase Search Strategy" section. If upstream reorganized the file, insert our section in a logical position (after the agent's role description, before the workflow steps).

### New Upstream Files
After merge, check for new agents/skills that perform code analysis. Add auggie-mcp integration to those that would benefit from semantic search. Skip pure documentation, configuration, or task-management skills.

## Lessons Learned

### v2.40.0 Sync
- Commands migrated to skills (v2.39.0) — auggie-mcp additions followed to new `skills/ce-*/SKILL.md` locations

### v2.47.0 Sync
- CLAUDE.md became `@AGENTS.md` pointer — moved Codebase Search Best Practices to AGENTS.md
- `brainstorming/SKILL.md` deleted, replaced by `ce-brainstorm/SKILL.md` — auggie-mcp reference re-applied to new location
- New skills `ce-compound-refresh` and `ce-ideate` added with auggie-mcp integration
- Upstream adopted cross-platform tool naming ("native file-search/glob" instead of "Grep") — our references updated to match
