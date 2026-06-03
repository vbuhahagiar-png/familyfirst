import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../navigation/route_names.dart';
import '../widgets/provider_card.dart';
import '../widgets/service_category_card.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchResultsProvider =
    FutureProvider.family<List<ProviderModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return ref.read(firestoreServiceProvider).searchProviders(query);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _selectedCategory = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Найти специалиста...',
            hintStyle: const TextStyle(color: AppColors.textHint),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (v) =>
              ref.read(searchQueryProvider.notifier).state = v,
        ),
        actions: [
          if (query.isNotEmpty)
            TextButton(
              onPressed: () => context.go(
                '${RouteNames.providersList}?q=$query',
              ),
              child: const Text('Поиск'),
            ),
        ],
      ),
      body: query.isEmpty
          ? _SearchSuggestions(
              onCategorySelect: (id) {
                setState(() => _selectedCategory = id);
                context.go('${RouteNames.providersList}?category=$id');
              },
            )
          : _SearchResults(query: query),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final void Function(String) onCategorySelect;

  const _SearchSuggestions({required this.onCategorySelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Категории',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: AppConstants.serviceCategories.length,
            itemBuilder: (context, index) {
              final cat = AppConstants.serviceCategories[index];
              return ServiceCategoryCard(
                id: cat['id']!,
                label: cat['nameRu']!,
                emoji: Helpers.serviceCategoryIcon(cat['id']!),
                onTap: () => onCategorySelect(cat['id']!),
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Популярные запросы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Уборка квартиры',
              'Няня на день',
              'Сантехник',
              'Мастер на час',
              'Переезд',
              'Электрик',
            ]
                .map((query) => ActionChip(
                      label: Text(query),
                      onPressed: () {},
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider(query));

    return resultsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(child: Text('Ошибка: $e')),
      data: (providers) {
        if (providers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppColors.textHint),
                SizedBox(height: 16),
                Text(
                  'Ничего не найдено',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Попробуйте другой запрос',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
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
    );
  }
}
