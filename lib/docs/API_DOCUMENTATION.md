# API Documentation

## 🔌 Supabase API Integration

This document describes the API integration between the Flutter application and Supabase backend services.

---

## 🔐 Authentication API

### Initialize Supabase Client

```dart
await Supabase.initialize(
  url: SupabaseConfig.supabaseUrl,
  anonKey: SupabaseConfig.supabaseAnonKey,
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);
```

### Sign In

**Endpoint:** `auth.signInWithPassword()`  
**Method:** POST  
**Purpose:** Authenticate user with email and password

```dart
Future<AuthResponse> signIn(String email, String password) async {
  return await Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );
}
```

**Response:**

```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "authenticated"
  },
  "session": {
    "access_token": "jwt-token",
    "refresh_token": "refresh-token"
  }
}
```

### Sign Out

**Endpoint:** `auth.signOut()`  
**Method:** POST

```dart
Future<void> signOut() async {
  await Supabase.instance.client.auth.signOut();
}
```

### Password Reset

**Endpoint:** `auth.resetPasswordForEmail()`  
**Method:** POST

```dart
Future<void> resetPassword(String email) async {
  await Supabase.instance.client.auth.resetPasswordForEmail(
    email,
    redirectTo: 'https://your-app.com/reset-password',
  );
}
```

### Get Current User

```dart
User? getCurrentUser() {
  return Supabase.instance.client.auth.currentUser;
}
```

---

## 👥 Users API

### Get User by Auth ID

**Table:** `users`  
**Method:** SELECT

```dart
Future<AppUser?> getUserByAuthId(String authId) async {
  final response = await Supabase.instance.client
      .from('users')
      .select()
      .eq('auth_id', authId)
      .single();

  return AppUser.fromJson(response);
}
```

### Update User Profile

**Table:** `users`  
**Method:** UPDATE

```dart
Future<void> updateUserProfile({
  required int userId,
  String? firstName,
  String? lastName,
  String? phone,
  String? profileImageUrl,
}) async {
  await Supabase.instance.client
      .from('users')
      .update({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      })
      .eq('id', userId);
}
```

---

## 🏥 Patients API

### Get All Patients

**Table:** `patients`  
**Method:** SELECT  
**Ordering:** Most recent first

```dart
Future<List<Patient>> getPatients() async {
  final response = await Supabase.instance.client
      .from('patients')
      .select()
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => Patient.fromJson(json))
      .toList();
}
```

**Response:**

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "dob": "1990-01-15",
    "gender": "M",
    "phone": "123-456-7890",
    "email": "john@example.com",
    "address": "123 Main St",
    "profile_image_url": "path/to/image.jpg",
    "created_at": "2024-01-15T10:00:00Z"
  }
]
```

### Get Patient by ID

**Table:** `patients`  
**Method:** SELECT

```dart
Future<Patient?> getPatientById(int patientId) async {
  final response = await Supabase.instance.client
      .from('patients')
      .select()
      .eq('id', patientId)
      .single();

  return Patient.fromJson(response);
}
```

### Create Patient

**Table:** `patients`  
**Method:** INSERT

```dart
Future<Patient> createPatient({
  required String name,
  required String dob,
  required String gender,
  String? phone,
  String? email,
  String? address,
}) async {
  final response = await Supabase.instance.client
      .from('patients')
      .insert({
        'name': name,
        'dob': dob,
        'gender': gender,
        'phone': phone,
        'email': email,
        'address': address,
      })
      .select()
      .single();

  return Patient.fromJson(response);
}
```

### Update Patient

**Table:** `patients`  
**Method:** UPDATE

```dart
Future<void> updatePatient(int patientId, Map<String, dynamic> updates) async {
  await Supabase.instance.client
      .from('patients')
      .update(updates)
      .eq('id', patientId);
}
```

### Delete Patient

**Table:** `patients`  
**Method:** DELETE  
**Role Required:** Admin only

```dart
Future<void> deletePatient(int patientId) async {
  await Supabase.instance.client
      .from('patients')
      .delete()
      .eq('id', patientId);
}
```

### Search Patients

**Method:** SELECT with ILIKE

```dart
Future<List<Patient>> searchPatients(String query) async {
  final response = await Supabase.instance.client
      .from('patients')
      .select()
      .or('name.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%')
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => Patient.fromJson(json))
      .toList();
}
```

---

## 📅 Appointments API

### Get All Appointments

**Table:** `appointments`  
**Method:** SELECT with JOIN

```dart
Future<List<Appointment>> getAppointments() async {
  final response = await Supabase.instance.client
      .from('appointments')
      .select('''
        *,
        patients(*),
        users!appointments_doctor_id_fkey(*)
      ''')
      .order('appointment_date', ascending: true);

  return (response as List)
      .map((json) => Appointment.fromJson(json))
      .toList();
}
```

### Get Appointments by Patient

**Table:** `appointments`  
**Method:** SELECT

```dart
Future<List<Appointment>> getAppointmentsByPatient(int patientId) async {
  final response = await Supabase.instance.client
      .from('appointments')
      .select('''
        *,
        users!appointments_doctor_id_fkey(*)
      ''')
      .eq('patient_id', patientId)
      .order('appointment_date', ascending: true);

  return (response as List)
      .map((json) => Appointment.fromJson(json))
      .toList();
}
```

### Create Appointment

**Table:** `appointments`  
**Method:** INSERT

```dart
Future<Appointment> createAppointment({
  required int patientId,
  required int doctorId,
  required DateTime appointmentDate,
  required String status,
  String? notes,
}) async {
  final response = await Supabase.instance.client
      .from('appointments')
      .insert({
        'patient_id': patientId,
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String(),
        'status': status,
        'notes': notes,
      })
      .select()
      .single();

  return Appointment.fromJson(response);
}
```

### Update Appointment Status

**Table:** `appointments`  
**Method:** UPDATE

```dart
Future<void> updateAppointmentStatus(int appointmentId, String status) async {
  await Supabase.instance.client
      .from('appointments')
      .update({'status': status})
      .eq('id', appointmentId);
}
```

---

## 💰 Billing API

### Get Invoices

**Table:** `invoices`  
**Method:** SELECT with JOIN

```dart
Future<List<Invoice>> getInvoices() async {
  final response = await Supabase.instance.client
      .from('invoices')
      .select('''
        *,
        patients(*),
        invoice_items(*, treatments(*))
      ''')
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => Invoice.fromJson(json))
      .toList();
}
```

### Create Invoice

**Table:** `invoices` + `invoice_items`  
**Method:** INSERT (Transaction)

```dart
Future<Invoice> createInvoice({
  required int patientId,
  required List<InvoiceItem> items,
  double? discount,
}) async {
  // Create invoice
  final invoiceResponse = await Supabase.instance.client
      .from('invoices')
      .insert({
        'patient_id': patientId,
        'subtotal': calculateSubtotal(items),
        'discount': discount ?? 0,
        'total': calculateTotal(items, discount),
        'status': 'pending',
      })
      .select()
      .single();

  final invoiceId = invoiceResponse['id'];

  // Create invoice items
  await Supabase.instance.client
      .from('invoice_items')
      .insert(
        items.map((item) => {
          'invoice_id': invoiceId,
          'treatment_id': item.treatmentId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total': item.total,
        }).toList(),
      );

  return Invoice.fromJson(invoiceResponse);
}
```

### Record Payment

**Table:** `payments`  
**Method:** INSERT + UPDATE invoice

```dart
Future<Payment> recordPayment({
  required int invoiceId,
  required double amount,
  required String paymentMethod,
}) async {
  // Record payment
  final paymentResponse = await Supabase.instance.client
      .from('payments')
      .insert({
        'invoice_id': invoiceId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_date': DateTime.now().toIso8601String(),
      })
      .select()
      .single();

  // Update invoice status
  await Supabase.instance.client
      .from('invoices')
      .update({'status': 'paid'})
      .eq('id', invoiceId);

  return Payment.fromJson(paymentResponse);
}
```

---

## 📁 Storage API

### Upload Profile Image

**Bucket:** `profile-images`  
**Method:** Upload

```dart
Future<String?> uploadProfileImage(File imageFile, int userId) async {
  final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final path = 'profiles/$fileName';

  await Supabase.instance.client.storage
      .from('profile-images')
      .upload(path, imageFile);

  return path;
}
```

### Download Image

**Bucket:** `profile-images`  
**Method:** Download

```dart
Future<Uint8List> downloadImage(String path) async {
  return await Supabase.instance.client.storage
      .from('profile-images')
      .download(path);
}
```

### Get Public URL

**Method:** getPublicUrl

```dart
String getPublicImageUrl(String path) {
  return Supabase.instance.client.storage
      .from('profile-images')
      .getPublicUrl(path);
}
```

### Delete Image

**Method:** remove

```dart
Future<void> deleteImage(String path) async {
  await Supabase.instance.client.storage
      .from('profile-images')
      .remove([path]);
}
```

---

## 📊 Analytics Queries

### Dashboard Statistics

```dart
Future<Map<String, dynamic>> getDashboardStats() async {
  // Total patients
  final patientsCount = await Supabase.instance.client
      .from('patients')
      .select('id', const FetchOptions(count: CountOption.exact, head: true));

  // Today's appointments
  final todayStart = DateTime.now().copyWith(hour: 0, minute: 0);
  final todayEnd = DateTime.now().copyWith(hour: 23, minute: 59);

  final todayAppointments = await Supabase.instance.client
      .from('appointments')
      .select('id', const FetchOptions(count: CountOption.exact, head: true))
      .gte('appointment_date', todayStart.toIso8601String())
      .lte('appointment_date', todayEnd.toIso8601String());

  // Revenue (this month)
  final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
  final revenue = await Supabase.instance.client
      .from('invoices')
      .select('total')
      .gte('created_at', monthStart.toIso8601String());

  final totalRevenue = (revenue as List)
      .fold<double>(0, (sum, item) => sum + (item['total'] as num).toDouble());

  return {
    'totalPatients': patientsCount.count,
    'todayAppointments': todayAppointments.count,
    'monthlyRevenue': totalRevenue,
  };
}
```

---

## 🔄 Real-time Subscriptions (Future)

### Subscribe to Table Changes

```dart
void subscribeToPatients(Function(List<Patient>) onData) {
  Supabase.instance.client
      .from('patients')
      .stream(primaryKey: ['id'])
      .listen((data) {
        final patients = (data as List)
            .map((json) => Patient.fromJson(json))
            .toList();
        onData(patients);
      });
}
```

---

## ⚠️ Error Handling

### Standard Error Response

```dart
try {
  await Supabase.instance.client
      .from('patients')
      .insert(data);
} on PostgrestException catch (e) {
  print('Database error: ${e.message}');
  print('Code: ${e.code}');
  print('Details: ${e.details}');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Common Error Codes

- `23505` - Unique constraint violation
- `23503` - Foreign key violation
- `42P01` - Table does not exist
- `PGRST301` - JWT token expired

---

## 🔒 Row Level Security (RLS)

### Policies Applied

**Patients Table:**

```sql
-- Read access for authenticated users
CREATE POLICY "Authenticated users can read patients"
  ON patients FOR SELECT
  TO authenticated
  USING (true);

-- Insert for authenticated users
CREATE POLICY "Authenticated users can insert patients"
  ON patients FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Update for authenticated users
CREATE POLICY "Authenticated users can update patients"
  ON patients FOR UPDATE
  TO authenticated
  USING (true);

-- Delete only for admins
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

---

## 📈 Rate Limits & Best Practices

### Supabase Limits

- **API Requests:** 500 requests/second (Free tier)
- **Database Connections:** 60 concurrent (Free tier)
- **Storage:** 1GB (Free tier)
- **Bandwidth:** 2GB/month (Free tier)

### Best Practices

1. **Batch Operations** - Use bulk inserts when possible
2. **Caching** - Cache frequently accessed data
3. **Pagination** - Limit large queries with `.limit()`
4. **Indexing** - Ensure proper indexes on queried columns
5. **Connection Pooling** - Reuse database connections

---

**API Version:** 1.0  
**Last Updated:** January 2026
