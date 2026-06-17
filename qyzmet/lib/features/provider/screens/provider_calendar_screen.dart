import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_colors.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import 'provider_home_screen.dart';

class ProviderCalendarScreen extends ConsumerStatefulWidget {
  const ProviderCalendarScreen({super.key});

  @override
  ConsumerState<ProviderCalendarScreen> createState() =>
      _ProviderCalendarScreenState();
}

class _ProviderCalendarScreenState
    extends ConsumerState<ProviderCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final providerAsync = ref.watch(providerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Календарь'),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Calendar
          _CalendarWidget(
            selectedDate: _selectedDate,
            currentMonth: _currentMonth,
            onDateSelected: (d) => setState(() => _selectedDate = d),
            onMonthChanged: (m) => setState(() => _currentMonth = m),
          ),

          const Divider(height: 1),

          // Selected day bookings
          Expanded(
            child: providerAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, __) => const SizedBox(),
              data: (provider) => provider != null
                  ? _DayBookings(
                      providerId: provider.id,
                      date: _selectedDate,
                    )
                  : const Center(child: Text('Профиль не найден')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime currentMonth;
  final void Function(DateTime) onDateSelected;
  final void Function(DateTime) onMonthChanged;

  const _CalendarWidget({
    required this.selectedDate,
    required this.currentMonth,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + lastDay.day;
    final rows = (totalCells / 7).ceil();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onMonthChanged(
                  DateTime(currentMonth.year, currentMonth.month - 1),
                ),
              ),
              Text(
                _monthName(currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onMonthChanged(
                  DateTime(currentMonth.year, currentMonth.month + 1),
                ),
              ),
            ],
          ),

          // Day names
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          ...List.generate(rows, (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayNumber = cellIndex - startOffset + 1;

                if (dayNumber < 1 || dayNumber > lastDay.day) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(
                    currentMonth.year, currentMonth.month, dayNumber);
                final isToday = _isToday(date);
                final isSelected = _isSameDay(date, selectedDate);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primarySurface
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.primary)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(DateTime date) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _DayBookings extends ConsumerWidget {
  final String providerId;
  final DateTime date;

  const _DayBookings({required this.providerId, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter bookings by selected date
    return StreamBuilder<List<BookingModel>>(
      stream: ref
          .read(firestoreServiceProvider)
          .getProviderBookings(providerId),
      builder: (context, snapshot) {
        final allBookings = snapshot.data ?? [];
        final dayBookings = allBookings.where((b) {
          return b.date.year == date.year &&
              b.date.month == date.month &&
              b.date.day == date.day;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Formatters.date(date),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (dayBookings.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Свободный день',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayBookings.length,
                  itemBuilder: (context, index) {
                    final booking = dayBookings[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: Helpers.bookingStatusColor(booking.status),
                            width: 3,
                          ),
                          top: BorderSide(
                            color: Helpers.bookingStatusColor(booking.status)
                                .withOpacity(0.3),
                          ),
                          right: BorderSide(
                            color: Helpers.bookingStatusColor(booking.status)
                                .withOpacity(0.3),
                          ),
                          bottom: BorderSide(
                            color: Helpers.bookingStatusColor(booking.status)
                                .withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            booking.startTime,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.clientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${booking.serviceName} · ${Formatters.duration(booking.durationHours)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
