import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../navigation/route_names.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/qyzmet_app_bar.dart';
import '../../shared/widgets/qyzmet_button.dart';
import '../../shared/widgets/qyzmet_text_field.dart';

class ProviderProfileSetupScreen extends ConsumerStatefulWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  ConsumerState<ProviderProfileSetupScreen> createState() =>
      _ProviderProfileSetupScreenState();
}

class _ProviderProfileSetupScreenState
    extends ConsumerState<ProviderProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  String _gender = 'female';
  Set<String> _selectedCategories = {};
  String _selectedDistrict = AppConstants.astanaDistricts.first;

  @override
  void initState() {
    super.initState();
    _prefillName();
  }

  Future<void> _prefillName() async {
    final user = await ref.read(authServiceProvider).getCurrentUserModel();
    if (mounted && user != null) {
      _nameController.text = user.displayName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Выберите хотя бы одну категорию услуг')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authServiceProvider).getCurrentUserModel();
      if (user == null) throw Exception('Не авторизован');

      final provider = ProviderModel(
        id: '',
        userId: user.uid,
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        serviceCategories: _selectedCategories.toList(),
        pricePerHour: double.parse(_priceController.text.trim()),
        gender: _gender,
        availability: ProviderModel.defaultAvailability(),
        location: ProviderLocation(
          city: AppConstants.defaultCity,
          district: _selectedDistrict,
        ),
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createProvider(provider);

      if (mounted) {
        context.go(RouteNames.providerHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const QyzmetAppBar(
          title: 'Настройка профиля',
          showBackButton: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Заполните профиль, чтобы начать принимать заказы.',
                          style: TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const _SectionTitle('Основная информация'),

                const SizedBox(height: 12),

                QyzmetTextField(
                  label: 'Полное имя',
                  controller: _nameController,
                  validator: Validators.name,
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Gender selector
                const Text(
                  'Пол',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'Женщина',
                        emoji: '👩',
                        value: 'female',
                        groupValue: _gender,
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        label: 'Мужчина',
                        emoji: '👨',
                        value: 'male',
                        groupValue: _gender,
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                QyzmetTextField(
                  label: 'О себе',
                  controller: _bioController,
                  maxLines: 4,
                  validator: Validators.bio,
                  hint: 'Опыт, квалификация, почему выбрать вас...',
                ),

                const SizedBox(height: 24),

                const _SectionTitle('Услуги и цена'),

                const SizedBox(height: 12),

                // Categories
                const Text(
                  'Категории услуг',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.serviceCategories.map((cat) {
                    final id = cat['id']!;
                    final isSelected = _selectedCategories.contains(id);
                    return FilterChip(
                      label: Text(
                        '${Helpers.serviceCategoryIcon(id)} ${cat['nameRu']}',
                      ),
                      selected: isSelected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedCategories.add(id);
                          } else {
                            _selectedCategories.remove(id);
                          }
                        });
                      },
                      selectedColor: AppColors.primarySurface,
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                QyzmetTextField(
                  label: 'Цена за час (₸)',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: Validators.price,
                  prefixIcon: const Icon(Icons.attach_money, size: 20),
                  hint: 'Например: 5000',
                ),

                const SizedBox(height: 24),

                const _SectionTitle('Местоположение'),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: 'Район Астаны',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: AppConstants.astanaDistricts
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedDistrict = v ?? AppConstants.astanaDistricts.first),
                ),

                const SizedBox(height: 32),

                QyzmetButton(
                  label: 'Создать профиль',
                  onPressed: _save,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String emoji;
  final String value;
  final String groupValue;
  final void Function(String) onChanged;

  const _GenderOption({
    required this.label,
    required this.emoji,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
