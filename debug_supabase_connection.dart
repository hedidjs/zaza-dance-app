// Debug script to test Supabase connection and operations
// Run with: dart debug_supabase_connection.dart

import 'dart:io';

void main() async {
  final supabaseUrl = 'https://yyvoavzgapsyycjwirmg.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5dm9hdnpnYXBzeXljandpcm1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyOTgyMzgsImV4cCI6MjA3MDg3NDIzOH0.IU_dW_8K-yuV1grWIWJdetU7jK-b-QDPFYp_m5iFP90';
  
  print('🔍 Testing Supabase Connection and Operations');
  print('===============================================');
  
  // Test 1: Check if we can read users table (anonymous access)
  print('\n1. Testing anonymous read access to users table...');
  try {
    final result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/users?select=id,display_name,email&limit=3',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Users table read: ${result.stdout}');
    } else {
      print('❌ Users table read failed: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Error reading users: $e');
  }

  // Test 2: Check if we can read gallery_items table
  print('\n2. Testing anonymous read access to gallery_items table...');
  try {
    final result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/gallery_items?select=id,title_he&limit=3',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Gallery items read: ${result.stdout}');
    } else {
      print('❌ Gallery items read failed: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Error reading gallery items: $e');
  }

  // Test 3: Check if we can read updates table
  print('\n3. Testing anonymous read access to updates table...');
  try {
    final result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/updates?select=id,title_he&limit=3',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Updates read: ${result.stdout}');
    } else {
      print('❌ Updates read failed: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Error reading updates: $e');
  }

  // Test 4: Test login with hedidjs@gmail.com (if password is available)
  print('\n4. Testing login capability...');
  try {
    final result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/auth/v1/token?grant_type=password',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', '{"email":"hedidjs@gmail.com","password":"test123"}'  // Common test password
    ]);
    
    if (result.exitCode == 0 && !result.stdout.contains('error')) {
      print('✅ Login test result: ${result.stdout}');
    } else {
      print('⚠️  Login test (expected to fail without correct password): ${result.stderr}');
    }
  } catch (e) {
    print('⚠️  Login test error (expected): $e');
  }

  // Test 5: Try to create a gallery item (should fail for anonymous users)
  print('\n5. Testing anonymous write access (should fail)...');
  try {
    final result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/gallery_items',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', '{"title_he":"Test Title","media_url":"http://test.com","media_type":"image","category":"test"}'
    ]);
    
    if (result.exitCode == 0) {
      if (result.stdout.contains('error') || result.stdout.contains('permission denied')) {
        print('✅ Anonymous write correctly blocked: ${result.stdout}');
      } else {
        print('⚠️  Anonymous write unexpectedly succeeded: ${result.stdout}');
      }
    } else {
      print('✅ Anonymous write correctly blocked: ${result.stderr}');
    }
  } catch (e) {
    print('✅ Anonymous write correctly blocked: $e');
  }

  print('\n===============================================');
  print('🔍 Debug Summary:');
  print('1. Check if anonymous read access works for viewing content');
  print('2. Verify that write operations are properly blocked for anonymous users');
  print('3. User needs to login first before performing write operations');
  print('===============================================');
}