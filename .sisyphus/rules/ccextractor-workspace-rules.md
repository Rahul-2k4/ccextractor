# 🛡️ CCExtractor Workspace Rules
## **CRITICAL: Must Be Followed in EVERY Session**

> **Status**: ENFORCED - These rules apply to ALL CCExtractor work, regardless of session context
> **Scope**: CCExtractor org repositories (ccextractor, sample-platform, flood-mobile, etc.)
> **Owner**: [Your Name]
> **Effective**: Immediately and Forever

---

## **RULE #1: Surgical Commits Only**

### What This Means
**ONLY commit files that are DIRECTLY related to the issue/PR you're working on.**

### ✅ ALLOWED Commits
- Code changes that fix the specific bug
- Feature implementation for the specific issue
- Tests related to the specific fix/feature
- Documentation for the specific change
- Configuration changes required for the specific issue

### ❌ FORBIDDEN Commits
- Debugging code (`// print("here")`, commented-out logs)
- Temporary files (test outputs, random notes)
- IDE configuration files (.vscode/, .idea/, etc.)
- Dependency updates unrelated to the issue
- "While I'm here" changes (refactoring unrelated code)
- Bulk file updates (formatting everything)
- AI-generated hallucinations or redundant comments

### Pre-Commit Checklist
Before EVERY commit, ask:
```
1. Does this file directly fix the issue?
2. Is this change necessary for the PR?
3. Can I explain why this file is in the commit?
```

If answer is NO to any → **DON'T COMMIT IT**

---

## **RULE #2: Hygiene Discipline**

### What This Means
**Keep the workspace CLEAN. Check upstream main branch. Use git diff to verify what's necessary.**

### Before Starting Work
```bash
# 1. Fetch latest from upstream
git fetch upstream

# 2. Check what you're about to change
git status

# 3. Ensure you're on the right branch
git branch --show-current

# 4. Ensure your branch is up to date
git rebase upstream/main  # or upstream/master
```

### During Work
```bash
# 1. See what you've changed
git diff

# 2. See what you're about to commit
git diff --cached

# 3. Ask: Is this NECESSARY for the issue?
```

### Before Committing
```bash
# 1. Review the entire diff
git diff

# 2. Remove unnecessary files
git checkout -- unnecessary_file.py

# 3. Unstage unnecessary changes
git reset HEAD unnecessary_file.py

# 4. Only stage what's needed
git add specific_file_needed_for_fix.py

# 5. Commit with CLEAR message
git commit -m "fix(specific_module): resolve issue #N - brief description"
```

### Clean Workspace Means
- No random test files lying around
- No `test.py`, `debug.txt`, `temp/` directories
- No `.DS_Store`, `Thumbs.db`, `*.swp` files
- No AI-generated garbage files
- No commented-out debugging code
- No "I'll fix this later" TODOs in committed code

---

## **RULE #3: Persistent Knowledge Logging**

### What This Means
**ALWAYS store key findings, bugs, failure steps in the Obsidian vault.**

### What to Log
1. **Key Findings** - Important discoveries, architectural insights
2. **Bugs Encountered** - Symptoms, reproduction steps, workarounds
3. **Failure Steps** - What didn't work and why
4. **Success Patterns** - What worked and lessons learned

### Obsidian Vault Structure
```
/home/rahul/Desktop/obsedian_store/ccextractor/
├── CCExtractor_Work/       # Create this directory
│   ├── Findings/           # Key findings
│   ├── Bugs/               # Bug reports
│   ├── Failures/           # What didn't work
│   ├── Successes/          # What worked
│   └── Commands/           # Useful commands/snippets
```

### Logging Templates

#### Key Finding Template
```markdown
# [Date] Key Finding: [Title]

## Discovery
[What you found]

## Why It Matters
[Implications for the project]

## Related Files
- File: `path/to/file`

## Tags
#finding #category #gsoc2026
```

#### Bug Report Template
```markdown
# [Date] Bug: [Title]

## Symptoms
[What went wrong]

## Reproduction Steps
1. Step 1
2. Step 2

## Error Output
```
[Paste error here]
```

## Resolution
- [ ] Fixed
- [ ] Workaround found
- [ ] Still open

## Tags
#bug #severity #component
```

### When to Log
- **Immediately** after discovering something important
- **Before** switching tasks
- **After** hitting a blocker
- **At end** of each work session

---

## 🔍 **SESSION START CHECKLIST**

### At the Beginning of EVERY Session
```bash
# 1. Navigate to CCExtractor workspace
cd /home/rahul/Desktop/ccextractor

# 2. Load GitHub token
source .env.github

# 3. Check workspace status
git status

# 4. Check for upstream updates
git fetch upstream
git log HEAD..upstream/main --oneline

# 5. Open today's session note in Obsidian
```

---

## 🚨 **VIOLATION CONSEQUENCES**

### If Rules Are NOT Followed
- ❌ Repos become messy and unusable
- ❌ Commits become unreviewable
- ❌ Knowledge is lost between sessions
- ❌ GSoC proposal suffers (no evidence of work)
- ❌ Mentors lose confidence (sloppy work)

### If Rules ARE Followed
- ✅ Clean, professional git history
- ✅ Reviewable, mergeable PRs
- ✅ Persistent knowledge base
- ✅ Evidence for GSoC proposal
- ✅ Mentor confidence (quality work)

---

## 📋 **QUICK REFERENCE**

### Before Committing
```bash
git diff                    # What changed?
git diff --cached           # What's staged?
# Is it NECESSARY for the issue?
```

### Before Pushing
```bash
git log origin/main..HEAD   # What will be pushed?
git diff origin/main..HEAD  # Review changes
# Is this reviewable?
```

---

**These rules are NON-NEGOTIABLE. Follow them in EVERY session.**

**Last Updated**: 2026-02-09
**Status**: ACTIVE & ENFORCED
