import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {

    await Supabase.initialize(
      url: 'https://zbxobhpmjjvdhotnyjmy.supabase.co', // 🔹 replace with your Supabase URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpieG9iaHBtamp2ZGhvdG55am15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MjI3ODksImV4cCI6MjA3ODA5ODc4OX0.wvEiBGTVewtbHshik036Hbu6P3SN2bBdl1-xpjAdrug',           // 🔹 replace with your anon key
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
