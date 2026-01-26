# Technical Architecture

## 🏗️ Architecture Overview

The Dental Clinic Management System follows a **Clean Architecture** pattern with **BLoC (Business Logic Component)** for state management, ensuring separation of concerns and testability.

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │  Pages   │  │ Widgets  │  │ Dialogs  │               │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘               │
│       │             │             │                     │
│       └─────────────┴─────────────┘                     │
│                     │                                   │
├─────────────────────┼───────────────────────────────────┤
│                BLoC Layer (State Management)            │
│  ┌─────────────────┴─────────────────┐                  │
│  │  ┌───────┐  ┌────────┐  ┌──────┐  │                  │
│  │  │ Event │→ │  BLoC  │→ │State │  │                  │
│  │  └───────┘  └────┬───┘  └──────┘  │                  │
│  └───────────────────┼───────────────┘                  │
├─────────────────────┼───────────────────────────────────┤
│              Domain Layer (Business Logic)              │
│  ┌─────────────────┴─────────────────┐                  │
│  │   Repositories   │   Use Cases    │                  │
│  └─────────────────┬─────────────────┘                  │
├─────────────────────┼───────────────────────────────────┤
│                 Data Layer                              │
│  ┌─────────────────┴─────────────────┐                  │
│  │  Remote Data Sources (Supabase)   │                  │
│  │  ┌──────┐ ┌──────┐ ┌──────────┐   │                  │
│  │  │ Auth │ │  DB  │ │ Storage  │   │                  │
│  │  └──────┘ └──────┘ └──────────┘   │                  │
│  └───────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
lib/
├── core/                          # Shared utilities and configurations
│   ├── constants/                 # App-wide constants
│   │   ├── app_colors.dart       # Color palette
│   │   ├── app_routes.dart       # Route definitions
│   │   └── app_text_styles.dart  # Typography
│   ├── models/                    # Shared models
│   │   ├── app_user.dart         # User model with roles
│   │   └── permissions.dart      # Permission system
│   ├── services/                  # Core services
│   │   ├── supabase_service.dart # Supabase initialization
│   │   └── image_upload_service.dart
│   ├── theme/                     # App theming
│   │   └── app_theme.dart
│   └── widgets/                   # Reusable widgets
│       ├── adaptive_scaffold.dart # Responsive layout
│       ├── app_navbar.dart       # Navigation sidebar
│       └── profile_image_picker.dart
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── bloc/                 # Auth BLoC
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── data/                 # Auth data source
│   │   │   └── auth_repository.dart
│   │   └── presentation/         # Auth UI
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── patients/                  # Patient management
│   │   ├── bloc/
│   │   ├── data/
│   │   ├── models/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   ├── dialogs/
│   │   │   └── utils/
│   │   └── repositories/
│   │
│   ├── appointments/              # Appointment scheduling
│   ├── billing/                   # Billing & invoicing
│   ├── dashboard/                 # Dashboard & analytics
│   └── settings/                  # System settings
│
├── docs/                          # Documentation
├── app.dart                       # App widget
├── main.dart                      # Entry point
└── routes.dart                    # Route configuration
```

---

## 🎯 Design Patterns

### 1. BLoC Pattern (Business Logic Component)

**Purpose:** Separate business logic from UI  
**Implementation:**

```dart
// Event
abstract class PatientEvent {}
class LoadPatients extends PatientEvent {}

// State
abstract class PatientState {}
class PatientsLoadSuccess extends PatientState {
  final List<Patient> patients;
}

// BLoC
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository repository;

  PatientBloc(this.repository) : super(PatientsInitial()) {
    on<LoadPatients>(_onLoadPatients);
  }
}
```

### 2. Repository Pattern

**Purpose:** Abstract data sources  
**Benefits:**

- Testability (mock repositories)
- Flexibility (swap data sources)
- Separation of concerns

```dart
class PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  Future<List<Patient>> getPatients() async {
    return await remoteDataSource.fetchPatients();
  }
}
```

### 3. Dependency Injection

**Implementation:** Provider pattern via BlocProvider

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AuthBloc(authRepository)),
    BlocProvider(create: (_) => PatientBloc(patientRepository)),
  ],
  child: MyApp(),
)
```

---

## 🔐 Security Architecture

### Authentication Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Login   │────>│   Auth   │────>│ Supabase │────>│  Token   │
│   Page   │     │   BLoC   │     │   Auth   │     │ Storage  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
                       │
                       ▼
              ┌─────────────────┐
              │ Role-Based      │
              │ Permissions     │
              └─────────────────┘
```

### Role-Based Access Control (RBAC)

```dart
enum UserRole { admin, doctor, receptionist }

class Permissions {
  final bool canDeletePatients;
  final bool canViewAllMedicalRecords;
  final bool canManageFinances;

  static Permissions fromRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Permissions(
          canDeletePatients: true,
          canViewAllMedicalRecords: true,
          canManageFinances: true,
        );
      case UserRole.doctor:
        return Permissions(
          canDeletePatients: false,
          canViewAllMedicalRecords: true,
          canManageFinances: false,
        );
      case UserRole.receptionist:
        return Permissions(
          canDeletePatients: false,
          canViewAllMedicalRecords: false,
          canManageFinances: false,
        );
    }
  }
}
```

### Permission Checks

```dart
// In UI
if (userRole == UserRole.admin) {
  // Show delete button
}

// In Widgets
Widget build(BuildContext context) {
  final userRole = context.watch<AuthBloc>().state.user?.role;

  return QuickActionsCard(
    userRole: userRole,
    // Delete button only shown if admin
  );
}
```

---

## 💾 Data Layer Architecture

### Supabase Integration

#### Database Schema

```sql
-- Users table (managed by Supabase Auth + custom fields)
users (
  id, auth_id, email, role, first_name, last_name,
  specialization, phone, profile_image_url, is_active
)

-- Patients table
patients (
  id, name, dob, gender, phone, email, address,
  profile_image_url, created_at, updated_at
)

-- Appointments table
appointments (
  id, patient_id, doctor_id, appointment_date,
  status, notes, created_at
)

-- Invoices & Payments
invoices, invoice_items, payments, treatments

-- Medical Records
dental_history, prescriptions, allergies
```

#### Storage Buckets

- `profile-images`: User and patient photos
- `medical-documents`: Scanned documents
- `clinic-assets`: Clinic logos and resources

---

## 🔄 State Management Flow

### Patient Load Flow

```
User Action
    │
    ▼
┌─────────────┐
│   Widget    │  ← UI triggers event
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ LoadPatients│  ← Event dispatched
│    Event    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Patient BLoC │  ← BLoC handles event
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Repository  │  ← Fetches data
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Supabase   │  ← Data source
└──────┬──────┘
       │
       ▼
┌─────────────┐
│PatientsLoad │  ← State emitted
│  Success    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Widget    │  ← UI rebuilds
│  Rebuilds   │
└─────────────┘
```

---

## 🎨 UI/UX Architecture

### Responsive Design Strategy

```dart
// Adaptive breakpoints
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px

// Implementation
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else if (constraints.maxWidth < 900) {
      return TabletLayout();
    }
    return DesktopLayout();
  },
)
```

### Theme System

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4F7EFF)),
  useMaterial3: true,
  // Custom gradient colors
  // Typography scale
  // Component themes
)
```

---

## 🚀 Performance Optimization

### Strategies Implemented

1. **Image Caching**
   - In-memory cache for profile images
   - Prevents redundant network calls

2. **Lazy Loading**
   - Paginated lists for large datasets
   - On-demand data fetching

3. **BLoC Optimization**
   - Proper event debouncing
   - State comparison to prevent unnecessary rebuilds

4. **Build Optimization**
   - Const constructors where possible
   - Widget extraction to minimize rebuilds

---

## 🧪 Testing Strategy

### Test Pyramid

```
           ┌──────────┐
          ╱  E2E (5%)  ╲
         ├──────────────┤
        ╱  Integration   ╲
       ╱    Tests (15%)   ╲
      ├────────────────────┤
     ╱   Unit Tests (80%)   ╲
    └────────────────────────┘
```

### Testing Layers

1. **Unit Tests** - BLoC logic, repositories, utilities
2. **Widget Tests** - UI components and interactions
3. **Integration Tests** - Feature flows
4. **E2E Tests** - Critical user journeys

---

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
  flutter_bloc: ^8.1.3 # State management
  equatable: ^2.0.5 # Value equality
  supabase_flutter: ^2.0.0 # Backend services

  # UI/UX
  flutter_svg: ^2.0.9
  google_fonts: ^6.1.0

  # Utilities
  intl: ^0.19.0 # Internationalization
  image_picker: ^1.0.4 # Image selection
  file_picker: ^6.1.1 # File selection
  url_launcher: ^6.2.1 # External links

  # Charts & Visualization
  fl_chart: ^0.66.0

dev_dependencies:
  flutter_test:
  flutter_lints: ^3.0.1
  bloc_test: ^9.1.5 # BLoC testing utilities
```

---

## 🔌 API Integration

### Supabase Client Configuration

```dart
class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_ANON_KEY',
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}
```

### Data Fetching Pattern

```dart
Future<List<Patient>> fetchPatients() async {
  final response = await Supabase.instance.client
      .from('patients')
      .select()
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => Patient.fromJson(json))
      .toList();
}
```

---

## 🔄 CI/CD Pipeline (Planned)

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   Git    │───>│  Build   │───>│   Test   │───>│  Deploy  │
│   Push   │    │  &       │    │          │    │   to     │
│          │    │  Lint    │    │          │    │ Staging  │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

### Planned Tools

- GitHub Actions for automation
- Flutter analyze for code quality
- Flutter test for automated testing
- Firebase Hosting for web deployment

---

## 📊 Monitoring & Logging

### Error Tracking (Planned)

- Sentry integration for crash reporting
- Custom error logging service
- User analytics (privacy-compliant)

### Performance Monitoring

- Flutter DevTools for profiling
- Custom performance metrics
- Database query optimization monitoring

---

## 🔮 Future Architecture Considerations

1. **Microservices** - Separate services for complex operations
2. **Offline Support** - Local database with sync
3. **Real-time Updates** - Supabase Realtime for live data
4. **GraphQL** - Consider for complex data queries
5. **Server-Side Rendering** - For SEO and performance
