import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/providers/auth_provider.dart';
import 'presentation/widgets/app_loader.dart';
import 'routing/app_router.dart';

class BhawaniBalesApp extends ConsumerWidget {
  const BhawaniBalesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    final isLoading = authState.loading;

    return MaterialApp.router(
      title: 'Bhawani Bales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ),
      routerConfig: AppRouter.router(profile, isLoading),
    );
  }
}
