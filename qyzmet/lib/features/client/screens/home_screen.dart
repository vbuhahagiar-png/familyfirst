import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../navigation/route_names.dart';
import '../widgets/provider_card.dart';
import '../widgets/service_category_card.dart';

final homeProvidersProvider = FutureProvider<List<ProviderModel>>((ref) async {
  return ref.read(firestoreServiceProvider).getProviders(limit: 10);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final providersAsync = ref.watch(homeProvidersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _HomeHeader(
                greeting: userAsync.value?.displayName ?? '',
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: _SearchBar(
                onTap: () => context.go(RouteNames.search),
              ),
            ),

            // Banner
            const SliverToBoxAdapter(child: _PromoBanner()),

            // Categories title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Категории услуг',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.providersList),
                      child: const Text('Все'),
                    ),
                  ],
                ),
              ),
            ),

            // Categories horizontal list
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: AppConstants.serviceCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = AppConstants.serviceCategories[index];
                    return ServiceCategoryCard(
                      id: cat['id']!,
                      label: cat['nameRu']!,
                      emoji: Helpers.serviceCategoryIcon(cat['id']!),
                      isSelected: selectedCategory == cat['id'],
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            selectedCategory == cat['id']
                                ? null
                                : cat['id'];
                        context.go(
                          '${RouteNames.providersList}?category=${cat['id']}',
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Popular providers title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Популярные специалисты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.providersList),
                      child: const Text('Все'),
                    ),
                  ],
                ),
              ),
            ),

            // Providers horizontal list
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: providersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(child: Text('Ошибка: $e')),
                  data: (providers) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => ProviderCard(
                      provider: providers[index],
                      onTap: () => context.go(
                        RouteNames.providerDetailPath(providers[index].id),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // All providers title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Все специалисты',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),

            // Providers vertical list
            providersAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Ошибка: $e')),
              ),
              data: (providers) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProviderCard(
                      provider: providers[index],
                      onTap: () => context.go(
                        RouteNames.providerDetailPath(providers[index].id),
                      ),
                      isHorizontal: true,
                    ),
                    childCount: providers.length,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String greeting;

  const _HomeHeader({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helpers.greetingByTime(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (greeting.isNotEmpty)
                Text(
                  greeting.split(' ').first,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.location_on_outlined,
                    color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.textHint, size: 20),
              SizedBox(width: 12),
              Text(
                'Найти специалиста...',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 15,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006064), Color(0xFF00BCD4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Первая уборка',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Text(
                    'со скидкой 20%!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Узнать больше',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
