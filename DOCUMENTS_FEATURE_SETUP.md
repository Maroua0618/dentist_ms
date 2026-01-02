# Patient Documents Feature Setup

## Overview
The Documents tab has been added to the appointment detail page, allowing doctors to upload and manage patient documents (PDFs, images, Word docs).

## What Was Added

### 1. New Widget: `documents_tab.dart`
Located in: `lib/features/appointments/presentation/widgets/documents_tab.dart`

Features:
- Upload documents (PDF, JPG, PNG, DOC, DOCX)
- View list of all patient documents
- Delete documents
- Download/view documents
- Shows uploader name and date

### 2. Updated Files
- `appointment_detail_page.dart` - Added "Documents" tab
- `pubspec.yaml` - Added `file_picker` package
- `appointment_remote.dart` - Fixed doctor name display issue

## Supabase Setup Required

### 1. Create Storage Bucket

You need to create a storage bucket in your Supabase project:

1. Go to your Supabase project dashboard
2. Navigate to **Storage** in the left sidebar
3. Click **Create a new bucket**
4. Use these settings:
   - **Name**: `documents`
   - **Public bucket**: ✅ Yes (check this box)
   - Click **Create bucket**

### 2. Set Storage Policies (REQUIRED)

**IMPORTANT**: The storage bucket has Row-Level Security enabled by default. You MUST add these policies or uploads will fail with a 403 error.

Go to **SQL Editor** in Supabase and run:

```sql
-- Allow authenticated users to upload documents
CREATE POLICY "Allow authenticated upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'documents');

-- Allow authenticated users to read documents
CREATE POLICY "Allow authenticated read"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'documents');

-- Allow authenticated users to delete documents
CREATE POLICY "Allow authenticated delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'documents');

-- Allow authenticated users to update documents
CREATE POLICY "Allow authenticated update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'documents')
WITH CHECK (bucket_id = 'documents');
```

**Alternative (Less Secure)**: Disable RLS on the bucket by going to Storage → documents bucket → Policies tab → Toggle "Enable RLS" OFF.

## Database Schema

The feature uses the existing `patient_documents` table with this structure:

```sql
patient_documents (
  id                    int4
  patient_id            int4
  uploaded_by_user_id   int4
  file_name             varchar
  file_path             varchar
  file_type             varchar
  uploaded_at           timestamp
  description           text
  appointment_id        int4
)
```

## Usage

1. Log in as a doctor
2. Navigate to an appointment detail page
3. Click on the **"Documents"** tab
4. Click **"Ajouter"** (Add) button to upload a document
5. Select a file and enter a description
6. The document will be uploaded to Supabase Storage and linked to the patient

## Features Implemented

✅ Upload documents with description
✅ View all patient documents
✅ Display file type icons (PDF, images, docs)
✅ Show uploader name and upload date
✅ Delete documents
✅ Links to appointment and patient
✅ Separate widget for better organization

## Supported File Types

- PDF (`.pdf`)
- Images (`.jpg`, `.jpeg`, `.png`)
- Word Documents (`.doc`, `.docx`)

## Note

The download/view functionality currently logs the document URL. To fully implement it, you may want to add the `url_launcher` package:

```yaml
dependencies:
  url_launcher: ^6.2.0
```

Then update the `_downloadDocument` method in `documents_tab.dart` to open the URL in a browser.
