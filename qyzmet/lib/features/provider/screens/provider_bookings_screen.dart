import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../shared/widgets/error_widget.dart';
import 'provider_home_screen.dart';

final providerAllBookingsProvider =
    StreamProvider<List<BookingModel>>((ref) async* {
  final provider = await ref.read(providerProfileProvider.future);
  if (provider == null) {
    yield [];
    return;
  }
  yield* ref.read(firestoreServiceProvider).getProviderBookings(provider.id);
});

class ProviderBookingsScreen extends ConsumerStatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  ConsumerState<ProviderBookingsScreen> createState() =>
      _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState
    extends ConsumerState<ProviderBookingsScreen>
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
    final bookingsAsync = ref.watch(providerAllBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Заказы'),
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
            Tab(text: 'Завершённые'),
            Tab(text: 'Отменённые'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => QyzmetErrorWidget(message: e.toString()),
        data: (bookings) {
          final active = bookings
              .where((b) =>
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.inProgress)
              .toList();
          final completed = bookings
              .where((b) => b.status == BookingStatus.completed)
              .toList();
          final cancelled = bookings
              .where((b) =>
                  b.status == BookingStatus.cancelled ||
                  b.status == BookingStatus.refunded)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingList(bookings: active),
              _BookingList(bookings: completed),
              _BookingList(bookings: cancelled),
            ],
          );
        },
      ),
    );
  }
}

class _BookingList extends ConsumerWidget {
  final List<BookingModel> bookings;

  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return const QyzmetEmptyWidget(
        message: 'Нет заказов',
        icon: Icons.list_alt_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _ProviderBookingItem(booking: booking, ref: ref);
      },
    );
  }
}

class _ProviderBookingItem extends StatelessWidget {
  final BookingModel booking;
  final WidgetRef ref;

  const _ProviderBookingItem({
    required this.booking,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  fontFamily: 'Inter',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Helpers.bookingStatusColor(booking.status)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.labelRu,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Helpers.bookingStatusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.serviceName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${Formatters.shortDate(booking.date)} · ${booking.startTime}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                Formatters.currency(booking.providerAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 15,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),

          if (booking.status == BookingStatus.inProgress) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markCompleted(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Отметить выполненным'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _markCompleted(BuildContext context) async {
    await ref.read(firestoreServiceProvider).updateBookingStatus(
          booking.id,
          BookingStatus.completed,
        );
  }
}
