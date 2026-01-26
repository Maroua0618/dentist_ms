# Sprint Planning & Scrum Process

## 📅 Sprint Structure

**Sprint Duration:** 2 weeks  
**Team Capacity:** 30-40 story points per sprint  
**Sprint Start:** Monday  
**Sprint End:** Friday (2 weeks later)

---

## 🎯 Sprint Goals

### Current Sprint (Sprint 3)

**Duration:** Jan 20 - Feb 2, 2026  
**Goal:** Complete core patient management and initiate billing module

**Key Deliverables:**

- ✅ Role-based patient deletion (Admin only)
- 🟢 Advanced patient filtering
- 📝 Appointment status management
- 📝 Invoice creation system
- 📝 Payment recording

**Sprint Metrics:**

- Committed: 34 story points
- Completed: TBD
- Velocity: TBD

---

## 📊 Definition of Done (DoD)

### User Story DoD Checklist

- [ ] Code written and follows style guide
- [ ] Unit tests written (>80% coverage)
- [ ] Code reviewed by at least one team member
- [ ] All acceptance criteria met
- [ ] No critical or high-priority bugs
- [ ] UI/UX approved
- [ ] Documentation updated
- [ ] Deployed to staging environment
- [ ] Product Owner acceptance

### Sprint DoD Checklist

- [ ] All committed stories completed
- [ ] Sprint goal achieved
- [ ] Code merged to main branch
- [ ] Sprint review completed
- [ ] Sprint retrospective held
- [ ] Next sprint planned

---

## 🗓️ Scrum Ceremonies

### 1. Sprint Planning (4 hours)

**When:** First Monday of sprint  
**Duration:** 4 hours (2-week sprint)  
**Participants:** Dev Team, Product Owner, Scrum Master

**Agenda:**

- **Part 1 (2 hours):** What will we deliver?
  - Review product backlog
  - Clarify user stories
  - Commit to sprint goal
  - Select stories for sprint backlog

- **Part 2 (2 hours):** How will we do it?
  - Break stories into tasks
  - Estimate tasks (hours)
  - Assign tasks to team members
  - Identify dependencies

**Output:**

- Sprint goal defined
- Sprint backlog created
- Team commitment

---

### 2. Daily Standup (15 minutes)

**When:** Every working day, 9:00 AM  
**Duration:** 15 minutes max  
**Participants:** Dev Team, Scrum Master (PO optional)

**Three Questions:**

1. What did I complete yesterday?
2. What will I work on today?
3. Are there any blockers?

**Format:**

```
Developer 1:
✅ Yesterday: Completed US-006 (Delete Patient)
🔨 Today: Working on US-009 (Filter Patients)
🚫 Blockers: None

Developer 2:
✅ Yesterday: Fixed navbar overflow issues
🔨 Today: Starting US-014 (Create Invoice)
🚫 Blockers: Waiting for design approval
```

**Anti-Patterns to Avoid:**

- ❌ Solving problems (take offline)
- ❌ Status reports to manager
- ❌ Going over 15 minutes
- ❌ Skipping regularly

---

### 3. Sprint Review (2 hours)

**When:** Last Friday of sprint  
**Duration:** 2 hours  
**Participants:** Dev Team, Product Owner, Stakeholders

**Agenda:**

1. **Demo** (60 min)
   - Showcase completed stories
   - Live demonstration
   - Gather feedback

2. **Backlog Refinement** (30 min)
   - Review upcoming stories
   - Update product backlog
   - Adjust priorities

3. **Metrics Review** (30 min)
   - Velocity
   - Burndown chart
   - Quality metrics

**Demo Script Template:**

```markdown
### US-006: Delete Patient (Admin Only)

**As an** administrator  
**I want** to delete patient records  
**So that** we can remove incorrect entries

**Demo:**

1. Login as receptionist → delete button hidden ✓
2. Login as doctor → delete button hidden ✓
3. Login as admin → delete button visible ✓
4. Click delete → confirmation dialog appears ✓
5. Confirm deletion → patient removed ✓

**Acceptance Criteria Met:** 5/5
```

---

### 4. Sprint Retrospective (1.5 hours)

**When:** After Sprint Review  
**Duration:** 1.5 hours  
**Participants:** Dev Team, Scrum Master

**Format:** Start, Stop, Continue

**Template:**

```
🟢 START (What should we start doing?)
- Pair programming for complex features
- Code reviews before merge
- Daily deployment to staging

🔴 STOP (What should we stop doing?)
- Committing directly to main
- Skipping unit tests
- Over-committing story points

🔵 CONTINUE (What's working well?)
- Daily standups at 9 AM
- BLoC pattern for state management
- Documentation updates
```

**Action Items:**
| Action | Owner | Deadline |
|--------|-------|----------|
| Set up CI/CD pipeline | Dev 1 | Sprint 4 |
| Create code review checklist | Dev 2 | Next week |
| Improve test coverage | Team | Sprint 4 |

---

### 5. Backlog Refinement (2 hours/week)

**When:** Mid-sprint (Wednesday)  
**Duration:** 2 hours  
**Participants:** Dev Team, Product Owner

**Activities:**

- Review upcoming user stories
- Add acceptance criteria
- Break down large stories
- Estimate story points
- Clarify requirements

**Refinement Checklist:**

- [ ] Story has clear title
- [ ] Acceptance criteria defined
- [ ] Story points estimated
- [ ] Dependencies identified
- [ ] Technical approach discussed

---

## 📈 Estimation Techniques

### Planning Poker

**Process:**

1. Read user story aloud
2. Discuss clarifications
3. Each member selects card (1, 2, 3, 5, 8, 13, 20, ∞, ?)
4. Reveal simultaneously
5. Discuss differences
6. Re-estimate until consensus

**Story Point Scale:**

- **1 point:** Trivial (< 2 hours)
- **2 points:** Simple (2-4 hours)
- **3 points:** Easy (4-8 hours)
- **5 points:** Medium (1-2 days)
- **8 points:** Complex (2-3 days)
- **13 points:** Very Complex (3-5 days)
- **20 points:** Too large - break down

---

## 📊 Sprint Tracking

### Burndown Chart

```
Story Points
40 │ ●
35 │   ●
30 │     ●
25 │       ●
20 │         ●
15 │           ●
10 │             ●
 5 │               ●
 0 │                 ●
   └───────────────────
   D1 D3 D5 D7 D9 D11

● Actual  ─ Ideal
```

### Sprint Board (Kanban)

```
┌───────────┬───────────┬───────────┬───────────┐
│  To Do    │ In Progress│  Review   │   Done    │
├───────────┼───────────┼───────────┼───────────┤
│ US-013 (3)│ US-009 (5)│ US-006 (3)│ US-022 (5)│
│ US-014 (8)│ US-012 (5)│           │ US-023 (3)│
│ US-015 (5)│           │           │           │
│ US-020 (5)│           │           │           │
├───────────┼───────────┼───────────┼───────────┤
│ 21 pts    │ 10 pts    │  3 pts    │  8 pts    │
└───────────┴───────────┴───────────┴───────────┘
```

---

## 🎯 Sprint Anti-Patterns

### What to Avoid

1. **Scope Creep**
   - ❌ Adding stories mid-sprint
   - ✅ Maintain sprint commitment

2. **Unfinished Work**
   - ❌ Carrying over stories
   - ✅ Complete committed stories

3. **Skipped Ceremonies**
   - ❌ Missing standups/retros
   - ✅ Attend all ceremonies

4. **Gold Plating**
   - ❌ Adding unplanned features
   - ✅ Stick to acceptance criteria

5. **Hero Programming**
   - ❌ One person doing everything
   - ✅ Distribute work evenly

---

## 📝 Sprint Templates

### Sprint Planning Template

```markdown
# Sprint [Number] Planning

**Sprint Goal:** [Goal statement]
**Duration:** [Start Date] - [End Date]
**Team Capacity:** [Story Points]

## Committed Stories

| ID     | Story   | Points | Assignee |
| ------ | ------- | ------ | -------- |
| US-XXX | [Title] | X      | [Name]   |

## Sprint Backlog Tasks

- [ ] Task 1 (4h) - [Assignee]
- [ ] Task 2 (2h) - [Assignee]

## Dependencies

- [List dependencies]

## Risks

- [List potential risks]
```

### Sprint Review Template

```markdown
# Sprint [Number] Review

**Date:** [Date]
**Attendees:** [Names]

## Completed Stories (XX/XX)

- ✅ US-XXX: [Title] (X pts)
- ✅ US-XXX: [Title] (X pts)

## Incomplete Stories

- ❌ US-XXX: [Title] - [Reason]

## Demo Highlights

- [Key features demonstrated]

## Stakeholder Feedback

- [Feedback items]

## Metrics

- Committed: XX pts
- Completed: XX pts
- Velocity: XX pts
```

### Retrospective Template

```markdown
# Sprint [Number] Retrospective

**Date:** [Date]

## What Went Well 🟢

- Item 1
- Item 2

## What Didn't Go Well 🔴

- Item 1
- Item 2

## Action Items

| Action   | Owner  | Due Date |
| -------- | ------ | -------- |
| [Action] | [Name] | [Date]   |

## Kudos 🎉

- Shoutout to [Name] for [Achievement]
```

---

## 🚀 Sprint Best Practices

### 1. Maintain Sustainable Pace

- No overtime/burnout
- Realistic commitments
- Buffer for unexpected issues

### 2. Focus on Sprint Goal

- All work contributes to goal
- Say no to scope creep
- Protect team's commitment

### 3. Continuous Communication

- Daily standups
- Slack for quick questions
- Regular pair programming

### 4. Quality First

- Don't skip testing
- Code reviews mandatory
- Refactor as you go

### 5. Embrace Change

- Adapt based on feedback
- Experiment with processes
- Continuous improvement

---

## 📊 Metrics & Reporting

### Key Metrics

1. **Velocity** - Story points completed per sprint
2. **Sprint Burndown** - Work remaining over time
3. **Quality** - Bug count, test coverage
4. **Team Happiness** - Satisfaction score (1-5)
5. **Technical Debt** - Tracked separately

### Reporting Frequency

- **Daily:** Burndown chart update
- **Weekly:** Velocity trend
- **Sprint End:** Full metrics review
- **Monthly:** Cumulative reports

---

**Sprint Process Owner:** Scrum Master  
**Last Review:** January 2026  
**Next Review:** End of Sprint 3
