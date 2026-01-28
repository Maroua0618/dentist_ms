-- Run this SQL in your Supabase SQL Editor to fix the sequence issue
-- This syncs the auto-increment sequence with the actual maximum ID in the table

select setval(
   pg_get_serial_sequence(
      'invoice_items',
      'id'
   ),
   coalesce(
      (
         select max(id)
           from invoice_items
      ),
      1
   ),
   true
);

-- Verify the fix worked
-- Check the sequence's last value
select last_value as current_sequence_value,
       (
          select max(id)
            from invoice_items
       ) as max_id_in_table
  from invoice_items_id_seq;

-- The sequence value should match or be higher than the max ID
-- Now try to add an invoice item - it should work!