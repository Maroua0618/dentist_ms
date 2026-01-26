# User Stories

## 📖 Story Format

**As a** [role], **I want** [feature], **so that** [benefit]

---

## 🔐 Authentication & Authorization

### US-001: Secure Login

**As a** clinic staff member  
**I want** to log in securely with my email and password  
**So that** I can access the system with my assigned role and permissions

**Acceptance Criteria:**

- Email and password fields are validated
- Error messages display for invalid credentials
- Successful login redirects to dashboard
- Password can be reset via email
- Face ID login available as alternative

**Priority:** High | **Story Points:** 5 | **Sprint:** 1

---

### US-002: Role-Based Access

**As an** administrator  
**I want** different user roles to have specific permissions  
**So that** sensitive data and actions are protected

**Acceptance Criteria:**

- Admin has full system access
- Doctors can view/edit medical records
- Receptionists have limited access to sensitive data
- Delete patient action only available to admins

**Priority:** High | **Story Points:** 8 | **Sprint:** 1

---

## 👥 Patient Management

### US-003: Add New Patient

**As a** receptionist  
**I want** to add new patient records  
**So that** we can track patient information and history

**Acceptance Criteria:**

- Form includes: name, DOB, gender, contact info, address
- All required fields validated
- Duplicate detection by name/phone
- Success message on save
- Patient appears in patient list

**Priority:** High | **Story Points:** 5 | **Sprint:** 1

---

### US-004: View Patient Profile

**As a** doctor  
**I want** to view complete patient profiles  
**So that** I can provide informed treatment

**Acceptance Criteria:**

- Profile shows personal info, stats, and contact details
- Dental history displayed in chronological order
- Medical records organized by tabs
- Profile images load correctly
- Quick actions available

**Priority:** High | **Story Points:** 8 | **Sprint:** 2

---

### US-005: Edit Patient Information

**As a** receptionist  
**I want** to update patient contact information  
**So that** we maintain accurate records

**Acceptance Criteria:**

- Edit dialog pre-fills current data
- Changes save successfully
- Validation prevents invalid data
- Confirmation message displayed
- Patient list refreshes automatically

**Priority:** Medium | **Story Points:** 3 | **Sprint:** 2

---

### US-006: Delete Patient

**As an** administrator  
**I want** to delete patient records  
**So that** we can remove incorrect or duplicate entries

**Acceptance Criteria:**

- Delete button only visible to admins
- Confirmation dialog prevents accidental deletion
- Associated records handled appropriately
- Success message displayed
- Patient removed from list

**Priority:** Low | **Story Points:** 3 | **Sprint:** 3

---

### US-007: Upload Patient Photo

**As a** receptionist  
**I want** to upload patient profile photos  
**So that** we can quickly identify patients

**Acceptance Criteria:**

- Image picker supports gallery selection
- Images upload to cloud storage
- Progress indicator during upload
- Images display in profile header
- Error handling for failed uploads

**Priority:** Medium | **Story Points:** 5 | **Sprint:** 2

---

### US-008: Search Patients

**As a** receptionist  
**I want** to search patients by name, phone, or ID  
**So that** I can quickly find patient records

**Acceptance Criteria:**

- Search works in real-time
- Results filter as user types
- Multiple search criteria supported
- Clear search button available
- No results message displays when appropriate

**Priority:** High | **Story Points:** 5 | **Sprint:** 2

---

### US-009: Filter Patients

**As a** doctor  
**I want** to filter patients by criteria  
**So that** I can view specific patient groups

**Acceptance Criteria:**

- Filter by age range, gender, dentist
- Multiple filters can be applied
- Filter dialog is user-friendly
- Active filters display as chips
- Results update immediately

**Priority:** Medium | **Story Points:** 5 | **Sprint:** 3

---

## 📅 Appointment Management

### US-010: Schedule Appointment

**As a** receptionist  
**I want** to schedule patient appointments  
**So that** we can manage the clinic's daily schedule

**Acceptance Criteria:**

- Select patient, doctor, date, and time
- Conflict detection prevents double-booking
- Appointment status can be set
- Notes field for special requirements
- Confirmation message on success

**Priority:** High | **Story Points:** 8 | **Sprint:** 2

---

### US-011: View Appointment Calendar

**As a** doctor  
**I want** to view my appointment schedule  
**So that** I can prepare for upcoming patients

**Acceptance Criteria:**

- Calendar view shows all appointments
- Color-coded by status
- Click appointment for details
- Day/week/month views available
- Today's appointments highlighted

**Priority:** High | **Story Points:** 8 | **Sprint:** 2

---

### US-012: Update Appointment Status

**As a** doctor  
**I want** to update appointment status  
**So that** we track appointment progress

**Acceptance Criteria:**

- Status options: Scheduled, In Progress, Completed, Cancelled
- Status changes reflect in real-time
- History of status changes tracked
- Notifications sent on status change

**Priority:** Medium | **Story Points:** 5 | **Sprint:** 3

---

### US-013: Cancel Appointment

**As a** receptionist  
**I want** to cancel appointments  
**So that** we can manage schedule changes

**Acceptance Criteria:**

- Cancellation reason required
- Confirmation dialog prevents accidents
- Cancelled appointments marked clearly
- Time slot becomes available
- Patient notified of cancellation

**Priority:** Medium | **Story Points:** 3 | **Sprint:** 3

---

## 💰 Billing & Payments

### US-014: Create Invoice

**As a** receptionist  
**I want** to create invoices for treatments  
**So that** we can bill patients accurately

**Acceptance Criteria:**

- Select patient and treatments
- Calculate totals automatically
- Add discounts and taxes
- Generate unique invoice number
- Save and print options available

**Priority:** High | **Story Points:** 8 | **Sprint:** 3

---

### US-015: Record Payment

**As a** receptionist  
**I want** to record patient payments  
**So that** we track financial transactions

**Acceptance Criteria:**

- Link payment to invoice
- Support multiple payment methods
- Calculate remaining balance
- Generate payment receipt
- Update invoice status automatically

**Priority:** High | **Story Points:** 5 | **Sprint:** 3

---

### US-016: View Financial Reports

**As an** administrator  
**I want** to view financial reports  
**So that** I can monitor clinic revenue

**Acceptance Criteria:**

- Daily/weekly/monthly revenue charts
- Payment method breakdown
- Outstanding invoices listed
- Export reports to PDF/Excel
- Date range filtering

**Priority:** Medium | **Story Points:** 8 | **Sprint:** 4

---

### US-017: Manage Expenses

**As an** administrator  
**I want** to track clinic expenses  
**So that** I can monitor profitability

**Acceptance Criteria:**

- Add expense with category and amount
- Expense categories customizable
- View expense history
- Filter by date and category
- Include in financial reports

**Priority:** Low | **Story Points:** 5 | **Sprint:** 4

---

## 📊 Dashboard & Analytics

### US-018: View Dashboard Metrics

**As a** clinic staff member  
**I want** to see key metrics on the dashboard  
**So that** I can monitor clinic performance

**Acceptance Criteria:**

- Patient count with trend indicator
- Today's appointments count
- Revenue statistics
- Pending payments total
- Refresh on data changes

**Priority:** High | **Story Points:** 8 | **Sprint:** 1

---

### US-019: View Activity Charts

**As an** administrator  
**I want** to view analytics charts  
**So that** I can identify trends and patterns

**Acceptance Criteria:**

- Revenue trend chart
- Appointment distribution chart
- Patient demographics chart
- Interactive and responsive
- Exportable to images

**Priority:** Medium | **Story Points:** 8 | **Sprint:** 4

---

## 🔧 Settings & Configuration

### US-020: Update Clinic Information

**As an** administrator  
**I want** to update clinic details  
**So that** accurate information displays in the system

**Acceptance Criteria:**

- Edit clinic name, address, contact
- Upload clinic logo
- Changes reflect immediately
- Validation on required fields
- Success confirmation

**Priority:** Medium | **Story Points:** 5 | **Sprint:** 3

---

### US-021: Manage User Profile

**As a** clinic staff member  
**I want** to update my profile information  
**So that** my details are current

**Acceptance Criteria:**

- Edit name, email, phone
- Upload profile picture
- Change password option
- Changes save successfully
- Profile updates in navbar

**Priority:** Low | **Story Points:** 3 | **Sprint:** 3

---

## 🏥 Medical Records (Role-Specific)

### US-022: View Medical Records (Doctor/Admin)

**As a** doctor  
**I want** to view all patient medical tabs  
**So that** I have complete medical information

**Acceptance Criteria:**

- Access to: Dental History, Prescriptions, Allergies, Upcoming
- All tabs display correctly
- Medical data is accurate
- Tabs are responsive

**Priority:** High | **Story Points:** 5 | **Sprint:** 2

---

### US-023: Limited Medical Access (Receptionist)

**As a** receptionist  
**I want** limited access to medical records  
**So that** patient privacy is protected

**Acceptance Criteria:**

- Access only to: Dental History, Upcoming tabs
- Prescriptions tab hidden
- Allergies tab hidden
- No error messages for hidden tabs

**Priority:** High | **Story Points:** 3 | **Sprint:** 2

---

### US-024: Add Medical Record

**As a** doctor  
**I want** to add medical records  
**So that** patient treatment history is documented

**Acceptance Criteria:**

- Add dental procedures with details
- Record treatment date and notes
- Attach images if needed
- Record saves successfully
- Displays in patient history

**Priority:** Medium | **Story Points:** 5 | **Sprint:** 3

---

## 📄 Story Point Reference

| Points | Complexity   | Estimated Time |
| ------ | ------------ | -------------- |
| 1      | Trivial      | < 2 hours      |
| 2      | Simple       | 2-4 hours      |
| 3      | Easy         | 4-8 hours      |
| 5      | Medium       | 1-2 days       |
| 8      | Complex      | 2-3 days       |
| 13     | Very Complex | 3-5 days       |

---

**Total User Stories:** 24  
**Total Story Points:** 137  
**Average Velocity (estimated):** 30-40 points per sprint
