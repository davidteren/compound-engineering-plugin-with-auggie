# Review Workflow Philosophy Update

**Date:** February 11, 2026
**Based on:** Learnings from PR #6662 review (elopage_web_client)

---

## Core Principle

**The objective is to identify fundamental technical issues, not provide domain-specific commentary.**

---

## What Changed

### Before
Reviews covered everything:
- Security vulnerabilities (XSS, CSRF, open redirects)
- Performance optimizations (bundle size, caching, lazy loading)
- Architecture preferences
- Type safety issues
- Data integrity bugs

**Result:** 43 findings with mixed signal — critical type bugs buried alongside "use native Date instead of moment.js" suggestions.

### After
Reviews focus on fundamental technical correctness:
- Type safety violations that cause runtime crashes
- Data integrity bugs (race conditions, corruption)
- Functional incompleteness (missing features)
- Pattern violations (duplicating existing code)

**Result:** Clear separation between "this is broken" vs. "this could be better."

---

## Updated Agent Scopes

### Security Sentinel
**Before:** Report all security concerns
**After:** Report only fundamental security bugs in PR code (SQL injection, command injection, hardcoded secrets)

**Out of scope:**
- XSS concerns (framework handles escaping)
- CSRF protection (infrastructure)
- Open redirect (defense-in-depth, not bug)
- Security headers (infrastructure)

### Performance Oracle
**Before:** Report all performance opportunities
**After:** Report only blocking performance bugs (O(n²), N+1, memory leaks, infinite loops)

**Out of scope:**
- Bundle size optimization
- Caching strategies
- Lazy loading
- Micro-optimizations

### Kieran TypeScript Reviewer
**Enhanced:** Now explicitly focuses on:
- Unsafe type casts without validation
- Type signatures that lie
- Missing runtime validation
- Null handling bugs

**Out of scope:**
- Style preferences
- "Better" patterns that are subjective

---

## Codebase Context Integration

**NEW REQUIREMENT:** Before flagging duplication or pattern violations:

1. ✅ Search codebase for existing similar functionality
2. ✅ Check if pattern/utility already exists
3. ✅ Cite specific examples when suggesting patterns
4. ✅ Verify pattern is actually used before recommending

**Example:**
- ❌ "Consider extracting this to a util"
- ✅ "This duplicates `SessionValidator.validate()` in `utils/session.utils.ts` — consider reusing"

---

## Synthesis Filtering

**NEW STEP:** During synthesis, actively filter out:

1. Security-domain findings (unless fundamental bugs)
2. Performance-domain findings (unless blocking issues)
3. Architecture preferences (unless pattern violations)
4. Any suggestion that starts with "could", "should consider", "might want to"

**Keep only:** "This IS broken because X, will cause Y production issue"

---

## Language & Tone

**REMOVED:**
- ❌ Time estimates ("5-minute fix", "2-hour effort")
- ❌ Performance metrics ("10x faster", "2-10ms overhead")
- ❌ Effort classifications ("Small/Medium/Large")
- ❌ Priority justifications based on time/effort

**KEEP:**
- ✅ Technical severity based on impact ("runtime crash", "data corruption")
- ✅ Clear problem statements
- ✅ Code examples
- ✅ Multiple solution options

---

## Example: Before vs. After

### Before ❌
**Finding:** "XSS vulnerability in PartnerBanner using dangerouslySetInnerHTML"
**Category:** Security
**Priority:** P1
**Rationale:** Could allow session hijacking
**Effort:** 2 minutes

### After ✅
**Finding:** "Type casting without validation causes runtime crash"
**Category:** Type Safety
**Priority:** P1
**Rationale:** If API returns partial data, `moment.utc(undefined)` throws
**Evidence:** Line 109 casts to `PartnerContext` after checking only 1 of 12 fields

---

## Files Updated

1. **`commands/workflows/review.md`**
   - Added "Review Philosophy" section
   - Updated synthesis tasks with filtering rules
   - Added codebase context requirements

2. **`agents/review/kieran-typescript-reviewer.md`**
   - Added "REVIEW FOCUS: Fundamental Technical Issues Only" section
   - Defined in-scope vs. out-of-scope clearly

3. **`agents/review/security-sentinel.md`**
   - Added "SCOPE LIMITATION: Fundamental Bugs Only" section
   - Clarified report vs. don't report

4. **`agents/review/performance-oracle.md`**
   - Added "SCOPE LIMITATION: Blocking Issues Only" section
   - Distinguished bugs from optimizations

---

## Expected Outcome

**Future reviews will:**
- Identify 5-10 critical technical issues (not 40+)
- Focus on type safety, data integrity, functional correctness
- Reference existing codebase patterns
- Avoid domain-specific commentary

**Management benefit:**
- Clearer signal on developer capability
- Focus on what matters: "Is the code technically correct?"
- Less noise from optimization suggestions

---

## Testing This Update

**Next PR review should produce:**
- Findings limited to: type bugs, race conditions, missing validation, functional gaps
- All findings cite codebase context where relevant
- No security/performance domain commentary
- Clear assessment of technical correctness

---

**Updated by:** David Teren
**Approved for:** Production use in Ablefy code reviews
