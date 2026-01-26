# Setup & Installation Guide

## 📋 Prerequisites

### Required Software

- **Flutter SDK:** 3.16.0 or higher
- **Dart SDK:** 3.2.0 or higher (bundled with Flutter)
- **IDE:** VS Code or Android Studio
- **Git:** For version control
- **Node.js:** (Optional) For web development

### Development Tools

```bash
# Check Flutter installation
flutter doctor

# Verify Dart version
dart --version

# Check for updates
flutter upgrade
```

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd dentist_ms
```

### 2. Install Dependencies

```bash
# Get all Flutter packages
flutter pub get

# Verify installation
flutter pub outdated
```

### 3. Supabase Setup

#### Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in project details:
   - Project name: `dental-clinic-ms`
   - Database password: (save securely)
   - Region: Choose closest to your location

#### Get API Credentials

1. Navigate to **Project Settings** > **API**
2. Copy the following:
   - Project URL: `https://xxxxx.supabase.co`
   - Anon/Public Key: `eyJhbGc...`

#### Configure Environment

Create `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

**⚠️ Security Note:** Never commit credentials to version control

### 4. Database Setup

#### Run SQL Schema

1. In Supabase Dashboard, go to **SQL Editor**
2. Copy content from `lib/docs/database_schema.sql`
3. Execute the SQL script
4. Verify tables are created in **Table Editor**

#### Optional: Load Sample Data

```sql
-- Insert sample admin user
INSERT INTO users (auth_id, email, first_name, last_name, role, is_active)
VALUES ('auth-uuid', 'admin@clinic.com', 'Admin', 'User', 'admin', true);

-- Insert sample patient
INSERT INTO patients (name, dob, gender, phone, email)
VALUES ('John Doe', '1990-01-01', 'M', '123-456-7890', 'john@example.com');
```

### 5. Storage Buckets Setup

#### Create Buckets

In Supabase Dashboard > **Storage**:

1. **profile-images** bucket:
   - Public: Yes
   - Allowed MIME types: image/\*
   - Max file size: 5MB

2. **medical-documents** bucket:
   - Public: No
   - Allowed MIME types: application/pdf, image/\*
   - Max file size: 10MB

#### Set Bucket Policies

```sql
-- Public read access for profile images
CREATE POLICY "Public read access" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-images');

-- Authenticated upload access
CREATE POLICY "Authenticated upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-images'
    AND auth.role() = 'authenticated'
  );
```

### 6. Run Application

#### Debug Mode

```bash
# Run on Chrome (web)
flutter run -d chrome

# Run on Windows
flutter run -d windows

# Run on connected device
flutter run
```

#### Release Build

```bash
# Build for web
flutter build web

# Build for Windows
flutter build windows

# Build APK for Android
flutter build apk --release
```

---

## 🔧 Configuration

### VS Code Setup

#### Recommended Extensions

```json
{
  "recommendations": [
    "Dart-Code.flutter",
    "Dart-Code.dart-code",
    "nash.awesome-flutter-snippets",
    "alexisvt.flutter-snippets",
    "usernamehw.errorlens"
  ]
}
```

#### Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Web)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["-d", "chrome"]
    },
    {
      "name": "Flutter (Windows)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["-d", "windows"]
    }
  ]
}
```

### Android Studio Setup

1. Install Flutter plugin
2. Install Dart plugin
3. Configure Flutter SDK path
4. Enable hot reload

---

## 🏗️ Project Structure Setup

### Feature Module Template

When adding a new feature:

```
features/new_feature/
├── bloc/
│   ├── new_feature_bloc.dart
│   ├── new_feature_event.dart
│   └── new_feature_state.dart
├── data/
│   └── new_feature_remote.dart
├── models/
│   └── new_feature_model.dart
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── dialogs/
└── repositories/
    └── new_feature_repository.dart
```

---

## 🧪 Testing Setup

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/patient_test.dart
```

### Generate Coverage Report

```bash
# Install lcov (macOS/Linux)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

---

## 🔐 Authentication Setup

### Create First Admin User

1. **Via Supabase Dashboard:**
   - Go to **Authentication** > **Users**
   - Click "Add user"
   - Email: `admin@clinic.com`
   - Password: (set secure password)
   - Auto-confirm: Yes

2. **Insert into users table:**

```sql
INSERT INTO users (
  auth_id,
  email,
  first_name,
  last_name,
  role,
  is_active
)
VALUES (
  'AUTH_UUID_FROM_SUPABASE_AUTH',
  'admin@clinic.com',
  'Admin',
  'User',
  'admin',
  true
);
```

### Test Login

1. Run the application
2. Navigate to login page
3. Enter admin credentials
4. Verify dashboard access

---

## 📱 Platform-Specific Setup

### Web Deployment

#### Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init hosting

# Build and deploy
flutter build web
firebase deploy
```

#### Netlify

```bash
# Build web app
flutter build web

# Deploy build/web folder to Netlify
# (Use Netlify CLI or drag-and-drop)
```

### Windows Desktop

#### Prerequisites

- Visual Studio 2022 (Desktop development with C++)
- Windows 10 SDK

#### Build

```bash
flutter build windows --release
```

Output: `build/windows/runner/Release/`

### Android

#### Setup

1. Install Android Studio
2. Install Android SDK (API 21+)
3. Create keystore for signing

```bash
# Generate keystore
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release

# Configure in android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=release
storeFile=<path-to-release.jks>
```

#### Build

```bash
flutter build apk --release
flutter build appbundle --release
```

---

## 🔍 Troubleshooting

### Common Issues

#### 1. Supabase Connection Error

```
Error: Failed to connect to Supabase
```

**Solution:**

- Verify URL and API key in configuration
- Check internet connection
- Ensure Supabase project is active

#### 2. Image Upload Fails

```
Error: Storage bucket not found
```

**Solution:**

- Verify bucket exists in Supabase Storage
- Check bucket policies and permissions
- Ensure bucket name matches in code

#### 3. Authentication Error

```
Error: Invalid login credentials
```

**Solution:**

- Verify user exists in Supabase Auth
- Check email confirmation status
- Ensure user record exists in users table
- Verify password is correct

#### 4. Database Query Error

```
Error: relation "patients" does not exist
```

**Solution:**

- Run database schema SQL
- Verify table names match code
- Check RLS policies

#### 5. Flutter Version Issues

```
Error: Requires Dart SDK version >=3.2.0
```

**Solution:**

```bash
flutter upgrade
flutter pub get
```

---

## 🔄 Update & Maintenance

### Update Dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Update Flutter SDK
flutter upgrade
```

### Database Migrations

When schema changes:

1. Create migration SQL file
2. Run in Supabase SQL Editor
3. Update model classes
4. Update repository methods
5. Test thoroughly

---

## 📊 Environment Variables

### Development vs Production

Create environment-specific configs:

**dev_config.dart:**

```dart
class Config {
  static const environment = 'development';
  static const supabaseUrl = 'DEV_URL';
  static const enableLogging = true;
}
```

**prod_config.dart:**

```dart
class Config {
  static const environment = 'production';
  static const supabaseUrl = 'PROD_URL';
  static const enableLogging = false;
}
```

---

## 🎯 Next Steps

1. ✅ Complete setup and verify installation
2. 📖 Review [Technical Architecture](TECHNICAL_ARCHITECTURE.md)
3. 📝 Check [User Stories](USER_STORIES.md) for features
4. 🐛 Review [Product Backlog](PRODUCT_BACKLOG.md) for tasks
5. 🚀 Start development!

---

## 📞 Support

**Issues:** Create issue on GitHub repository  
**Questions:** Contact development team  
**Documentation:** Check `/docs` folder

**Last Updated:** January 2026
