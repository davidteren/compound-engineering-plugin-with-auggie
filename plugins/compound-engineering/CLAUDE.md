# Compounding Engineering Plugin Development

## Versioning Requirements

**IMPORTANT**: Every change to this plugin MUST include updates to all three files:

1. **`.claude-plugin/plugin.json`** - Bump version using semver
2. **`CHANGELOG.md`** - Document changes using Keep a Changelog format
3. **`README.md`** - Verify/update component counts and tables

### Version Bumping Rules

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, major reorganization
- **MINOR** (1.0.0 → 1.1.0): New agents, commands, or skills
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, doc updates, minor improvements

### Pre-Commit Checklist

Before committing ANY changes:

- [ ] Version bumped in `.claude-plugin/plugin.json`
- [ ] CHANGELOG.md updated with changes
- [ ] README.md component counts verified
- [ ] README.md tables accurate (agents, commands, skills)
- [ ] plugin.json description matches current counts

### Directory Structure

```
agents/
├── review/     # Code review agents
├── research/   # Research and analysis agents
├── design/     # Design and UI agents
├── workflow/   # Workflow automation agents
└── docs/       # Documentation agents

commands/
├── workflows/  # Core workflow commands (workflows:plan, workflows:review, etc.)
└── *.md        # Utility commands

skills/
└── *.md        # All skills at root level
```

## Command Naming Convention

**Workflow commands** use `workflows:` prefix to avoid collisions with built-in commands:
- `/workflows:plan` - Create implementation plans
- `/workflows:review` - Run comprehensive code reviews
- `/workflows:work` - Execute work items systematically
- `/workflows:compound` - Document solved problems

**Why `workflows:`?** Claude Code has built-in `/plan` and `/review` commands. Using `name: workflows:plan` in frontmatter creates a unique `/workflows:plan` command with no collision.

## Skill Compliance Checklist

When adding or modifying skills, verify compliance with skill-creator spec:

### YAML Frontmatter (Required)

- [ ] `name:` present and matches directory name (lowercase-with-hyphens)
- [ ] `description:` present and describes **what it does and when to use it** (per official spec: "Explains code with diagrams. Use when exploring how code works.")

### Reference Links (Required if references/ exists)

- [ ] All files in `references/` are linked as `[filename.md](./references/filename.md)`
- [ ] All files in `assets/` are linked as `[filename](./assets/filename)`
- [ ] All files in `scripts/` are linked as `[filename](./scripts/filename)`
- [ ] No bare backtick references like `` `references/file.md` `` - use proper markdown links

### Writing Style

- [ ] Use imperative/infinitive form (verb-first instructions)
- [ ] Avoid second person ("you should") - use objective language ("To accomplish X, do Y")

### Quick Validation Command

```bash
# Check for unlinked references in a skill
grep -E '`(references|assets|scripts)/[^`]+`' skills/*/SKILL.md
# Should return nothing if all refs are properly linked

# Check description format - should describe what + when
grep -E '^description:' skills/*/SKILL.md
```

## Codebase Search Best Practices

### When to Use Each Tool

| Tool | Use When | Example |
|------|----------|---------|
| `mcp__auggie-mcp__codebase-retrieval` | Understanding architecture, finding patterns, semantic search | "How is authentication implemented?" |
| Grep | Finding exact identifiers, counting references, regex patterns | `class UserService`, `def process_payment` |
| Glob | Finding files by path pattern | `**/*.test.ts`, `app/models/*.rb` |
| Context7 (`mcp__plugin_compound-engineering_context7`) | Framework/library documentation | "React Query cache invalidation" |

### Best Practice: Always Search Before Suggesting

Before suggesting architectural changes, refactoring, or new patterns:
1. Use `mcp__auggie-mcp__codebase-retrieval` to find how similar things are done in this codebase
2. Match existing conventions rather than introducing new ones
3. Reference specific files and line numbers in your recommendations

### Using codebase-retrieval Effectively

- Set `directory_path` to the project root directory
- Use natural language `information_request` — describe what you need conceptually (e.g., "Find authentication middleware and session management")
- Use Grep/Glob for exact identifier matching (e.g., "find all references to `UserService`")
- codebase-retrieval is optional — agents gracefully fall back to Grep/Glob if unavailable

## Documentation

See `docs/solutions/plugin-versioning-requirements.md` for detailed versioning workflow.
