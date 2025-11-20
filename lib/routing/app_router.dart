import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/home/company_selection_screen.dart';
import '../presentation/screens/home/entries_home_screen.dart';
import '../presentation/widgets/app_loader.dart';
import '../data/models/profile_model.dart';

/// AppRouter builds a GoRouter based on current auth/profile state.
/// - isLoading: show AppLoader
/// - profile == null: show LoginScreen
/// - profile != null: show CompanySelectionScreen at '/'
class AppRouter {
  static GoRouter router(ProfileModel? profile, bool isLoading) {
    // 1️⃣ Loading state
    if (isLoading) {
      return GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const AppLoader(),
          ),
        ],
      );
    }

    // 2️⃣ Not logged in → show login
    if (profile == null) {
      return GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LoginScreen(),
          ),
        ],
      );
    }

    // 3️⃣ Logged in → show CompanySelectionScreen
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const CompanySelectionScreen(),
        ),

        GoRoute(
          path: '/home',
          builder: (context, state) {
            final qp = state.uri.queryParameters;

            final companyId = qp['companyId'] ?? '';
            final companyName =
                qp['companyName'] != null ? Uri.decodeComponent(qp['companyName']!) : '';
            final timePeriodId = qp['timePeriodId'] ?? '';

            if (companyId.isEmpty || timePeriodId.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text('Home')),
                body: const Center(
                  child: Text('Missing company/time period. Go back and select.'),
                ),
              );
            }

            return EntriesHomeScreen(
              companyId: companyId,
              companyName: companyName,
              timePeriodId: timePeriodId,
            );
          },
        ),
      ],
    );
  }
}
