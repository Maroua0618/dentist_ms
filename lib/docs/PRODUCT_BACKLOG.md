# Product Backlog

## 📋 Backlog Management

**Last Updated:** January 2026  
**Product Owner:** TBD  
**Next Refinement:** TBD

---

## 🎯 Epics Overview

| Epic ID | Epic Name                 | Story Count | Total Points | Status         |
| ------- | ------------------------- | ----------- | ------------ | -------------- |
| EP-01   | Authentication & Security | 2           | 13           | ✅ Completed   |
| EP-02   | Patient Management        | 7           | 34           | 🟡 In Progress |
| EP-03   | Appointment System        | 4           | 24           | 🟡 In Progress |
| EP-04   | Billing & Finance         | 4           | 26           | 📝 Planned     |
| EP-05   | Dashboard & Analytics     | 2           | 16           | 🟡 In Progress |
| EP-06   | Settings & Configuration  | 2           | 8            | 📝 Planned     |
| EP-07   | Medical Records           | 3           | 13           | ✅ Completed   |

---

## 🔥 Sprint Backlog - Current Sprint

### Sprint 3 (Current)

**Sprint Goal:** Complete patient management and start billing features  
**Duration:** Jan 20 - Feb 2, 2026  
**Capacity:** 35 story points

| ID     | User Story                  | Priority | Points | Status         | Assignee |
| ------ | --------------------------- | -------- | ------ | -------------- | -------- |
| US-006 | Delete Patient (Admin only) | High     | 3      | ✅ Done        | Dev Team |
| US-009 | Filter Patients             | High     | 5      | 🟢 In Progress | Dev Team |
| US-012 | Update Appointment Status   | High     | 5      | 📝 To Do       | Dev Team |
| US-013 | Cancel Appointment          | Medium   | 3      | 📝 To Do       | Dev Team |
| US-014 | Create Invoice              | High     | 8      | 📝 To Do       | Dev Team |
| US-015 | Record Payment              | High     | 5      | 📝 To Do       | Dev Team |
| US-020 | Update Clinic Information   | Medium   | 5      | 📝 To Do       | Dev Team |

**Sprint Commitment:** 34 points

---

## 📅 Future Sprints

### Sprint 4 - Planned

**Goal:** Advanced reporting and remaining billing features  
**Planned Points:** 30

- US-016: View Financial Reports (8)
- US-017: Manage Expenses (5)
- US-019: View Activity Charts (8)
- US-024: Add Medical Record (5)
- Bug fixes and improvements (4)

### Sprint 5 - Planned

**Goal:** Mobile optimization and notifications  
**Planned Points:** 28

- Responsive design improvements
- SMS/Email notifications
- Performance optimization
- Advanced search capabilities

---

## 🏆 Completed Sprints

### Sprint 2 (Jan 6 - Jan 19, 2026)

**Goal:** Patient profiles and appointment scheduling  
**Committed:** 36 | **Completed:** 34 | **Velocity:** 34

**Completed Stories:**

- ✅ US-003: Add New Patient (5)
- ✅ US-004: View Patient Profile (8)
- ✅ US-005: Edit Patient Information (3)
- ✅ US-007: Upload Patient Photo (5)
- ✅ US-008: Search Patients (5)
- ✅ US-010: Schedule Appointment (8)
- ✅ US-022: View Medical Records - Doctor/Admin (5)
- ✅ US-023: Limited Medical Access - Receptionist (3)

**Retrospective Highlights:**

- ✨ Role-based access control implemented successfully
- 🐛 Fixed overflow issues in navbar animation
- 📈 Improved image upload performance

---

### Sprint 1 (Dec 23, 2025 - Jan 5, 2026)

**Goal:** Foundation and authentication  
**Committed:** 32 | **Completed:** 32 | **Velocity:** 32

**Completed Stories:**

- ✅ US-001: Secure Login (5)
- ✅ US-002: Role-Based Access (8)
- ✅ US-018: View Dashboard Metrics (8)
- ✅ Project setup and architecture (11)

---

## 📊 Backlog by Priority

### High Priority (Must Have)

1. US-009: Filter Patients (5)
2. US-012: Update Appointment Status (5)
3. US-014: Create Invoice (8)
4. US-015: Record Payment (5)
5. US-011: View Appointment Calendar (8)

### Medium Priority (Should Have)

6. US-013: Cancel Appointment (3)
7. US-016: View Financial Reports (8)
8. US-019: View Activity Charts (8)
9. US-020: Update Clinic Information (5)
10. US-024: Add Medical Record (5)

### Low Priority (Nice to Have)

11. US-017: Manage Expenses (5)
12. US-021: Manage User Profile (3)
13. Advanced analytics features
14. Multi-clinic support
15. Third-party integrations

---

## 🔄 Backlog Refinement

### Upcoming Refinement Topics

- [ ] Define acceptance criteria for notification system
- [ ] Break down reporting features into smaller stories
- [ ] Technical debt items from Sprint 1-2
- [ ] Performance optimization stories
- [ ] Mobile app specific stories

### Technical Debt

| Item                            | Priority | Estimated Points |
| ------------------------------- | -------- | ---------------- |
| Improve error handling in BLoCs | Medium   | 5                |
| Add comprehensive unit tests    | High     | 8                |
| Optimize database queries       | Medium   | 5                |
| Implement caching strategy      | Low      | 3                |
| Code documentation              | Low      | 3                |

---

## 🐛 Bugs & Issues

### Critical Bugs

- None currently

### High Priority Bugs

- None currently

### Medium Priority Bugs

- Minor UI alignment issues in small screens (2 pts)

### Low Priority Bugs

- None currently

---

## 🚀 Feature Requests

### From Stakeholders

1. **SMS Notifications** - Send appointment reminders via SMS
2. **Email Reports** - Automated daily/weekly reports
3. **Multi-language Support** - Additional languages beyond French
4. **Mobile App** - Native mobile application
5. **Backup System** - Automated data backup

### From Users

1. Dark mode support
2. Keyboard shortcuts for common actions
3. Export patient data to PDF
4. Treatment templates
5. Appointment recurring schedules

---

## 📈 Velocity Tracking

| Sprint   | Planned | Completed | Velocity |
| -------- | ------- | --------- | -------- |
| Sprint 1 | 32      | 32        | 32       |
| Sprint 2 | 36      | 34        | 34       |
| Sprint 3 | 34      | TBD       | TBD      |

**Average Velocity:** 33 points  
**Trend:** Stable ➡️

---

## 🎯 Release Planning

### Version 1.0 (MVP) - Target: Feb 2026

**Required Epics:**

- ✅ EP-01: Authentication & Security
- 🟡 EP-02: Patient Management (90% complete)
- 🟡 EP-03: Appointment System (75% complete)
- 📝 EP-04: Billing & Finance (40% complete)
- ✅ EP-05: Dashboard & Analytics (Core features done)

**Remaining Points:** ~45  
**Estimated Completion:** 2 more sprints

### Version 1.1 - Target: March 2026

- Advanced reporting
- Notification system
- Performance improvements
- Enhanced mobile experience

### Version 2.0 - Target: Q2 2026

- Multi-clinic support
- Advanced analytics
- Third-party integrations
- API for external systems

---

## 📝 Notes

**Dependencies:**

- US-014 (Create Invoice) must be completed before US-015 (Record Payment)
- US-010 (Schedule Appointment) required for US-012 (Update Appointment Status)

**Risks:**

- Learning curve for Supabase features may impact velocity
- Performance optimization may require additional sprints

**Assumptions:**

- Development team of 2-3 developers
- 2-week sprint cadence
- Product Owner available for clarifications
