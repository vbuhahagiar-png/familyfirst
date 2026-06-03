import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/error_widget.dart';
import '../widgets/provider_card.dart';

final providersListProvider =
    FutureProvider.family<List<ProviderModel>, String?>((ref, category) async {
  return ref.read(firestoreServiceProvider).getProviders(
        category: category,
        limit: 30,
      );
});

class ProvidersListScreen extends ConsumerStatefulWidget {
  final String? category;

  const ProvidersListScreen({super.key, this.category});

  @override
  ConsumerState<ProvidersListScreen> createState() =>
      _ProvidersListScreenState();
}

class _ProvidersListScreenState extends ConsumerState<ProvidersListScreen> {
  String? _selectedCategory;
  String _sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync =
        ref.watch(providersListProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _selectedCategory != null
              ? Helpers.serviceCategoryNameRu(_selectedCategory!)
              : 'Все специалисты',
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: AppConstants.serviceCategories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChip(
                    label: const Text('Все'),
                    selected: _selectedCategory == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = null),
                    selectedColor: AppColors.primarySurface,
                  );
                }
                final cat = AppConstants.serviceCategories[index - 1];
                return FilterChip(
                  label: Text(
                    '${Helpers.serviceCategoryIcon(cat['id']!)} ${cat['nameRu']}',
                  ),
                  selected: _selectedCategory == cat['id'],
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat['id']),
                  selectedColor: AppColors.primarySurface,
                );
              },
            ),
          ),

          // Sort row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                providersAsync.when(
                  data: (p) => Text(
                    '${p.length} специалистов',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort, size: 16),
                  label: Text(_sortLabel),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: providersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => QyzmetErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(providersListProvider),
              ),
              data: (providers) {
                if (providers.isEmpty) {
                  return const QyzmetEmptyWidget(
                    message: 'Специалисты не найдены',
                    submessage: 'Попробуйте другую категорию',
                    icon: Icons.person_search,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) => ProviderCard(
                    provider: providers[index],
                    onTap: () => context.go(
                      RouteNames.providerDetailPath(providers[index].id),
                    ),
                    isHorizontal: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String get _sortLabel {
    switch (_sortBy) {
      case 'price_asc':
        return 'Цена ↑';
      case 'price_desc':
        return 'Цена ↓';
      case 'reviews':
        return 'Отзывы';
      default:
        return 'Рейтинг';
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _FiltersSheet(),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Сортировка',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          ...['rating', 'price_asc', 'price_desc', 'reviews'].map((sort) {
            final labels = {
              'rating': 'По рейтингу',
              'price_asc': 'Цена: от низкой',
              'price_desc': 'Цена: от высокой',
              'reviews': 'По отзывам',
            };
            return ListTile(
              title: Text(labels[sort] ?? sort),
              trailing: _sortBy == sort
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = sort);
                Navigator.pop(ctx);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet();

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  RangeValues _priceRange = const RangeValues(0, 50000);
  double _minRating = 0;
  bool _verifiedOnly = false;
  bool _availableNow = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Фильтры',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          const Text('Цена за час (₸)'),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 50000,
            divisions: 50,
            labels: RangeLabels(
              '${_priceRange.start.round()} ₸',
              '${_priceRange.end.round()} ₸',
            ),
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 12),
          const Text('Минимальный рейтинг'),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            label: _minRating.toStringAsFixed(1),
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _minRating = v),
          ),
          SwitchListTile(
            title: const Text('Только верифицированные'),
            value: _verifiedOnly,
            onChanged: (v) => setState(() => _verifiedOnly = v),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Доступны сейчас'),
            value: _availableNow,
            onChanged: (v) => setState(() => _availableNow = v),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Сбросить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
