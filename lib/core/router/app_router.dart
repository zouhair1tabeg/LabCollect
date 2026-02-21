import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/missions/screens/mission_list_screen.dart';
import '../../features/missions/screens/mission_detail_screen.dart';
import '../../features/collection/screens/category_selection_screen.dart';
import '../../features/collection/screens/location_verification_screen.dart';
import '../../features/collection/screens/client_info_screen.dart';
import '../../features/collection/screens/product_info_screen.dart';
import '../../features/collection/screens/sample_details_screen.dart';
import '../../features/collection/screens/analysis_requirements_screen.dart';
import '../../features/collection/screens/documentation_screen.dart';
import '../../features/collection/screens/export_screen.dart';
import '../../features/collection/screens/final_review_screen.dart';
import '../../features/collection/screens/completion_screen.dart';
import '../../features/sync/screens/sync_status_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/missions';
      return null;
    },
    routes: [
      // ── Auth ────────────────────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // ── Missions ────────────────────────────────────
      GoRoute(
        path: '/missions',
        builder: (context, state) => const MissionListScreen(),
      ),
      GoRoute(
        path: '/missions/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MissionDetailScreen(missionId: id);
        },
      ),

      // ── Collection Flow (named segments) ────────────
      GoRoute(
        path: '/collection/:missionId/category',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: CategorySelectionScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/location',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: LocationVerificationScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/client',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: ClientInfoScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/product',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: ProductInfoScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/sample',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: SampleDetailsScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/analysis',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: AnalysisRequirementsScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/documentation',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: DocumentationScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/export',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: ExportScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/review',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: FinalReviewScreen(missionId: id),
          );
        },
      ),
      GoRoute(
        path: '/collection/:missionId/completion',
        pageBuilder: (context, state) {
          final id = state.pathParameters['missionId']!;
          return _slideTransitionPage(
            key: state.pageKey,
            child: CompletionScreen(missionId: id),
          );
        },
      ),

      // ── Keep old step-index route for backward compat ─
      GoRoute(
        path: '/collection/:missionId/:step',
        builder: (context, state) {
          final missionId = state.pathParameters['missionId']!;
          final step = int.parse(state.pathParameters['step']!);
          return _buildCollectionScreen(missionId, step);
        },
      ),

      // ── Sync ────────────────────────────────────────
      GoRoute(
        path: '/sync-status',
        builder: (context, state) => const SyncStatusScreen(),
      ),
    ],
  );
});

/// Named route segments for collection steps
const List<String> collectionRouteSegments = [
  'category',
  'location',
  'client',
  'product',
  'sample',
  'analysis',
  'documentation',
  'export',
  'review',
  'completion',
];

/// Get the route path for a collection step by index
String collectionStepRoute(String missionId, int step) {
  if (step >= 0 && step < collectionRouteSegments.length) {
    return '/collection/$missionId/${collectionRouteSegments[step]}';
  }
  return '/collection/$missionId/category';
}

/// Build the appropriate screen from a step index (backward compat)
Widget _buildCollectionScreen(String missionId, int step) {
  switch (step) {
    case 0:
      return CategorySelectionScreen(missionId: missionId);
    case 1:
      return LocationVerificationScreen(missionId: missionId);
    case 2:
      return ClientInfoScreen(missionId: missionId);
    case 3:
      return ProductInfoScreen(missionId: missionId);
    case 4:
      return SampleDetailsScreen(missionId: missionId);
    case 5:
      return AnalysisRequirementsScreen(missionId: missionId);
    case 6:
      return DocumentationScreen(missionId: missionId);
    case 7:
      return ExportScreen(missionId: missionId);
    case 8:
      return FinalReviewScreen(missionId: missionId);
    case 9:
      return CompletionScreen(missionId: missionId);
    default:
      return CategorySelectionScreen(missionId: missionId);
  }
}

/// Horizontal slide + fade page transition for collection flow
CustomTransitionPage _slideTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation =
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
          );

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
