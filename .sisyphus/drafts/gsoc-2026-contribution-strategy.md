# Draft: GSoC 2026 CCExtractor Contribution Strategy

## User Profile
- **Skills**: Flexible, good with anything that comes their way
- **Goal**: Maximize selection chances, prefer projects with more slots
- **Timeline**: 1 month (Standard - 2-3 solid contributions)
- **Constraint**: Do NOT look at their GitHub account

## Strategy Selection
User wants "guaranteed selection" + "many slots"

### Analysis of GSoC Ideas Page

**High Competition (Avoid):**
- CCExtractor Core (Release 1.00) - "Hard", flagship project
- Ultimate Alarm Clock - Popular, Flutter-based
- COSMIC Session - Trending (Wayland, Rust)

**Medium Competition (Consider):**
- TaskWarrior / CCSync integration
- Task Server III
- Sample Platform NG
- Desktop Actions in Ilia

**Low Competition / Niche (Best for Maximizing Chances):**
- DTMB support (Chinese TV standard)
- Japanese caption support
- Linux network throughput tuning
- BitTorrent over TLS
- rTorrent projects (unification, RPC interface)

**Key Quote from Page:**
> "Project popularity: Some ideas just have more competition, so if participating in GSoC is a top priority for you (over working on a specific project), consider applying to one of the 'niche' ideas."

## Qualification Path (Based on Page Guidelines)

The page clearly states:
> "Work on our core tool: Even if you are going to be working on something totally different... if you can dig into our (messy) code base, find yourself your way around it, and fix a few bugs, you are just the kind of person we can trust."

**Strategy:**
1. Start with core tool contributions (GitHub issues, some labeled "easy")
2. Then do project-specific work
3. Join Zulip (required for community bonding)

## Historical GSoC Data Research

### 2023 (4 students accepted):
1. **Flood Mobile** (Flutter) - Amit Amrutiya
2. **The Sample Platform** (React/JS) - Tarun Arora
3. **Core/Rust Implementation** (Rust/C) - Elbert Ronnie
4. **Teletext Research** (Core) - Rahul

### 2024:
1. **Chirag Tyagi** - Core project (mentored by Carlos)
2. **CCExtractor 1.00** - Major Rust integration, testing, release prep (3 mentors: Carlos, Willem, Punit)

### 2021-2022:
- **Flood Mobile** (Flutter) - Pratik Baid (2021)
- **Beacon** - Multi-year project (2021-2022)
- **FFmpeg API Update** - Core tool work (2022)
- **OCR Subsystem** - Image processing/Tesseract

### Pattern Analysis:
**Most Frequent Project Areas:**
1. **Flutter Apps** - Flood Mobile appeared multiple times (2021, 2023)
2. **Core/Rust Work** - Consistently funded every year
3. **Sample Platform** - Recurring project (2022, 2023)
4. **Research/OCR** - Occasional but funded

**Slot Allocation:**
- GSoC doesn't allocate per-project slots
- Org gets total slots, mentors distribute
- CCExtractor typically gets **3-5 students/year**
- More mentors = more potential slots

**Key Insight:**
Projects with **multiple mentors** have higher acceptance probability because:
- More mentor capacity = can accept more students
- Backup mentors available = safer for org
- Example: CCExtractor 1.00 has 3 mentors (Carlos + Willem + Punit)

## Recommendations for User:
**Best Bet Projects (Based on historical frequency + mentor count):**
1. **CCExtractor Core (Release 1.00)** - 3 mentors, flagship project
2. **Flutter Apps** - Consistently funded over multiple years
3. **Sample Platform NG** - Recurring project, multiple years

## DECISION MADE: CCExtractor Core (Release 1.00)

**Why This is the Best Choice:**
- 3 mentors (Carlos, Willem, Punit) = highest slot probability
- Flagship project for 2024-2026
- Integrating pending Rust PRs, testing, preparing 1.00 release
- "Hard" difficulty = less competition, more respect for completion

## User's 1-Month Contribution Strategy

### Week 1: Core Tool Warm-up (MANDATORY)
**Goal:** Prove you can handle the messy C codebase
- Fix 2-3 "easy" GitHub issues in CCExtractor core
- Join Zulip chat (make yourself visible)
- Attend office hours (Sundays 10:30 AM SF time)

### Week 2-3: Project-Specific Work
**Goal:** Demonstrate Core 1.00 competency
- Contribute to Rust integration work
- Write tests for pending PRs
- Document integration issues

### Week 4: Proposal + Community Bonding
**Goal:** Convert contributions into proposal
- Draft detailed proposal with mentor feedback
- Refine based on Zulip discussions
- Get mentor endorsement before submission

## Key Resources
- GitHub: CCExtractor/ccextractor
- Ideas page: ccextractor.org/docs/ideas_page_for_summer_of_code_2026/
- Office hours: Sundays, 10:30 AM SF time (Google Meet)
- Zulip: (find link on website)
