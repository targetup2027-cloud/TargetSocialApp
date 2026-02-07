import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/motion_system.dart';
import '../core/navigation/navigation_transitions.dart';
import '../features/auth/presentation/authed_landing_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_overlay_screen.dart';
import '../features/onboarding/presentation/logo_assembly_screen.dart';
import '../features/onboarding/presentation/welcome_onboarding_screen.dart';
import '../features/onboarding/presentation/orbital_home_onboarding_screen.dart';
import '../features/onboarding/presentation/ai_growth_onboarding_screen.dart';
import '../features/ai_tools/presentation/agent_details_screen.dart';
import '../features/ai_tools/presentation/subscription_payment_screen.dart';
import '../features/discover/presentation/discover_screen.dart';
import '../features/social/presentation/social_screen.dart';
import '../features/messages/presentation/messages_screen.dart';
import '../features/business/presentation/business_screen.dart';
import '../features/ai_hub/presentation/ai_hub_screen.dart';
import '../features/ai_tools/presentation/ai_tools_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shop/presentation/shop_screen.dart';
import '../features/shop/presentation/checkout_screen.dart';
import '../features/shop/presentation/payment_success_screen.dart';
import '../features/business/presentation/business_store_profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/profile/presentation/trust_info_screen.dart';
import '../features/auth/application/auth_guard.dart';
import '../features/social/presentation/create_post_screen.dart';
import '../features/social/domain/entities/post.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/business/presentation/create_business_screen.dart';
import '../features/business/presentation/business_plans_screen.dart';
import '../features/business/presentation/edit_business_screen.dart';
import '../features/business/domain/entities/business.dart';
import '../features/profile/presentation/visitor_profile_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';

const _publicRoutes = <String>{
  '/',
  '/login',
  '/signup',
  '/onboarding',
  '/onboarding-overlay',
  '/logo-assembly',
  '/welcome-onboarding',
  '/orbital-home-onboarding',
  '/ai-growth-onboarding',
};

CustomTransitionPage<T> _buildMotionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return NavigationTransitions.fadeSlideUp(
    key: key,
    child: child,
    slideOffset: 0.02,
  );
}

CustomTransitionPage<T> _buildSharedAxisPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return NavigationTransitions.sharedAxis(
    key: key,
    child: child,
    direction: SharedAxisDirection.horizontal,
  );
}

CustomTransitionPage<T> _buildFadeThroughPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return NavigationTransitions.fadeThrough(
    key: key,
    child: child,
  );
}

CustomTransitionPage<T> _buildContainerTransformPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return NavigationTransitions.containerTransform(
    key: key,
    child: child,
  );
}

CustomTransitionPage<T> _buildSlideFromBottomPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return NavigationTransitions.slideFromBottom(
    key: key,
    child: child,
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(ref.read(authGuardProvider.notifier).stream),
    redirect: (context, state) {
      final authGuard = ref.read(authGuardProvider);
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);
      
      if (authGuard == AuthGuardStatus.unknown) {
        return null;
      }
      
      final isAuthenticated = authGuard == AuthGuardStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }
      
      if (isAuthenticated && isAuthRoute) {
        return '/app';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: '/app',
        name: 'app',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const AuthedLandingScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const OnboardingOverlayScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding-overlay',
        name: 'onboarding-overlay',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const OnboardingOverlayScreen(),
        ),
      ),
      GoRoute(
        path: '/logo-assembly',
        name: 'logo-assembly',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const LogoAssemblyScreen(),
        ),
      ),
      GoRoute(
        path: '/welcome-onboarding',
        name: 'welcome-onboarding',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const WelcomeOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/orbital-home-onboarding',
        name: 'orbital-home-onboarding',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const OrbitalHomeOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/agent-details',
        name: 'agent-details',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return _buildMotionPage(
            key: state.pageKey,
            child: AgentDetailsScreen(
              title: data['title'],
              description: data['description'],
              price: data['price'],
              icon: data['icon'],
              iconColor: data['iconColor'],
              badge: data['badge'],
              badgeColor: data['badgeColor'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/ai-growth-onboarding',
        name: 'ai-growth-onboarding',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const AIGrowthOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/subscription-payment',
        name: 'subscription-payment',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return _buildMotionPage(
            key: state.pageKey,
            child: SubscriptionPaymentScreen(
              planName: data['planName'],
              planPrice: data['planPrice'],
              planLimit: data['planLimit'],
              planFeatures: data['planFeatures'],
              agentName: data['agentName'],
              successButtonText: data['successButtonText'],
              successRoute: data['successRoute'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/discover',
        name: 'discover',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const DiscoverScreen(),
        ),
      ),
      GoRoute(
        path: '/social',
        name: 'social',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const SocialScreen(),
        ),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const MessagesScreen(),
        ),
      ),
      GoRoute(
        path: '/business',
        name: 'business',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const BusinessScreen(),
        ),
      ),
      GoRoute(
        path: '/ai-hub',
        name: 'ai-hub',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const AIHubScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/shop',
        name: 'shop',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const ShopScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/ai-tools',
        name: 'ai-tools',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const AIToolsScreen(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: '/payment-success',
        name: 'payment-success',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const PaymentSuccessScreen(),
        ),
      ),
      GoRoute(
        path: '/store/:storeId',
        name: 'store',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: BusinessStoreProfileScreen(
            storeId: state.pathParameters['storeId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/trust-info',
        name: 'trust-info',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const TrustInfoScreen(),
        ),
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const CreatePostScreen(),
        ),
      ),
      GoRoute(
        path: '/edit-post',
        name: 'edit-post',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: CreatePostScreen(editPost: state.extra as Post?),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/create-business',
        name: 'create-business',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const CreateBusinessScreen(),
        ),
      ),
      GoRoute(
        path: '/business-plans',
        name: 'business-plans',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: const BusinessPlansScreen(),
        ),
      ),
      GoRoute(
        path: '/edit-business',
        name: 'edit-business',
        pageBuilder: (context, state) {
          final business = state.extra as Business;
          return _buildMotionPage(
            key: state.pageKey,
            child: EditBusinessScreen(business: business),
          );
        },
      ),
      GoRoute(
        path: '/user/:userId',
        name: 'visitor-profile',
        pageBuilder: (context, state) => _buildMotionPage(
          key: state.pageKey,
          child: VisitorProfileScreen(
            userId: state.pathParameters['userId'] ?? '',
          ),
        ),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
