import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../widgets/booking_card.dart';
import '../widgets/star_rating.dart';
import '../../shared/widgets/qyzmet_text_field.dart';

final clientBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) async* {
  final user = await ref.read(authServiceProvider).getCurrentUserModel();
  if (user == null) {
    yield [];
    return;
  }
  yield* ref.read(firestoreServiceProvider).getClientBookings(user.uid);
});

class BookingsHistoryScreen extends ConsumerStatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  ConsumerState<BookingsHistoryScreen> createState() =>
      _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState
    extends ConsumerState<BookingsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(clientBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Мои заказы'),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Активные'),
            Tab(text: 'История'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => QyzmetErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(clientBookingsProvider),
        ),
        data: (bookings) {
          final upcoming =
              bookings.where((b) => b.isUpcoming).toList();
          final past = bookings.where((b) => b.isPast).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingsList(
                bookings: upcoming,
                emptyMessage: 'Нет активных заказов',
                emptySubMessage:
                    'Найдите специалиста и оформите заказ',
              ),
              _BookingsList(
                bookings: past,
                emptyMessage: 'История пуста',
                emptySubMessage: 'Здесь будут ваши прошлые заказы',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;
  final String emptySubMessage;

  const _BookingsList({
    required this.bookings,
    required this.emptyMessage,
    required this.emptySubMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return QyzmetEmptyWidget(
        message: emptyMessage,
        submessage: emptySubMessage,
        icon: Icons.calendar_today_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          booking: booking,
          onCancel: booking.canBeCancelled
              ? () => _cancelBooking(context, ref, booking)
              : null,
          onReview: booking.status == BookingStatus.completed
              ? () => _showReviewDialog(context, ref, booking)
              : null,
        );
      },
    );
  }

  Future<void> _cancelBooking(
      BuildContext context, WidgetRef ref, BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отменить заказ?'),
        content: const Text(
            'Вы уверены, что хотите отменить этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(firestoreServiceProvider).updateBookingStatus(
            booking.id,
            BookingStatus.cancelled,
          );
    }
  }

  Future<void> _showReviewDialog(
      BuildContext context, WidgetRef ref, BookingModel booking) async {
    double rating = 5.0;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Оставить отзыв'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Оцените работу ${booking.providerName}'),
              const SizedBox(height: 16),
              InteractiveStarRating(
                initialRating: rating,
                onRatingChanged: (r) => setState(() => rating = r),
              ),
              const SizedBox(height: 16),
              QyzmetTextField(
                label: 'Комментарий',
                controller: commentController,
                maxLines: 3,
                hint: 'Ваш отзыв...',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}
