---
name: document-review
description: Review requirements or plan documents using parallel persona agents that surface role-specific issues. Use when a requirements document or plan document exists and the user wants to improve it.
<<<<<<< HEAD
=======
argument-hint: "[mode:headless] [path/to/document.md]"
>>>>>>> upstream/main
---

# Document Review

Review requirements or plan documents through multi-persona analysis. Dispatches specialized reviewer agents in parallel, auto-fixes quality issues, and presents strategic questions for user decision.

<<<<<<< HEAD
## Phase 1: Get and Analyze Document

**If a document path is provided:** Read it, then proceed.

**If no document is specified:** Ask which document to review, or find the most recent in `docs/brainstorms/` or `docs/plans/` using a file-search/glob tool (e.g., Glob in Claude Code).

### Classify Document Type

After reading, classify the document:
- **requirements** -- from `docs/brainstorms/`, focuses on what to build and why
- **plan** -- from `docs/plans/`, focuses on how to build it with implementation details

### Select Conditional Personas

Analyze the document content to determine which conditional personas to activate. Check for these signals:

**product-lens** -- activate when the document contains:
- User-facing features, user stories, or customer-focused language
- Market claims, competitive positioning, or business justification
- Scope decisions, prioritization language, or priority tiers with feature assignments
- Requirements with user/customer/business outcome focus

**design-lens** -- activate when the document contains:
- UI/UX references, frontend components, or visual design language
- User flows, wireframes, screen/page/view mentions
- Interaction descriptions (forms, buttons, navigation, modals)
- References to responsive behavior or accessibility

**security-lens** -- activate when the document contains:
- Auth/authorization mentions, login flows, session management
- API endpoints exposed to external clients
- Data handling, PII, payments, tokens, credentials, encryption
- Third-party integrations with trust boundary implications

**scope-guardian** -- activate when the document contains:
- Multiple priority tiers (P0/P1/P2, must-have/should-have/nice-to-have)
- Large requirement count (>8 distinct requirements or implementation units)
- Stretch goals, nice-to-haves, or "future work" sections
- Scope boundary language that seems misaligned with stated goals
- Goals that don't clearly connect to requirements

## Phase 2: Announce and Dispatch Personas

### Announce the Review Team

Tell the user which personas will review and why. For conditional personas, include the justification:

```
Reviewing with:
- coherence-reviewer (always-on)
- feasibility-reviewer (always-on)
- scope-guardian-reviewer -- plan has 12 requirements across 3 priority levels
- security-lens-reviewer -- plan adds API endpoints with auth flow
```

### Build Agent List

Always include:
- `compound-engineering:document-review:coherence-reviewer`
- `compound-engineering:document-review:feasibility-reviewer`

Add activated conditional personas:
- `compound-engineering:document-review:product-lens-reviewer`
- `compound-engineering:document-review:design-lens-reviewer`
- `compound-engineering:document-review:security-lens-reviewer`
- `compound-engineering:document-review:scope-guardian-reviewer`

### Dispatch

Dispatch all agents in **parallel** using the platform's task/agent tool (e.g., Agent tool in Claude Code, spawn in Codex). Each agent receives the prompt built from the [subagent template](./references/subagent-template.md) with these variables filled:

| Variable | Value |
|----------|-------|
| `{persona_file}` | Full content of the agent's markdown file |
| `{schema}` | Content of [findings-schema.json](./references/findings-schema.json) |
| `{document_type}` | "requirements" or "plan" from Phase 1 classification |
| `{document_path}` | Path to the document |
| `{document_content}` | Full text of the document |

Pass each agent the **full document** -- do not split into sections.

**Error handling:** If an agent fails or times out, proceed with findings from agents that completed. Note the failed agent in the Coverage section. Do not block the entire review on a single agent failure.

**Dispatch limit:** Even at maximum (6 agents), use parallel dispatch. These are document reviewers with bounded scope reading a single document -- parallel is safe and fast.

## Phase 3: Synthesize Findings

Process findings from all agents through this pipeline. **Order matters** -- each step depends on the previous.

### 3.1 Validate

Check each agent's returned JSON against [findings-schema.json](./references/findings-schema.json):
- Drop findings missing any required field defined in the schema
- Drop findings with invalid enum values
- Note the agent name for any malformed output in the Coverage section

### 3.2 Confidence Gate

Suppress findings below 0.50 confidence. Store them as residual concerns for potential promotion in step 3.4.

### 3.3 Deduplicate

Fingerprint each finding using `normalize(section) + normalize(title)`. Normalization: lowercase, strip punctuation, collapse whitespace.

When fingerprints match across personas:
- If the findings recommend **opposing actions** (e.g., one says cut, the other says keep), do not merge -- preserve both for contradiction resolution in 3.5
- Otherwise merge: keep the highest severity, keep the highest confidence, union all evidence arrays, note all agreeing reviewers (e.g., "coherence, feasibility")

### 3.4 Promote Residual Concerns

Scan the residual concerns (findings suppressed in 3.2) for:
- **Cross-persona corroboration**: A residual concern from Persona A overlaps with an above-threshold finding from Persona B. Promote at P2 with confidence 0.55-0.65.
- **Concrete blocking risks**: A residual concern describes a specific, concrete risk that would block implementation. Promote at P2 with confidence 0.55.

### 3.5 Resolve Contradictions

When personas disagree on the same section:
- Create a **combined finding** presenting both perspectives
- Set `autofix_class: present`
- Frame as a tradeoff, not a verdict

Specific conflict patterns:
- Coherence says "keep for consistency" + scope-guardian says "cut for simplicity" -> combined finding, let user decide
- Feasibility says "this is impossible" + product-lens says "this is essential" -> P1 finding framed as a tradeoff
- Multiple personas flag the same issue -> merge into single finding, note consensus, increase confidence

### 3.6 Route by Autofix Class

| Autofix Class | Route |
|---------------|-------|
| `auto` | Apply automatically -- local deterministic fix (terminology, formatting, cross-references) |
| `present` | Present to user for judgment |

Demote any `auto` finding that lacks a `suggested_fix` to `present` -- the orchestrator cannot apply a fix without concrete replacement text.

### 3.7 Sort

Sort findings for presentation: P0 -> P1 -> P2 -> P3, then by confidence (descending), then by document order (section position).

## Phase 4: Apply and Present

### Apply Auto-fixes

Apply all `auto` findings to the document in a **single pass**:
- Edit the document inline using the platform's edit tool
- Track what was changed for the "Auto-fixes Applied" section
- Do not ask for approval -- these are unambiguously correct (terminology fixes, formatting, cross-references)

### Present Remaining Findings

Present all other findings to the user using the format from [review-output-template.md](./references/review-output-template.md):
- Group by severity (P0 -> P3)
- Include the Coverage table showing which personas ran
- Show auto-fixes that were applied
- Include residual concerns and deferred questions if any

Brief summary at the top: "Applied N auto-fixes. M findings to consider (X at P0/P1)."

### Protected Artifacts

During synthesis, discard any finding that recommends deleting or removing files in:
- `docs/brainstorms/`
- `docs/plans/`
- `docs/solutions/`

These are pipeline artifacts and must not be flagged for removal.

## Phase 5: Next Action

Use the platform's blocking question tool when available (AskUserQuestion in Claude Code, request_user_input in Codex, ask_user in Gemini). Otherwise present numbered options and wait for the user's reply.

Offer:

1. **Refine again** -- another review pass
2. **Review complete** -- document is ready

After 2 refinement passes, recommend completion -- diminishing returns are likely. But if the user wants to continue, allow it.

Return "Review complete" as the terminal signal for callers.
=======
## Phase 0: Detect Mode

Check the skill arguments for `mode:headless`. Arguments may contain a document path, `mode:headless`, or both. Tokens starting with `mode:` are flags, not file paths -- strip them from the arguments and use the remaining token (if any) as the document path for Phase 1.

If `mode:headless` is present, set **headless mode** for the rest of the workflow.

**Headless mode** changes the interaction model, not the classification boundaries. Document-review still applies the same judgment about what has one clear correct fix vs. what needs user judgment. The only difference is how non-auto findings are delivered:
- `auto` fixes are applied silently (same as interactive)
- `present` findings are returned as structured text for the caller to handle -- no AskUserQuestion prompts, no interactive approval
- Phase 5 returns immediately with "Review complete" (no refine/complete question)

The caller receives findings with their original classifications intact and decides what to do with them.

Callers invoke headless mode by including `mode:headless` in the skill arguments, e.g.:
```
Skill("compound-engineering:document-review", "mode:headless docs/plans/my-plan.md")
```


If `mode:headless` is not present, the skill runs in its default interactive mode with no behavior change.

## Phase 1: Get and Analyze Document

**If a document path is provided:** Read it, then proceed.

**If no document is specified (interactive mode):** Ask which document to review, or find the most recent in `docs/brainstorms/` or `docs/plans/` using a file-search/glob tool (e.g., Glob in Claude Code).

**If no document is specified (headless mode):** Output "Review failed: headless mode requires a document path. Re-invoke with: Skill(\"compound-engineering:document-review\", \"mode:headless <path>\")" without dispatching agents.

### Classify Document Type

After reading, classify the document:
- **requirements** -- from `docs/brainstorms/`, focuses on what to build and why
- **plan** -- from `docs/plans/`, focuses on how to build it with implementation details

### Select Conditional Personas

Analyze the document content to determine which conditional personas to activate. Check for these signals:

**product-lens** -- activate when the document makes challengeable claims about what to build and why, or when the proposed work carries strategic weight beyond the immediate problem. The system's users may be end users, developers, operators, maintainers, or any other audience -- the criteria are domain-agnostic. Check for either leg:

*Leg 1 — Premise claims:* The document stakes a position on what to build or why that a knowledgeable stakeholder could reasonably challenge -- not merely describing a task or restating known requirements:
- Problem framing where the stated need is non-obvious or debatable, not self-evident from existing context
- Solution selection where alternatives plausibly exist (implicit or explicit)
- Prioritization decisions that explicitly rank what gets built vs deferred
- Goal statements that predict specific user outcomes, not just restate constraints or describe deliverables

*Leg 2 — Strategic weight:* The proposed work could affect system trajectory, user perception, or competitive positioning, even if the premise is sound:
- Changes that shape how the system is perceived or what it becomes known for
- Complexity or simplicity bets that affect adoption, onboarding, or cognitive load
- Work that opens or closes future directions (path dependencies, architectural commitments)
- Opportunity cost implications -- building this means not building something else

**design-lens** -- activate when the document contains:
- UI/UX references, frontend components, or visual design language
- User flows, wireframes, screen/page/view mentions
- Interaction descriptions (forms, buttons, navigation, modals)
- References to responsive behavior or accessibility

**security-lens** -- activate when the document contains:
- Auth/authorization mentions, login flows, session management
- API endpoints exposed to external clients
- Data handling, PII, payments, tokens, credentials, encryption
- Third-party integrations with trust boundary implications

**scope-guardian** -- activate when the document contains:
- Multiple priority tiers (P0/P1/P2, must-have/should-have/nice-to-have)
- Large requirement count (>8 distinct requirements or implementation units)
- Stretch goals, nice-to-haves, or "future work" sections
- Scope boundary language that seems misaligned with stated goals
- Goals that don't clearly connect to requirements

**adversarial** -- activate when the document contains:
- More than 5 distinct requirements or implementation units
- Explicit architectural or scope decisions with stated rationale
- High-stakes domains (auth, payments, data migrations, external integrations)
- Proposals of new abstractions, frameworks, or significant architectural patterns

## Phase 2: Announce and Dispatch Personas

### Announce the Review Team

Tell the user which personas will review and why. For conditional personas, include the justification:

```
Reviewing with:
- coherence-reviewer (always-on)
- feasibility-reviewer (always-on)
- scope-guardian-reviewer -- plan has 12 requirements across 3 priority levels
- security-lens-reviewer -- plan adds API endpoints with auth flow
```
>>>>>>> upstream/main

### Build Agent List

<<<<<<< HEAD
- Do not rewrite the entire document
- Do not add new sections or requirements the user didn't discuss
- Do not over-engineer or add complexity
- Do not create separate review files or add metadata sections
- Do not modify any of the 4 caller skills (ce-brainstorm, ce-plan, ce-plan-beta, deepen-plan-beta)

## Iteration Guidance

On subsequent passes, re-dispatch personas and re-synthesize. The auto-fix mechanism and confidence gating prevent the same findings from recurring once fixed. If findings are repetitive across passes, recommend completion.
=======
Always include:
- `compound-engineering:document-review:coherence-reviewer`
- `compound-engineering:document-review:feasibility-reviewer`

Add activated conditional personas:
- `compound-engineering:document-review:product-lens-reviewer`
- `compound-engineering:document-review:design-lens-reviewer`
- `compound-engineering:document-review:security-lens-reviewer`
- `compound-engineering:document-review:scope-guardian-reviewer`
- `compound-engineering:document-review:adversarial-document-reviewer`

### Dispatch

Dispatch all agents in **parallel** using the platform's task/agent tool (e.g., Agent tool in Claude Code, spawn in Codex). Each agent receives the prompt built from the subagent template included below with these variables filled:

| Variable | Value |
|----------|-------|
| `{persona_file}` | Full content of the agent's markdown file |
| `{schema}` | Content of the findings schema included below |
| `{document_type}` | "requirements" or "plan" from Phase 1 classification |
| `{document_path}` | Path to the document |
| `{document_content}` | Full text of the document |

Pass each agent the **full document** -- do not split into sections.

**Error handling:** If an agent fails or times out, proceed with findings from agents that completed. Note the failed agent in the Coverage section. Do not block the entire review on a single agent failure.

**Dispatch limit:** Even at maximum (7 agents), use parallel dispatch. These are document reviewers with bounded scope reading a single document -- parallel is safe and fast.

## Phases 3-5: Synthesis, Presentation, and Next Action

After all dispatched agents return, read `references/synthesis-and-presentation.md` for the synthesis pipeline (validate, gate, dedup, promote, resolve contradictions, route by autofix class), auto-fix application, finding presentation, and next-action menu. Do not load this file before agent dispatch completes.

---

## Included References

### Subagent Template

@./references/subagent-template.md

### Findings Schema

@./references/findings-schema.json
>>>>>>> upstream/main
