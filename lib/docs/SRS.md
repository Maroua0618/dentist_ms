# Software Requirements Specification (SRS)

## Dental Clinic Management System

**Version:** 1.0.0  
**Date:** January 2026  
**Status:** Active Development  
**Document Owner:** Product Owner / Development Team

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Overall Description](#2-overall-description)
3. [System Features](#3-system-features)
4. [External Interface Requirements](#4-external-interface-requirements)
5. [System Features Detail](#5-system-features-detail)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [Other Requirements](#7-other-requirements)
8. [Appendix](#8-appendix)

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) document provides a comprehensive description of the Dental Clinic Management System (DCMS). It details the functional and non-functional requirements for developers, project managers, testers, and stakeholders involved in the development and deployment of the system.

**Intended Audience:**

- Development Team
- Product Owners
- Quality Assurance Team
- System Administrators
- End Users (Clinic Staff)
- Project Stakeholders

### 1.2 Scope

The Dental Clinic Management System is a comprehensive web and desktop application designed to streamline dental clinic operations. The system will:

**Product Name:** Dental Clinic Management System (DCMS)

**Product Features:**

- Secure multi-role authentication system
- Patient information management
- Appointment scheduling and tracking
- Billing and invoice generation
- Payment processing and tracking
- Dashboard with real-time analytics
- Medical records management
- Clinic settings and configuration
- Image upload and storage
- Search and filter capabilities

**Benefits:**

- Improved operational efficiency
- Reduced administrative workload
- Better patient data organization
- Enhanced billing accuracy
- Real-time clinic performance insights
- Secure data management

**Out of Scope (Current Version):**

- Mobile native applications (iOS/Android)
- SMS/Email notification system
- Integration with external laboratory systems
- Telemedicine features
- Multi-clinic management
- Patient portal

### 1.3 Definitions, Acronyms, and Abbreviations

| Term | Definition                          |
| ---- | ----------------------------------- |
| DCMS | Dental Clinic Management System     |
| SRS  | Software Requirements Specification |
| RBAC | Role-Based Access Control           |
| BLoC | Business Logic Component            |
| UI   | User Interface                      |
| UX   | User Experience                     |
| API  | Application Programming Interface   |
| CRUD | Create, Read, Update, Delete        |
| MVP  | Minimum Viable Product              |
| RLS  | Row Level Security                  |
| 2FA  | Two-Factor Authentication           |
| JWT  | JSON Web Token                      |
| DoD  | Definition of Done                  |

### 1.4 References

- Flutter Documentation: https://docs.flutter.dev
- Supabase Documentation: https://supabase.com/docs
- Material Design 3: https://m3.material.io
- BLoC Pattern: https://bloclibrary.dev
- Project GitHub Repository: [Internal]

### 1.5 Overview

This document is organized into eight main sections:

- Section 2: Overall system description and context
- Section 3: High-level system features
- Section 4: Interface requirements
- Section 5: Detailed functional requirements
- Section 6: Non-functional requirements
- Section 7: Additional requirements
- Section 8: Appendices and supporting information

---

## 2. Overall Description

### 2.1 Product Perspective

The Dental Clinic Management System is a standalone application that integrates with Supabase backend services. It operates as:

**System Architecture:**

```
┌────────────────────────────────────┐
│   Flutter Application (Frontend)   │
│  ┌──────────────────────────────┐  │
│  │   Presentation Layer (UI)    │  │
│  └──────────┬───────────────────┘  │
│             │                      │
│  ┌──────────┴───────────────────┐  │
│  │   BLoC Layer (State Mgmt)    │  │
│  └──────────┬───────────────────┘  │
│             │                      │
│  ┌──────────┴───────────────────┐  │
│  │  Repository Layer (Data)     │  │
│  └──────────┬───────────────────┘  │
└─────────────┼──────────────────────┘
              │
              │ HTTPS/REST
              ▼
┌─────────────────────────────────────┐
│      Supabase Backend (BaaS)        │
│  ┌────────────┬──────────────────┐  │
│  │ PostgreSQL │  Authentication  │  │
│  └────────────┴──────────────────┘  │
│  ┌────────────┬──────────────────┐  │
│  │  Storage   │   Real-time API  │  │
│  └────────────┴──────────────────┘  │
└─────────────────────────────────────┘
```

**Platform Support:**

- Web (Chrome, Firefox, Edge, Safari)
- Windows Desktop
- Linux Desktop (future)
- macOS Desktop (future)

### 2.2 Product Functions

The system provides the following major functions:

1. **Authentication & Authorization**
   - User login with email/password
   - Role-based access control (Admin, Doctor, Receptionist)
   - Password reset functionality
   - Session management

2. **Patient Management**
   - Patient registration
   - Patient profile management
   - Medical history tracking
   - Patient search and filtering
   - Profile image management

3. **Appointment Scheduling**
   - Appointment creation and editing
   - Calendar view (day/week/month)
   - Status tracking and updates
   - Conflict detection

4. **Billing & Financial**
   - Invoice generation
   - Payment recording
   - Treatment pricing
   - Financial reporting
   - Expense tracking

5. **Dashboard & Analytics**
   - Real-time metrics
   - Visual charts and graphs
   - Quick access widgets
   - Performance indicators

6. **Settings & Configuration**
   - Clinic information management
   - User profile settings
   - System preferences

### 2.3 User Classes and Characteristics

#### 2.3.1 Administrator

**Description:** Clinic owners, managers, or IT administrators  
**Technical Expertise:** Medium to High  
**Frequency of Use:** Daily  
**Key Tasks:**

- System configuration
- User management
- Financial oversight
- Data management
- Report generation

**Permissions:** Full system access

#### 2.3.2 Doctor/Dentist

**Description:** Medical professionals providing dental care  
**Technical Expertise:** Low to Medium  
**Frequency of Use:** Daily  
**Key Tasks:**

- Patient examination and treatment
- Medical record documentation
- Prescription creation
- Treatment planning
- Appointment management

**Permissions:** Full medical records access, limited administrative functions

#### 2.3.3 Receptionist

**Description:** Front desk staff handling administrative tasks  
**Technical Expertise:** Low to Medium  
**Frequency of Use:** Daily  
**Key Tasks:**

- Patient registration
- Appointment scheduling
- Invoice creation
- Payment collection
- Basic patient information updates

**Permissions:** Limited medical records access, full scheduling and billing access

### 2.4 Operating Environment

**Hardware Requirements:**

- **Minimum:**
  - Processor: Dual-core 2.0 GHz
  - RAM: 4 GB
  - Storage: 500 MB available space
  - Display: 1366 x 768 resolution

- **Recommended:**
  - Processor: Quad-core 2.5 GHz or higher
  - RAM: 8 GB or more
  - Storage: 1 GB available space
  - Display: 1920 x 1080 resolution or higher

**Software Requirements:**

- **Web:** Modern browser (Chrome 90+, Firefox 88+, Edge 90+, Safari 14+)
- **Windows:** Windows 10 or later (64-bit)
- **Internet:** Stable broadband connection (minimum 5 Mbps)

**Backend Requirements:**

- Supabase project (cloud-hosted)
- PostgreSQL database
- Object storage

### 2.5 Design and Implementation Constraints

**Technical Constraints:**

- Must use Flutter framework (3.16.0+)
- Must use Supabase as backend service
- Must implement BLoC pattern for state management
- Must support offline-first capabilities (future)

**Regulatory Constraints:**

- HIPAA compliance considerations (US)
- GDPR compliance (EU)
- Data encryption requirements
- Patient data privacy standards

**Business Constraints:**

- Single clinic support (v1.0)
- French language UI
- Cloud-based deployment
- Responsive design requirement

### 2.6 Assumptions and Dependencies

**Assumptions:**

- Users have basic computer literacy
- Clinic has stable internet connectivity
- Supabase services remain available and reliable
- Users have appropriate devices (desktop/laptop with modern browser)
- Clinic staff receive basic training on system usage

**Dependencies:**

- Flutter SDK availability and updates
- Supabase platform stability
- Third-party package maintenance
- Cloud infrastructure availability
- Browser compatibility

---

## 3. System Features

### 3.1 Feature Overview

| ID   | Feature Name                   | Priority | Status         |
| ---- | ------------------------------ | -------- | -------------- |
| F-01 | Authentication & Authorization | High     | ✅ Implemented |
| F-02 | Patient Management             | High     | ✅ Implemented |
| F-03 | Appointment Scheduling         | High     | 🟡 In Progress |
| F-04 | Billing & Invoicing            | High     | 🟡 In Progress |
| F-05 | Dashboard & Analytics          | Medium   | ✅ Implemented |
| F-06 | Medical Records                | High     | ✅ Implemented |
| F-07 | Image Management               | Medium   | ✅ Implemented |
| F-08 | Search & Filter                | Medium   | ✅ Implemented |
| F-09 | Settings & Configuration       | Low      | 🟡 In Progress |
| F-10 | Reporting (Future)             | Low      | 📝 Planned     |

---

## 4. External Interface Requirements

### 4.1 User Interfaces

#### 4.1.1 General UI Requirements

- **Design System:** Material Design 3
- **Theme:** Light mode (dark mode planned)
- **Language:** French
- **Responsiveness:** Desktop and tablet support
- **Accessibility:** Basic WCAG 2.1 Level A compliance

#### 4.1.2 Screen Requirements

**Login Screen:**

- Two-tab interface (Face ID / Email-Password)
- Email input field (validated)
- Password input field (masked)
- "Remember me" checkbox
- "Forgot password" link
- Login button
- Error message display

**Dashboard Screen:**

- Navigation sidebar (collapsible)
- Stats cards (4 key metrics)
- Quick access buttons
- Recent activity feed
- Charts and graphs
- User profile section

**Patient List Screen:**

- Search bar
- Filter dropdown
- Patient data table with columns:
  - Profile photo
  - Name
  - Age
  - Gender
  - Phone
  - Last visit
  - Actions
- Pagination controls
- Add patient button

**Patient Profile Screen:**

- Profile header (photo, name, stats)
- Tab navigation (Dental History, Prescriptions, Allergies, Upcoming)
- Quick actions panel
- Edit patient button
- Delete patient button (admin only)

**Appointment Calendar:**

- Month/week/day view toggle
- Date picker
- Appointment cards with color-coding
- Add appointment button
- Filter by doctor/status

**Invoice Screen:**

- Patient selection
- Treatment items list
- Subtotal/discount/total calculations
- Payment status indicator
- Print/export options

### 4.2 Hardware Interfaces

**Camera (Optional):**

- For profile photo capture
- Accessed via web API or system camera
- Image preview before upload

**Printer (Optional):**

- For invoice and report printing
- Standard printer drivers
- PDF export as alternative

### 4.3 Software Interfaces

#### 4.3.1 Supabase Backend

**Authentication Service:**

- Protocol: HTTPS/REST
- Authentication: JWT tokens
- Functions: Sign in, sign out, password reset

**Database (PostgreSQL):**

- Protocol: PostgREST API
- Operations: CRUD operations on all tables
- Real-time: Subscribe to table changes (future)

**Storage Service:**

- Protocol: HTTPS
- Operations: Upload, download, delete files
- Buckets: profile-images, medical-documents

#### 4.3.2 Browser APIs

- Local Storage: Session persistence
- File API: Image upload
- Fetch API: Network requests

### 4.4 Communication Interfaces

**Network Protocols:**

- HTTPS for all API communication
- WebSocket for real-time updates (future)
- RESTful API architecture

**Data Formats:**

- JSON for API requests/responses
- Base64 for image encoding
- CSV/PDF for exports

**Security:**

- TLS 1.3 encryption
- JWT token authentication
- Row-level security in database

---

## 5. System Features Detail

### 5.1 Authentication System

#### 5.1.1 Description

Secure user authentication and authorization with role-based access control.

#### 5.1.2 Functional Requirements

**REQ-AUTH-001: User Login**

- Priority: High
- The system shall authenticate users using email and password
- The system shall validate email format before submission
- The system shall mask password input
- The system shall display appropriate error messages for invalid credentials
- The system shall redirect authenticated users to the dashboard

**REQ-AUTH-002: Password Reset**

- Priority: High
- The system shall send password reset email to registered users
- The system shall validate email existence before sending reset link
- The system shall expire reset links after 24 hours
- The system shall allow users to set new password via reset link

**REQ-AUTH-003: Session Management**

- Priority: High
- The system shall maintain user sessions using JWT tokens
- The system shall automatically refresh expired tokens
- The system shall log out users after 8 hours of inactivity
- The system shall allow users to manually log out

**REQ-AUTH-004: Role-Based Access**

- Priority: High
- The system shall assign one of three roles: Admin, Doctor, Receptionist
- The system shall enforce role-based permissions throughout the application
- The system shall hide/disable features based on user role
- The system shall prevent unauthorized access to restricted features

### 5.2 Patient Management

#### 5.2.1 Description

Comprehensive patient information management with medical history tracking.

#### 5.2.2 Functional Requirements

**REQ-PAT-001: Add Patient**

- Priority: High
- The system shall allow authorized users to register new patients
- The system shall require: name, DOB, gender, phone
- The system shall validate all required fields
- The system shall detect duplicate patients by name and phone
- The system shall generate unique patient ID automatically

**REQ-PAT-002: View Patient Profile**

- Priority: High
- The system shall display complete patient information
- The system shall show patient statistics (age, total visits, last visit)
- The system shall organize medical records in tabs
- The system shall display profile image if available
- The system shall show quick action buttons

**REQ-PAT-003: Edit Patient Information**

- Priority: High
- The system shall allow authorized users to update patient details
- The system shall validate updated information
- The system shall track modification timestamp
- The system shall prevent deletion of required fields
- The system shall show confirmation message on successful update

**REQ-PAT-004: Delete Patient**

- Priority: Medium
- The system shall allow only admins to delete patients
- The system shall require confirmation before deletion
- The system shall handle associated records appropriately
- The system shall prevent accidental deletions
- The system shall show success message after deletion

**REQ-PAT-005: Search Patients**

- Priority: High
- The system shall provide real-time search functionality
- The system shall search by name, phone, email, patient ID
- The system shall display results as user types
- The system shall show "no results" message when appropriate
- The system shall allow clearing search

**REQ-PAT-006: Filter Patients**

- Priority: Medium
- The system shall allow filtering by age range, gender, doctor
- The system shall support multiple simultaneous filters
- The system shall display active filters as chips
- The system shall update results immediately when filters change
- The system shall allow clearing all filters

**REQ-PAT-007: Upload Profile Photo**

- Priority: Low
- The system shall allow image upload from device
- The system shall accept JPEG and PNG formats
- The system shall limit file size to 5MB
- The system shall display upload progress
- The system shall show error for invalid files

### 5.3 Appointment Management

#### 5.3.1 Description

Scheduling and tracking of patient appointments with doctors.

#### 5.3.2 Functional Requirements

**REQ-APT-001: Create Appointment**

- Priority: High
- The system shall allow scheduling new appointments
- The system shall require: patient, doctor, date, time
- The system shall detect scheduling conflicts
- The system shall prevent double-booking
- The system shall allow adding notes

**REQ-APT-002: View Calendar**

- Priority: High
- The system shall display appointments in calendar format
- The system shall support day, week, and month views
- The system shall color-code by status
- The system shall show appointment details on hover/click
- The system shall highlight today's date

**REQ-APT-003: Update Appointment Status**

- Priority: Medium
- The system shall allow updating appointment status
- The system shall support statuses: Scheduled, In Progress, Completed, Cancelled, No Show
- The system shall track status change history
- The system shall update calendar view immediately
- The system shall allow only authorized status transitions

**REQ-APT-004: Edit/Cancel Appointment**

- Priority: Medium
- The system shall allow rescheduling appointments
- The system shall require reason for cancellation
- The system shall update all associated records
- The system shall show confirmation dialog
- The system shall notify relevant parties (future)

### 5.4 Billing & Financial Management

#### 5.4.1 Description

Invoice generation, payment tracking, and financial reporting.

#### 5.4.2 Functional Requirements

**REQ-BILL-001: Create Invoice**

- Priority: High
- The system shall allow creating patient invoices
- The system shall auto-populate patient information
- The system shall allow adding multiple treatment items
- The system shall calculate totals automatically
- The system shall support discounts (percentage or fixed)
- The system shall generate unique invoice number

**REQ-BILL-002: Record Payment**

- Priority: High
- The system shall allow recording payments against invoices
- The system shall support multiple payment methods (Cash, Card, Transfer, Check)
- The system shall calculate remaining balance
- The system shall update invoice status automatically
- The system shall allow partial payments

**REQ-BILL-003: View Financial Reports**

- Priority: Medium
- The system shall display revenue summaries (daily, weekly, monthly)
- The system shall show payment method breakdown
- The system shall list outstanding invoices
- The system shall calculate total receivables
- The system shall allow date range filtering

**REQ-BILL-004: Manage Expenses**

- Priority: Low
- The system shall allow recording clinic expenses
- The system shall categorize expenses
- The system shall track expense dates and amounts
- The system shall include expenses in financial reports
- The system shall support expense categories

### 5.5 Dashboard & Analytics

#### 5.5.1 Description

Real-time clinic metrics and performance indicators.

#### 5.5.2 Functional Requirements

**REQ-DASH-001: Display Key Metrics**

- Priority: High
- The system shall show total patient count
- The system shall show today's appointment count
- The system shall show monthly revenue
- The system shall show pending payments total
- The system shall update metrics in real-time

**REQ-DASH-002: Visual Charts**

- Priority: Medium
- The system shall display revenue trend chart
- The system shall show appointment distribution
- The system shall present patient demographics
- The system shall allow chart interaction
- The system shall support export to image (future)

**REQ-DASH-003: Quick Access**

- Priority: Low
- The system shall provide quick action buttons
- The system shall show recent patients
- The system shall display upcoming appointments
- The system shall show recent activity
- The system shall allow navigation to detail views

### 5.6 Medical Records

#### 5.6.1 Description

Patient medical history, prescriptions, allergies, and treatment records.

#### 5.6.2 Functional Requirements

**REQ-MED-001: Dental History**

- Priority: High
- The system shall display patient's dental procedure history
- The system shall show treatment dates and details
- The system shall list treating doctors
- The system shall allow adding new dental records (doctors only)
- The system shall sort by date (newest first)

**REQ-MED-002: Prescriptions**

- Priority: High
- The system shall manage patient prescriptions
- The system shall allow doctors to create prescriptions
- The system shall hide prescription tab for receptionists
- The system shall show medication, dosage, duration
- The system shall track prescribing doctor and date

**REQ-MED-003: Allergies**

- Priority: High
- The system shall track patient allergies
- The system shall hide allergy tab for receptionists
- The system shall allow doctors to add/edit allergies
- The system shall show allergy type and severity
- The system shall highlight critical allergies

**REQ-MED-004: Role-Based Tab Access**

- Priority: High
- The system shall show all tabs to admins and doctors
- The system shall show only "Dental History" and "Upcoming" tabs to receptionists
- The system shall hide restricted tabs completely (not just disable)
- The system shall prevent URL-based access to restricted tabs

### 5.7 Settings & Configuration

#### 5.7.1 Description

System and clinic configuration management.

#### 5.7.2 Functional Requirements

**REQ-SET-001: Clinic Information**

- Priority: Medium
- The system shall allow admins to update clinic details
- The system shall support: name, address, phone, email, logo
- The system shall validate required fields
- The system shall display clinic info in UI
- The system shall show confirmation on save

**REQ-SET-002: User Profile**

- Priority: Low
- The system shall allow users to update their profile
- The system shall support: name, phone, profile photo
- The system shall allow password change
- The system shall prevent email modification
- The system shall update navbar immediately

---

## 6. Non-Functional Requirements

### 6.1 Performance Requirements

**PERF-001: Response Time**

- Page load time shall not exceed 3 seconds
- API requests shall complete within 2 seconds
- Search results shall appear within 500ms
- Image uploads shall show progress indicators

**PERF-002: Throughput**

- System shall support 50 concurrent users
- System shall handle 1000 patients without performance degradation
- Database queries shall complete within 1 second
- Real-time updates shall propagate within 2 seconds

**PERF-003: Resource Usage**

- Application memory usage shall not exceed 500MB
- Client-side caching shall reduce redundant API calls
- Images shall be compressed before upload
- Lazy loading shall be used for large lists

### 6.2 Safety Requirements

**SAFE-001: Data Backup**

- System shall support automated backups (Supabase handles)
- Backups shall be retained for 30 days minimum
- Point-in-time recovery shall be available

**SAFE-002: Error Handling**

- System shall gracefully handle network failures
- System shall display user-friendly error messages
- System shall log errors for debugging
- System shall prevent data loss during errors

### 6.3 Security Requirements

**SEC-001: Authentication**

- System shall use secure password hashing (bcrypt)
- System shall enforce minimum password length of 8 characters
- System shall implement session timeouts
- System shall use HTTPS for all communications

**SEC-002: Authorization**

- System shall enforce role-based access control
- System shall implement row-level security in database
- System shall validate permissions on every request
- System shall log unauthorized access attempts

**SEC-003: Data Protection**

- System shall encrypt sensitive data at rest
- System shall encrypt data in transit (TLS 1.3)
- System shall comply with HIPAA guidelines
- System shall implement secure file upload

**SEC-004: Audit Trail**

- System shall log all data modifications (future)
- System shall track user actions
- System shall store audit logs securely
- System shall allow audit log review by admins

### 6.4 Software Quality Attributes

#### 6.4.1 Availability

- System uptime: 99.5% (dependent on Supabase)
- Planned maintenance windows: Off-peak hours
- Recovery time objective (RTO): 4 hours
- Recovery point objective (RPO): 1 hour

#### 6.4.2 Maintainability

- Code shall follow Flutter style guide
- Code shall include inline documentation
- Code shall have >80% test coverage (target)
- Architecture shall support feature additions

#### 6.4.3 Portability

- Application shall run on Windows 10+
- Application shall run in modern web browsers
- Application shall support 1366x768 minimum resolution
- Application shall work offline (future enhancement)

#### 6.4.4 Reliability

- Mean time between failures (MTBF): >168 hours
- Mean time to repair (MTTR): <4 hours
- Error rate: <1% of transactions
- Data integrity: 100% ACID compliance

#### 6.4.5 Scalability

- System shall support up to 1000 patients (v1.0)
- System shall support up to 50 concurrent users
- Database shall handle 10,000 appointments
- Storage shall support 10GB of images

#### 6.4.6 Usability

- New users shall complete training within 2 hours
- Common tasks shall require <5 clicks
- UI shall provide clear feedback for all actions
- Help documentation shall be accessible
- Error messages shall be in French

---

## 7. Other Requirements

### 7.1 Legal Requirements

**LEGAL-001: Data Privacy**

- System shall comply with GDPR (if applicable)
- System shall comply with HIPAA (if applicable)
- System shall allow data export for patient requests
- System shall support right to be forgotten (data deletion)

**LEGAL-002: Terms of Service**

- Users shall accept terms of service on first login
- System shall display privacy policy
- System shall log user consent

### 7.2 Internationalization

**I18N-001: Language Support**

- Primary language: French
- All UI text shall be in French
- Date format: DD/MM/YYYY
- Currency: Euro (€) or configurable
- Number format: European (1.234,56)

### 7.3 Platform Requirements

**PLAT-001: Browser Compatibility**

- Chrome 90+ (primary target)
- Firefox 88+
- Edge 90+
- Safari 14+

**PLAT-002: Operating System**

- Windows 10/11 (64-bit)
- Web-based (platform-agnostic)
- Future: Linux, macOS support

### 7.4 Documentation Requirements

**DOC-001: User Documentation**

- System shall include user manual
- System shall provide inline help
- System shall include video tutorials (future)
- System shall maintain FAQ section

**DOC-002: Technical Documentation**

- System shall maintain API documentation
- System shall document database schema
- System shall provide setup guide
- System shall include architecture diagrams

---

## 8. Appendix

### 8.1 Database Schema Overview

```sql
-- Core Tables
users (id, auth_id, email, role, first_name, last_name, ...)
patients (id, name, dob, gender, phone, email, ...)
appointments (id, patient_id, doctor_id, appointment_date, status, ...)
invoices (id, patient_id, subtotal, discount, total, status, ...)
invoice_items (id, invoice_id, treatment_id, quantity, unit_price, ...)
payments (id, invoice_id, amount, payment_method, payment_date, ...)
treatments (id, name, description, default_price, ...)
dental_history (id, patient_id, procedure, date, doctor_id, ...)
prescriptions (id, patient_id, medication, dosage, doctor_id, ...)
allergies (id, patient_id, allergy_type, severity, ...)
```

### 8.2 User Role Permissions Matrix

See [ROLE_PERMISSIONS.md](ROLE_PERMISSIONS.md) for complete matrix.

### 8.3 API Endpoints Summary

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for complete reference.

### 8.4 Glossary

| Term           | Definition                                          |
| -------------- | --------------------------------------------------- |
| Appointment    | Scheduled visit of a patient with a doctor          |
| Invoice        | Bill for dental services rendered                   |
| Patient        | Individual receiving dental care                    |
| Treatment      | Dental procedure or service                         |
| Prescription   | Medical order for medication                        |
| Allergy        | Patient's adverse reaction to substance             |
| Dental History | Record of past dental procedures                    |
| Session        | Authenticated user's active period                  |
| Role           | User's permission level (Admin/Doctor/Receptionist) |

### 8.5 Change History

| Version | Date     | Author   | Changes              |
| ------- | -------- | -------- | -------------------- |
| 1.0.0   | Jan 2026 | Dev Team | Initial SRS document |

### 8.6 Approval

**Document Prepared By:** Development Team  
**Document Reviewed By:** [Pending]  
**Document Approved By:** [Pending]  
**Approval Date:** [Pending]

---

**Document Status:** Active  
**Last Updated:** January 26, 2026  
**Next Review:** March 2026

---

## Related Documentation

- [Project Overview](PROJECT_OVERVIEW.md)
- [User Stories](USER_STORIES.md)
- [Technical Architecture](TECHNICAL_ARCHITECTURE.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Setup Guide](SETUP_GUIDE.md)
