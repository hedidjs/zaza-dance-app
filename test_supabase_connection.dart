import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testSupabaseConnection() async {
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://yyvoavzgapsyycjwirmg.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5dm9hdnpnYXBzeXljandpcm1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyOTgyMzgsImV4cCI6MjA3MDg3NDIzOH0.IU_dW_8K-yuV1grWIWJdetU7jK-b-QDPFYp_m5iFP90',
    );

    final supabase = Supabase.instance.client;
    
    // Test database connection
    final result = await supabase.from('users').select('email').limit(1);
    print('Users table query successful: ${result.length} users found');
    
    // Try to sign in with test user
    try {
      final authResult = await supabase.auth.signInWithPassword(
        email: 'hedidjs@gmail.com',
        password: 'Hedid1234',
      );
      
      if (authResult.user != null) {
        print('✅ Login successful for hedidjs@gmail.com');
        print('User ID: ${authResult.user!.id}');
        print('Email verified: ${authResult.user!.emailConfirmedAt != null}');
      } else {
        print('❌ Login failed - no user returned');
      }
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
    }
    
  } catch (e) {
    print('❌ Connection error: $e');
  }
}

void main() async {
  await testSupabaseConnection();
}
