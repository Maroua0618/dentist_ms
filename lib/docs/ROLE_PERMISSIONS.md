# Role-Based Access Control (RBAC)

## 👥 User Roles Overview

The system implements three distinct user roles with specific permissions to ensure data security and appropriate access levels.

| Role             | Description                    | Primary Users                    |
| ---------------- | ------------------------------ | -------------------------------- |
| **Admin**        | Full system access             | Clinic owners, IT administrators |
| **Doctor**       | Medical and patient care focus | Dentists, dental specialists     |
| **Receptionist** | Front desk operations          | Front desk staff, schedulers     |

---

## 🔐 Permission Matrix

### Complete Permissions Overview

| Feature                | Admin | Doctor      | Receptionist |
| ---------------------- | ----- | ----------- | ------------ |
| **Authentication**     |
| Login/Logout           | ✅    | ✅          | ✅           |
| Reset Password         | ✅    | ✅          | ✅           |
| **Dashboard**          |
| View Dashboard         | ✅    | ✅          | ✅           |
| View All Metrics       | ✅    | ✅          | 🔶 Limited   |
| Export Reports         | ✅    | ✅          | ❌           |
| **Patient Management** |
| View Patients          | ✅    | ✅          | ✅           |
| Add Patient            | ✅    | ✅          | ✅           |
| Edit Patient Info      | ✅    | ✅          | ✅           |
| Delete Patient         | ✅    | ❌          | ❌           |
| Upload Patient Photo   | ✅    | ✅          | ✅           |
| Search/Filter Patients | ✅    | ✅          | ✅           |
| Export Patient Data    | ✅    | ✅          | ❌           |
| **Medical Records**    |
| View Dental History    | ✅    | ✅          | ✅           |
| Add Dental Records     | ✅    | ✅          | ❌           |
| View Prescriptions     | ✅    | ✅          | ❌           |
| Create Prescriptions   | ✅    | ✅          | ❌           |
| View Allergies         | ✅    | ✅          | ❌           |
| Manage Allergies       | ✅    | ✅          | ❌           |
| View Upcoming Appts    | ✅    | ✅          | ✅           |
| **Appointments**       |
| View Calendar          | ✅    | ✅          | ✅           |
| Schedule Appointment   | ✅    | ✅          | ✅           |
| Edit Appointment       | ✅    | ✅          | ✅           |
| Cancel Appointment     | ✅    | ✅          | ✅           |
| Update Status          | ✅    | ✅          | 🔶 Limited   |
| **Billing & Finance**  |
| View Invoices          | ✅    | 🔶 Own only | ✅           |
| Create Invoice         | ✅    | ❌          | ✅           |
| Edit Invoice           | ✅    | ❌          | ✅           |
| Delete Invoice         | ✅    | ❌          | ❌           |
| Record Payment         | ✅    | ❌          | ✅           |
| View Financial Reports | ✅    | ❌          | ❌           |
| Manage Expenses        | ✅    | ❌          | ❌           |
| **Settings**           |
| Update Clinic Info     | ✅    | ❌          | ❌           |
| Manage Users           | ✅    | ❌          | ❌           |
| View System Logs       | ✅    | ❌          | ❌           |
| Update Own Profile     | ✅    | ✅          | ✅           |
| Change Password        | ✅    | ✅          | ✅           |

**Legend:**  
✅ Full Access | 🔶 Partial/Limited Access | ❌ No Access

---

## 👤 Role Descriptions

### 1. Administrator

**Purpose:** Complete system management and oversight

**Key Responsibilities:**

- System configuration and maintenance
- User management and role assignment
- Financial oversight and reporting
- Data backup and security
- Clinic information management
- Advanced analytics and reporting

**Unique Permissions:**

- Delete patients and records
- Access financial reports
- Manage system settings
- View audit logs
- Export all data

**Use Cases:**

- Clinic owner reviewing monthly finances
- IT admin managing user accounts
- Senior manager analyzing performance metrics

---

### 2. Doctor / Dentist

**Purpose:** Patient care and medical decision-making

**Key Responsibilities:**

- Patient diagnosis and treatment planning
- Medical record documentation
- Prescription management
- Treatment procedure tracking
- Patient consultation

**Unique Permissions:**

- Full access to medical records
- Create and manage prescriptions
- Add treatment notes
- View complete patient history
- Update dental records

**Restrictions:**

- Cannot delete patients
- No financial report access
- Cannot modify clinic settings
- Limited to own appointments (data view)

**Use Cases:**

- Reviewing patient medical history before appointment
- Creating post-treatment prescriptions
- Documenting dental procedures
- Updating allergy information

---

### 3. Receptionist

**Purpose:** Front desk operations and scheduling

**Key Responsibilities:**

- Patient registration and check-in
- Appointment scheduling and management
- Basic billing and payment collection
- Customer service and communication

**Permissions:**

- Schedule and manage appointments
- Add/edit patient contact information
- Create invoices
- Record payments
- View basic patient information

**Restrictions:**

- Cannot delete patients
- Cannot view prescriptions
- Cannot view allergies
- No access to financial reports
- Cannot modify system settings
- No access to sensitive medical data

**Use Cases:**

- Registering new patient at front desk
- Scheduling follow-up appointment
- Creating invoice for completed treatment
- Recording patient payment

---

## 🛡️ Implementation

### Role Enum Definition

```dart
enum UserRole {
  admin,
  doctor,
  receptionist;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role.toLowerCase(),
      orElse: () => UserRole.receptionist,
    );
  }
}
```

### Permission Class

```dart
class Permissions {
  final bool canDeletePatients;
  final bool canViewAllMedicalRecords;
  final bool canManageFinances;
  final bool canManageSystemSettings;
  final bool canViewPrescriptions;
  final bool canViewAllergies;
  final bool canCreatePrescriptions;

  const Permissions({
    required this.canDeletePatients,
    required this.canViewAllMedicalRecords,
    required this.canManageFinances,
    required this.canManageSystemSettings,
    required this.canViewPrescriptions,
    required this.canViewAllergies,
    required this.canCreatePrescriptions,
  });

  static Permissions fromRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Permissions(
          canDeletePatients: true,
          canViewAllMedicalRecords: true,
          canManageFinances: true,
          canManageSystemSettings: true,
          canViewPrescriptions: true,
          canViewAllergies: true,
          canCreatePrescriptions: true,
        );

      case UserRole.doctor:
        return const Permissions(
          canDeletePatients: false,
          canViewAllMedicalRecords: true,
          canManageFinances: false,
          canManageSystemSettings: false,
          canViewPrescriptions: true,
          canViewAllergies: true,
          canCreatePrescriptions: true,
        );

      case UserRole.receptionist:
        return const Permissions(
          canDeletePatients: false,
          canViewAllMedicalRecords: false,
          canManageFinances: false,
          canManageSystemSettings: false,
          canViewPrescriptions: false,
          canViewAllergies: false,
          canCreatePrescriptions: false,
        );
    }
  }
}
```

### UI Implementation Examples

#### 1. Conditional Widget Rendering

```dart
// Show delete button only for admins
if (userRole == UserRole.admin) {
  _buildActionButton(
    'Supprimer le patient',
    Icons.delete_forever,
    false,
    () => onActionTap('Delete Patient'),
  ),
}
```

#### 2. Tab Visibility Control

```dart
List<Widget> _buildTabList() {
  if (userRole == UserRole.receptionist) {
    // Receptionist sees limited tabs
    return const [
      Tab(text: 'Histo dentaire'),
      Tab(text: 'À venir'),
    ];
  }

  // Doctors and Admins see all tabs
  return const [
    Tab(text: 'Histo dentaire'),
    Tab(text: 'Ordonnances'),
    Tab(text: 'Allergies'),
    Tab(text: 'À venir'),
  ];
}
```

#### 3. Feature Access Check

```dart
// Get user role from auth state
final authState = context.watch<AuthBloc>().state;
final userRole = authState.user?.role ?? UserRole.receptionist;

// Pass to widgets
QuickActionsCard(
  onActionTap: _handleQuickAction,
  userRole: userRole,
)
```

---

## 🔒 Database-Level Security

### Row Level Security (RLS) Policies

#### Patients Table

```sql
-- All authenticated users can read
CREATE POLICY "Authenticated users can read patients"
  ON patients FOR SELECT
  TO authenticated
  USING (true);

-- Only admins can delete
CREATE POLICY "Only admins can delete patients"
  ON patients FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.auth_id = auth.uid()
      AND users.role = 'admin'
    )
  );
```

#### Prescriptions Table

```sql
-- Doctors and admins can view prescriptions
CREATE POLICY "Doctors and admins can view prescriptions"
  ON prescriptions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.auth_id = auth.uid()
      AND users.role IN ('admin', 'doctor')
    )
  );

-- Receptionists cannot access
-- (No policy = no access)
```

#### Invoices Table

```sql
-- Admins and receptionists can manage invoices
CREATE POLICY "Admins and receptionists manage invoices"
  ON invoices FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.auth_id = auth.uid()
      AND users.role IN ('admin', 'receptionist')
    )
  );
```

---

## 🎯 Permission Scenarios

### Scenario 1: Receptionist Viewing Patient Profile

```
✅ Can view: Name, contact info, dental history, upcoming appointments
❌ Cannot view: Prescriptions, allergies
❌ Cannot do: Delete patient, view detailed medical notes
```

### Scenario 2: Doctor Treating Patient

```
✅ Can view: All medical records, prescriptions, allergies
✅ Can do: Add treatment notes, create prescriptions, update records
❌ Cannot do: Delete patient, view financial reports
```

### Scenario 3: Admin Managing System

```
✅ Can view: Everything
✅ Can do: Delete records, manage users, view financial reports
✅ Full control: All system features and settings
```

---

## 🔄 Role Assignment Workflow

### 1. User Registration (Admin Only)

```dart
// Admin creates new user account
final newUser = await authRepository.createUser(
  email: email,
  password: password,
  firstName: firstName,
  lastName: lastName,
  role: selectedRole, // Admin selects role
);
```

### 2. Role Verification on Login

```dart
// On successful login, fetch user details
final user = await userRepository.getUserByAuthId(authId);

// Store role in auth state
emit(AuthState(
  status: AuthStatus.authenticated,
  user: user,
  permissions: Permissions.fromRole(user.role),
));
```

### 3. Runtime Permission Checks

```dart
// Check permission before action
final canDelete = context.read<AuthBloc>().state.permissions.canDeletePatients;

if (canDelete) {
  // Proceed with deletion
} else {
  // Show unauthorized message
}
```

---

## 📊 Audit & Compliance

### Audit Logging (Planned)

- Track sensitive operations (delete, export)
- Log role changes
- Monitor access to restricted data
- Compliance with healthcare regulations (HIPAA considerations)

### Security Best Practices

1. **Principle of Least Privilege** - Users have minimum necessary access
2. **Separation of Duties** - Critical actions require multiple roles
3. **Regular Review** - Periodic access rights review
4. **Session Management** - Automatic logout after inactivity
5. **Password Policies** - Strong password requirements

---

## 🚨 Security Considerations

### Current Implementation

- ✅ Role-based UI restrictions
- ✅ Database RLS policies
- ✅ Authentication required for all features
- ✅ Permission checks at widget level

### Planned Enhancements

- [ ] Two-factor authentication (2FA)
- [ ] IP whitelist for admin access
- [ ] Session timeout configuration
- [ ] Password rotation policy
- [ ] Comprehensive audit logging
- [ ] Encrypted sensitive data fields

---

## 📝 Role Change Process

### Changing User Role (Admin Only)

1. Admin navigates to User Management
2. Selects user to modify
3. Updates role dropdown
4. Confirms change
5. System logs the change
6. User notified of role change
7. New permissions take effect on next login

### Emergency Access Override (Future)

- Super admin role for emergency access
- Time-limited elevated permissions
- All actions logged

---

**Last Updated:** January 2026  
**Review Frequency:** Quarterly  
**Compliance Officer:** TBD
