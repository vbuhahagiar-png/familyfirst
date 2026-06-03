import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/models/review_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/qyzmet_button.dart';
import '../widgets/review_card.dart';
import '../widgets/star_rating.dart';

final providerDetailProvider =
    StreamProvider.family<ProviderModel?, String>((ref, id) {
  return ref.read(firestoreServiceProvider).getProviderStream(id);
});

final providerReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, providerId) {
  return ref.read(firestoreServiceProvider).getProviderReviews(providerId);
});

class ProviderDetailScreen extends ConsumerWidget {
  final String providerId;

  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(providerDetailProvider(providerId));
    final reviewsAsync = ref.watch(providerReviewsProvider(providerId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: providerAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Ошибка: $e')),
        ),
        data: (provider) {
          if (provider == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Специалист не найден')),
            );
          }
          return _ProviderDetailBody(
            provider: provider,
            reviewsAsync: reviewsAsync,
          );
        },
      ),
    );
  }
}

class _ProviderDetailBody extends StatefulWidget {
  final ProviderModel provider;
  final AsyncValue<List<ReviewModel>> reviewsAsync;

  const _ProviderDetailBody({
    required this.provider,
    required this.reviewsAsync,
  });

  @override
  State<_ProviderDetailBody> createState() => _ProviderDetailBodyState();
}

class _ProviderDetailBodyState extends State<_ProviderDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProviderHero(provider: provider),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, size: 18),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: _ProviderInfoCard(provider: provider),
          ),

          SliverPersistentHeader(
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                tabs: const [
                  Tab(text: 'О себе'),
                  Tab(text: 'Отзывы'),
                  Tab(text: 'Доступность'),
                ],
              ),
            ),
            pinned: true,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _AboutTab(provider: provider),
            _ReviewsTab(reviewsAsync: widget.reviewsAsync),
            _AvailabilityTab(provider: provider),
          ],
        ),
      ),
      bottomNavigationBar: _BookingBar(provider: provider),
    );
  }
}

class _ProviderHero extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderHero({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        provider.photoURL.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: provider.photoURL,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.primarySurface,
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
        // Gradient overlay
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x88000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderInfoCard extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderInfoCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          provider.displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.serviceCategories
                          .map((c) => Helpers.serviceCategoryNameRu(c))
                          .join(', '),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (provider.isAvailableNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: AppColors.success,
                            size: 8,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Доступен',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _StatBadge(
                icon: Icons.star,
                iconColor: AppColors.starFilled,
                label: provider.formattedRating,
                subLabel: '${provider.totalReviews} отзывов',
              ),
              const SizedBox(width: 16),
              _StatBadge(
                icon: Icons.work,
                iconColor: AppColors.primary,
                label: '${provider.totalBookings}',
                subLabel: 'заказов',
              ),
              const SizedBox(width: 16),
              _StatBadge(
                icon: Icons.timer,
                iconColor: AppColors.info,
                label: Formatters.responseTime(provider.responseTime),
                subLabel: 'ответ',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${provider.location.city}, ${provider.location.district}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subLabel;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              subLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  final ProviderModel provider;

  const _AboutTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О себе',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.bio.isNotEmpty
                ? provider.bio
                : 'Специалист пока не добавил описание.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Услуги',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.serviceCategories.map((cat) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Helpers.serviceCategoryIcon(cat),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Helpers.serviceCategoryNameRu(cat),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          if (provider.photoGallery.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Фото работ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.photoGallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: provider.photoGallery[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final AsyncValue<List<ReviewModel>> reviewsAsync;

  const _ReviewsTab({required this.reviewsAsync});

  @override
  Widget build(BuildContext context) {
    return reviewsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Ошибка: $e')),
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 48, color: AppColors.textHint),
                SizedBox(height: 16),
                Text('Пока нет отзывов'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reviews.length,
          itemBuilder: (context, index) => ReviewCard(review: reviews[index]),
        );
      },
    );
  }
}

class _AvailabilityTab extends StatelessWidget {
  final ProviderModel provider;

  const _AvailabilityTab({required this.provider});

  static const _days = [
    ('monday', 'Понедельник'),
    ('tuesday', 'Вторник'),
    ('wednesday', 'Среда'),
    ('thursday', 'Четверг'),
    ('friday', 'Пятница'),
    ('saturday', 'Суббота'),
    ('sunday', 'Воскресенье'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: _days.map((day) {
        final avail = provider.availability[day.$1];
        final isEnabled = avail?.enabled ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  day.$2,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isEnabled
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ),
              if (isEnabled) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${avail!.start} – ${avail.end}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else
                const Text(
                  'Недоступен',
                  style: TextStyle(color: AppColors.textHint),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _BookingBar extends StatelessWidget {
  final ProviderModel provider;

  const _BookingBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.formattedPrice,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'Inter',
                ),
              ),
              const Text(
                'за час',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: QyzmetButton(
              label: 'Забронировать',
              onPressed: () =>
                  context.go(RouteNames.bookingPath(provider.id)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
