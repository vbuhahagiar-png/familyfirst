import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'route_names.dart';
import '../core/services/auth_service.dart';

// Auth screens
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/phone_auth_screen.dart';

// Client screens
import '../features/client/screens/home_screen.dart';
import '../features/client/screens/search_screen.dart';
import '../features/client/screens/providers_list_screen.dart';
import '../features/client/screens/provider_detail_screen.dart';
import '../features/client/screens/booking_screen.dart';
import '../features/client/screens/payment_screen.dart';
import '../features/client/screens/booking_confirmation_screen.dart';
import '../features/client/screens/bookings_history_screen.dart';
import '../features/client/screens/profile_screen.dart';
import '../features/client/screens/loyalty_screen.dart';

// Provider screens
import '../features/provider/screens/provider_home_screen.dart';
import '../features/provider/screens/provider_profile_setup_screen.dart';
import '../features/provider/screens/provider_bookings_screen.dart';
import '../features/provider/screens/provider_calendar_screen.dart';
import '../features/provider/screens/provider_earnings_screen.dart';
import '../features/provider/screens/provider_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isOnAuth = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.onboarding ||
          state.matchedLocation == RouteNames.phoneAuth;
      final isSplash = state.matchedLocation == RouteNames.splash;

      if (isSplash) return null;
      if (!isAuthenticated && !isOnAuth) return RouteNames.login;
      if (isAuthenticated && isOnAuth) return RouteNames.clientHome;

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.phoneAuth,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PhoneAuthScreen(role: extra?['role'] ?? 'client');
        },
      ),

      // Client Shell (with bottom nav)
      ShellRoute(
        builder: (context, state, child) => ClientShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.clientHome,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.bookingsHistory,
            builder: (context, state) => const BookingsHistoryScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Client standalone screens
      GoRoute(
        path: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RouteNames.providersList,
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return ProvidersListScreen(category: category);
        },
      ),
      GoRoute(
        path: RouteNames.providerDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProviderDetailScreen(providerId: id);
        },
      ),
      GoRoute(
        path: RouteNames.booking,
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return BookingScreen(providerId: providerId);
        },
      ),
      GoRoute(
        path: RouteNames.payment,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentScreen(
            bookingId: bookingId,
            totalAmount: (extra?['totalAmount'] ?? 0.0).toDouble(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.bookingConfirmation,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: RouteNames.loyalty,
        builder: (context, state) => const LoyaltyScreen(),
      ),

      // Provider screens
      ShellRoute(
        builder: (context, state, child) => ProviderShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.providerHome,
            builder: (context, state) => const ProviderHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.providerBookings,
            builder: (context, state) => const ProviderBookingsScreen(),
          ),
          GoRoute(
            path: RouteNames.providerCalendar,
            builder: (context, state) => const ProviderCalendarScreen(),
          ),
          GoRoute(
            path: RouteNames.providerEarnings,
            builder: (context, state) => const ProviderEarningsScreen(),
          ),
          GoRoute(
            path: RouteNames.providerProfile,
            builder: (context, state) => const ProviderProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.providerProfileSetup,
        builder: (context, state) => const ProviderProfileSetupScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
          ],
        ),
      ),
    ),
  );
});

class ClientShell extends StatefulWidget {
  final Widget child;
  const ClientShell({super.key, required this.child});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _currentIndex = 0;

  final _routes = [
    RouteNames.clientHome,
    RouteNames.bookingsHistory,
    RouteNames.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Заказы',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class ProviderShell extends StatefulWidget {
  final Widget child;
  const ProviderShell({super.key, required this.child});

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _currentIndex = 0;

  final _routes = [
    RouteNames.providerHome,
    RouteNames.providerBookings,
    RouteNames.providerCalendar,
    RouteNames.providerEarnings,
    RouteNames.providerProfile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Заказы',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Календарь',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Доходы',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
