import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends State<ProviderVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _iinController = TextEditingController();
  final _picker = ImagePicker();

  File? _idFrontImage;
  File? _idBackImage;
  File? _selfieImage;

  bool _isLoading = false;
  String? _errorMessage;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _iinController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      switch (type) {
        case 'front':
          _idFrontImage = file;
          break;
        case 'back':
          _idBackImage = file;
          break;
        case 'selfie':
          _selfieImage = file;
          break;
      }
    });
  }

  void _showImageSourceSheet(String type) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadFile(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final task = ref.putFile(file);
    task.snapshotEvents.listen((snap) {
      setState(() {
        _uploadProgress = snap.bytesTransferred / snap.totalBytes;
      });
    });
    await task;
    return await ref.getDownloadURL();
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idFrontImage == null || _idBackImage == null || _selfieImage == null) {
      setState(() {
        _errorMessage = 'Пожалуйста, загрузите все необходимые документы';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _uploadProgress = 0;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final basePath = 'providers/$uid/verification';

      final frontUrl =
          await _uploadFile(_idFrontImage!, '$basePath/id_front.jpg');
      final backUrl =
          await _uploadFile(_idBackImage!, '$basePath/id_back.jpg');
      final selfieUrl =
          await _uploadFile(_selfieImage!, '$basePath/selfie.jpg');

      await FirebaseFirestore.instance.collection('providers').doc(uid).update({
        'iin': _iinController.text.trim(),
        'idDocumentUrl': frontUrl,
        'idDocumentBackUrl': backUrl,
        'selfieUrl': selfieUrl,
        'verificationStatus': 'pending',
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Документы отправлены'),
            content: const Text(
              'Ваши документы отправлены на проверку. '
              'Обычно проверка занимает 1-2 рабочих дня. '
              'Мы уведомим вас о результате.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Понятно'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки. Попробуйте снова.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Верификация документов'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Верификация необходима для начала работы. '
                        'Ваши данные защищены и используются только для подтверждения личности.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // IIN Field
              Text('ИИН', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _iinController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: const InputDecoration(
                  hintText: '000000000000',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Введите ИИН';
                  if (val.length != 12) return 'ИИН должен содержать 12 цифр';
                  if (!RegExp(r'^\d{12}$').hasMatch(val)) {
                    return 'ИИН содержит только цифры';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Document Upload Sections
              Text('Удостоверение личности',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 16),

              _DocumentUploadCard(
                title: 'Лицевая сторона',
                subtitle: 'Сфотографируйте переднюю сторону удостоверения',
                icon: Icons.credit_card,
                image: _idFrontImage,
                onTap: () => _showImageSourceSheet('front'),
              ),
              const SizedBox(height: 12),

              _DocumentUploadCard(
                title: 'Обратная сторона',
                subtitle: 'Сфотографируйте обратную сторону удостоверения',
                icon: Icons.credit_card_outlined,
                image: _idBackImage,
                onTap: () => _showImageSourceSheet('back'),
              ),
              const SizedBox(height: 24),

              Text('Селфи с документом',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 8),
              Text(
                'Сделайте фото: вы держите документ рядом с лицом',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),

              _DocumentUploadCard(
                title: 'Селфи с удостоверением',
                subtitle: 'Держите документ открытым рядом с лицом',
                icon: Icons.selfie,
                image: _selfieImage,
                onTap: () => _showImageSourceSheet('selfie'),
              ),
              const SizedBox(height: 24),

              // Error
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: colorScheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Progress
              if (_isLoading) ...[
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text(
                  'Загрузка: ${(_uploadProgress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submitVerification,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Отправить на проверку',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final File? image;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = image != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 140,
        decoration: BoxDecoration(
          color: hasImage
              ? Colors.transparent
              : colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.4),
            width: hasImage ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image!, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 36,
                      color: colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  Text(title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
