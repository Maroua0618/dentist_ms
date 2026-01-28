import 'package:supabase_flutter/supabase_flutter.dart';

/// One-time utility to fix the invoice_items sequence
/// Run this ONCE to sync the sequence with the max ID in the table
Future<void> fixInvoiceItemsSequence() async {
  try {
    final client = Supabase.instance.client;

    print('====== FIXING INVOICE_ITEMS SEQUENCE ======');

    // This SQL resets the sequence to match the current max ID
    final result = await client.rpc('fix_invoice_items_sequence');

    print('Sequence fixed successfully: $result');
    print('==========================================');
  } catch (e) {
    print('Failed to fix sequence: $e');
    print('You need to run this SQL manually in Supabase:');
    print(
      'SELECT setval(pg_get_serial_sequence(\'invoice_items\', \'id\'), COALESCE((SELECT MAX(id) FROM invoice_items), 1), true);',
    );
  }
}
