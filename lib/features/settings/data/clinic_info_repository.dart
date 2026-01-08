import 'dart:convert';
import 'dart:typed_data';
import 'package:dentist_ms/features/settings/models/clinic_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ClinicInfoRepository {
  Future<ClinicInfo> fetchClinicInfo();
  Future<void> saveClinicInfo(ClinicInfo info);
}

class SupabaseClinicInfoRepository implements ClinicInfoRepository {
  SupabaseClinicInfoRepository(this._client);

  final SupabaseClient _client;
  static const String _bucket = 'clinic-settings';
  static const String _fileName = 'clinic_info.json';

  @override
  Future<ClinicInfo> fetchClinicInfo() async {
    try {
      // Download the JSON file from storage
      final bytes = await _client.storage.from(_bucket).download(_fileName);

      // Parse the JSON
      final jsonString = utf8.decode(bytes);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return ClinicInfo.fromJson(jsonData);
    } catch (e) {
      // If file doesn't exist or any error, return defaults
      print('Error loading clinic info: $e');
      return ClinicInfo.defaultValues();
    }
  }

  @override
  Future<void> saveClinicInfo(ClinicInfo info) async {
    try {
      // Convert to JSON string
      final jsonString = jsonEncode(info.toJson());
      final bytes = utf8.encode(jsonString);

      // Upload to storage (upsert)
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            _fileName,
            Uint8List.fromList(bytes),
            fileOptions: const FileOptions(
              contentType: 'application/json',
              upsert: true,
            ),
          );
    } catch (e) {
      print('Error saving clinic info: $e');
      rethrow;
    }
  }
}
