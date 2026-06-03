import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../navigation/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.prefOnboardingDone) ?? false;
    final authService = ref.read(authServiceProvider);

    if (!mounted) return;

    if (authService.currentUser != null) {
      final user = await authService.getCurrentUserModel();
      if (user != null && mounted) {
        if (user.isProvider) {
          context.go(RouteNames.providerHome);
        } else {
          context.go(RouteNames.clientHome);
        }
      } else {
        context.go(RouteNames.login);
      }
    } else if (!onboardingDone) {
      context.go(RouteNames.onboarding);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) => Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Q',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App name and slogan
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) => SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Qyzmet',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.appSlogan,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Inter',
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Loading indicator
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) => Opacity(
                    opacity: _textOpacity.value,
                    child: child,
                  ),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
