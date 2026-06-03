import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/qyzmet_button.dart';

class OnboardingPage {
  final String title;
  final String description;
  final String emoji;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Забронируйте за 60 секунд',
      description:
          'Выберите специалиста, выберите удобное время и подтвердите заказ. Всё просто и быстро!',
      emoji: '⚡',
      color: Color(0xFF00BCD4),
    ),
    OnboardingPage(
      title: 'Проверенные специалисты',
      description:
          'Все мастера проходят строгую верификацию. Реальные отзывы, рейтинги и гарантия качества.',
      emoji: '✅',
      color: Color(0xFF10B981),
    ),
    OnboardingPage(
      title: 'Безопасная оплата',
      description:
          'Платите картой, Apple Pay или Google Pay. Деньги поступают мастеру только после выполнения работы.',
      emoji: '🔒',
      color: Color(0xFF3B82F6),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Пропустить',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),

            // Indicators and button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  QyzmetButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Начать'
                        : 'Далее',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),

          const SizedBox(height: 48),

          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
