import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_client.dart';
import 'app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (from core/config)
  await SupabaseConfig.init();

  // Wrap entire app in ProviderScope for Riverpod
  runApp(const ProviderScope(child: BhawaniBalesApp()));
}
