# Features Documentation

## 📚 Complete Feature Reference

This document provides detailed documentation for all features in the Dental Clinic Management System.

---

## 🔐 1. Authentication & Authorization

### Overview

Secure authentication system with role-based access control, supporting multiple login methods and password management.

### Features

- **Email/Password Login** - Traditional authentication
- **Face ID Login** - Biometric authentication (future)
- **Password Reset** - Email-based recovery
- **Role-Based Access** - Admin, Doctor, Receptionist roles
- **Session Management** - Secure token handling

### User Flow

```
1. User navigates to login page
2. Selects authentication method (Email or Face ID)
3. Enters credentials
4. System validates credentials
5. Supabase authenticates user
6. System fetches user profile and role
7. Redirects to dashboard with appropriate permissions
```

### Technical Implementation

- **BLoC:** `AuthBloc` manages authentication state
- **Repository:** `AuthRepository` handles Supabase Auth API
- **Storage:** Secure token storage
- **Models:** `AppUser` with role and permissions

### Key Components

- `login_page.dart` - Login UI with tabs
- `auth_bloc.dart` - Authentication logic
- `auth_repository.dart` - Data layer

### Screenshots & UI

- Two-tab interface: "Face ID" and "Email et Mot de Passe"
- Gradient background with clinic branding
- Feature highlights section
- Error handling with French messages

---

## 📊 2. Dashboard

### Overview

Real-time overview of clinic operations with key metrics, statistics, and quick access to common actions.

### Features

- **Patient Count** - Total active patients with trend
- **Today's Appointments** - Count of scheduled appointments
- **Monthly Revenue** - Financial performance indicator
- **Pending Payments** - Outstanding invoices
- **Quick Actions** - Fast navigation to key features
- **Recent Activity** - Latest system events

### Widgets

1. **Stats Cards** - Display key metrics
2. **Charts** - Visual data representation
3. **Recent Patients** - Latest registered patients
4. **Upcoming Appointments** - Next scheduled appointments
5. **Activity Feed** - System notifications

### Data Sources

```dart
// Dashboard statistics
- Patients: COUNT from patients table
- Appointments: COUNT where date = today
- Revenue: SUM(total) from invoices (current month)
- Pending: SUM(total) where status = 'pending'
```

### Role-Specific Views

- **Admin:** Full dashboard with financial metrics
- **Doctor:** Patient and appointment focus
- **Receptionist:** Appointment and billing focus

### Key Files

- `dashboard_page.dart` - Main dashboard layout
- `dashboard_bloc.dart` - Dashboard state management
- `stats_card.dart` - Metric display widgets

---

## 👥 3. Patient Management

### Overview

Comprehensive patient information system for managing patient records, medical history, and personal details.

### Core Features

#### 3.1 Patient List

- **Search** - Real-time search by name, phone, email
- **Filter** - Age range, gender, assigned doctor
- **Sort** - By name, date added, age
- **Pagination** - Efficient data loading
- **Export** - CSV/PDF export (Admin only)

#### 3.2 Add Patient

```dart
Required Fields:
- Full name
- Date of birth
- Gender
- Phone number

Optional Fields:
- Email
- Address
- Profile photo
- Emergency contact
```

**Validation:**

- Name: 2-50 characters
- Phone: Valid format
- Email: Valid email format
- DOB: Not in future

#### 3.3 Patient Profile

Comprehensive view with tabbed interface:

**Profile Header:**

- Profile photo
- Name and ID
- Age and gender
- Contact information
- Quick stats (appointments, visits)

**Quick Actions:**

- Schedule appointment
- Create invoice
- View history
- Delete patient (Admin only)

**Medical Records Tabs:**

1. **Dental History** (All roles)
   - Past treatments
   - Procedures performed
   - Treatment dates
   - Treating doctor

2. **Prescriptions** (Doctor/Admin only)
   - Medication list
   - Dosage and duration
   - Prescribing doctor
   - Date prescribed

3. **Allergies** (Doctor/Admin only)
   - Known allergies
   - Severity level
   - Reaction type
   - Date identified

4. **Upcoming** (All roles)
   - Scheduled appointments
   - Treatment plans
   - Follow-up requirements

### Role-Based Access

```dart
Admin:
  - Full CRUD operations
  - Can delete patients
  - Access all tabs

Doctor:
  - View/Edit patients
  - Cannot delete
  - Access all tabs
  - Add medical records

Receptionist:
  - View/Edit basic info
  - Cannot delete
  - Limited tabs (Dental History, Upcoming)
  - Cannot view prescriptions/allergies
```

### Technical Implementation

**State Management:**

```dart
PatientBloc States:
- PatientsInitial
- PatientsLoading
- PatientsLoadSuccess
- PatientDetailLoaded
- PatientCreated
- PatientUpdated
- PatientDeleted
- PatientsError
```

**Key Events:**

```dart
- LoadPatients
- SearchPatients(query)
- FilterPatients(criteria)
- LoadPatientDetail(id)
- CreatePatient(patient)
- UpdatePatient(id, data)
- DeletePatient(id)
- UploadPatientPhoto(file)
```

### Database Schema

```sql
patients (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  dob DATE NOT NULL,
  gender CHAR(1) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  address TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
)
```

---

## 📅 4. Appointment Management

### Overview

Scheduling system for managing patient appointments with doctors, including calendar views and status tracking.

### Features

#### 4.1 Appointment Calendar

- **Multiple Views** - Day, Week, Month
- **Color Coding** - By status
- **Drag & Drop** - Reschedule appointments
- **Conflict Detection** - Prevent double-booking
- **Doctor Filter** - View specific doctor schedules

#### 4.2 Create Appointment

```dart
Appointment Form:
- Patient selection (searchable dropdown)
- Doctor selection
- Date and time picker
- Duration
- Appointment type
- Status (Scheduled by default)
- Notes/Comments
```

**Validation:**

- No overlapping appointments
- Future dates only (or same day)
- Doctor availability check
- Patient doesn't have conflicting appointment

#### 4.3 Appointment Status

```dart
Status Options:
- Scheduled (Blue)
- In Progress (Yellow)
- Completed (Green)
- Cancelled (Red)
- No Show (Gray)
```

**Status Transitions:**

```
Scheduled → In Progress → Completed
Scheduled → Cancelled
Scheduled → No Show
```

#### 4.4 Appointment Details

- Patient information
- Doctor assigned
- Date and time
- Status history
- Notes and comments
- Related invoices
- Treatment performed

### Notifications (Planned)

- SMS reminder (24h before)
- Email confirmation
- Doctor notification
- Status change alerts

### Key Components

- `appointment_calendar.dart` - Calendar view
- `appointment_form.dart` - Create/edit form
- `appointment_bloc.dart` - State management
- `appointment_repository.dart` - Data access

### Database Schema

```sql
appointments (
  id SERIAL PRIMARY KEY,
  patient_id INT REFERENCES patients(id),
  doctor_id INT REFERENCES users(id),
  appointment_date TIMESTAMP NOT NULL,
  status VARCHAR(20) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
)
```

---

## 💰 5. Billing & Invoicing

### Overview

Complete financial management system for treatments, invoices, and payments.

### Features

#### 5.1 Invoice Management

**Create Invoice:**

```dart
Invoice Components:
- Patient selection
- Treatment items (searchable)
- Quantity and unit price
- Subtotal calculation
- Discount (percentage or fixed)
- Tax (if applicable)
- Total amount
- Payment terms
- Due date
```

**Invoice Status:**

- **Draft** - Not finalized
- **Pending** - Awaiting payment
- **Partially Paid** - Some payment received
- **Paid** - Fully paid
- **Overdue** - Past due date
- **Cancelled** - Voided invoice

#### 5.2 Treatment Management

```dart
Treatment Catalog:
- Treatment name
- Description
- Default price
- Category (Cleaning, Filling, Root Canal, etc.)
- Duration estimate
```

**Pre-defined Treatments:**

- Consultation
- Teeth Cleaning
- Filling
- Root Canal
- Crown
- Extraction
- Whitening
- Orthodontics

#### 5.3 Payment Recording

```dart
Payment Information:
- Invoice reference
- Payment date
- Amount
- Payment method (Cash, Card, Transfer, Check)
- Reference number
- Notes
```

**Payment Methods:**

- Cash
- Credit/Debit Card
- Bank Transfer
- Check
- Insurance (future)

#### 5.4 Financial Reports

```dart
Available Reports (Admin only):
- Daily revenue summary
- Monthly revenue chart
- Payment method breakdown
- Outstanding invoices
- Doctor-wise revenue
- Treatment popularity
```

### Calculations

```dart
// Invoice calculation
subtotal = sum(items.unitPrice * items.quantity)
discountAmount = subtotal * (discountPercent / 100)
taxAmount = (subtotal - discountAmount) * taxRate
total = subtotal - discountAmount + taxAmount

// Payment tracking
remainingBalance = invoice.total - sum(payments.amount)
```

### Role Access

- **Admin:** Full access to all financial features
- **Receptionist:** Create invoices, record payments
- **Doctor:** View own patient invoices only

### Key Files

- `invoice_page.dart` - Invoice management
- `invoice_form.dart` - Create/edit invoice
- `payment_dialog.dart` - Record payment
- `invoice_bloc.dart`, `payment_bloc.dart` - State management

### Database Schema

```sql
invoices (
  id SERIAL PRIMARY KEY,
  patient_id INT REFERENCES patients(id),
  subtotal DECIMAL(10,2),
  discount DECIMAL(10,2),
  total DECIMAL(10,2),
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW()
)

invoice_items (
  id SERIAL PRIMARY KEY,
  invoice_id INT REFERENCES invoices(id),
  treatment_id INT REFERENCES treatments(id),
  quantity INT,
  unit_price DECIMAL(10,2),
  total DECIMAL(10,2)
)

payments (
  id SERIAL PRIMARY KEY,
  invoice_id INT REFERENCES invoices(id),
  amount DECIMAL(10,2),
  payment_method VARCHAR(20),
  payment_date TIMESTAMP,
  reference_number VARCHAR(50)
)
```

---

## ⚙️ 6. Settings & Configuration

### Overview

System configuration and preferences management.

### Features

#### 6.1 Clinic Information

```dart
Configurable Settings:
- Clinic name
- Logo upload
- Address
- Phone number
- Email
- Website
- Business hours
- Tax ID
```

#### 6.2 User Profile

```dart
User Settings:
- First and last name
- Email (read-only)
- Phone number
- Profile photo
- Password change
- Language preference
```

#### 6.3 System Preferences (Planned)

- Date format
- Currency
- Time zone
- Theme (Light/Dark)
- Default appointment duration
- Reminder settings

### Key Components

- `settings_page.dart` - Settings UI
- `clinic_info_cubit.dart` - Clinic data management
- `profile_settings.dart` - User profile

---

## 🎨 7. UI/UX Features

### Theme System

```dart
Color Palette:
- Primary: #4F7EFF (Blue)
- Gradient: Linear gradient backgrounds
- Success: Green
- Warning: Yellow
- Error: Red
- Text: Dark gray
```

### Responsive Design

- **Desktop** (>900px): Full sidebar, multi-column layout
- **Tablet** (600-900px): Collapsible sidebar
- **Mobile** (<600px): Bottom navigation, single column

### Navigation

- **Sidebar** - Main navigation (desktop/tablet)
- **App Bar** - Page title and actions
- **Breadcrumbs** - Location indicator

### Animations

- Smooth page transitions
- Hover effects
- Loading skeletons
- Toast notifications

---

## 📱 8. Image Management

### Profile Images

- **Upload:** Gallery selection
- **Storage:** Supabase Storage bucket
- **Caching:** In-memory cache for performance
- **Compression:** Automatic image optimization
- **Formats:** JPEG, PNG
- **Size Limit:** 5MB

### Image Features

- Circular avatar display
- Placeholder for missing images
- Upload progress indicator
- Error handling

---

## 🔍 9. Search & Filter

### Global Search

- Patient name
- Phone number
- Email
- Patient ID

### Advanced Filters

```dart
Patient Filters:
- Age range (slider)
- Gender (dropdown)
- Assigned doctor (multi-select)
- Registration date range

Appointment Filters:
- Date range
- Doctor
- Status
- Patient

Invoice Filters:
- Date range
- Status
- Amount range
- Patient
```

### Sort Options

- Name (A-Z, Z-A)
- Date (Newest, Oldest)
- Amount (High-Low, Low-High)

---

## 🚀 Performance Features

### Optimization Techniques

1. **Lazy Loading** - Load data on demand
2. **Pagination** - Limit initial data fetch
3. **Caching** - Cache frequently accessed data
4. **Image Optimization** - Compress and cache images
5. **Debouncing** - Delay search queries
6. **Widget Optimization** - Const constructors

### Caching Strategy

```dart
// Image cache
Map<String, Uint8List> _imageCache = {};

// Data cache (BLoC level)
List<Patient> _cachedPatients;
DateTime _cacheTimestamp;
```

---

## 📊 Analytics & Reporting (Planned)

### Planned Analytics

- Patient demographics
- Appointment trends
- Revenue forecasting
- Treatment popularity
- Doctor performance
- Peak hours analysis

---

**Last Updated:** January 2026  
**Version:** 1.0.0
