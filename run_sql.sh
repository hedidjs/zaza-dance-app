#!/bin/bash
echo "Running SQL to create missing tables..."
supabase db reset --db-url $(supabase status | grep "DB URL" | awk '{print $3}') --file create_missing_tables_cli.sql
echo "Done!"
