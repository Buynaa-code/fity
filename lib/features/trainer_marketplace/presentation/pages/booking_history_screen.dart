import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/branding/brand_config.dart';
import '../../domain/entities/booking.dart';
import '../../data/repositories/trainer_repository.dart';
import '../bloc/booking/booking_bloc.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BookingBloc(repository: TrainerRepository())..add(LoadBookings()),
      child: const _BookingHistoryView(),
    );
  }
}

class _BookingHistoryView extends StatefulWidget {
  const _BookingHistoryView();

  @override
  State<_BookingHistoryView> createState() => _BookingHistoryViewState();
}

class _BookingHistoryViewState extends State<_BookingHistoryView>
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
    return Scaffold(
      backgroundColor: BrandColors.background,
      body: SafeArea(
        child: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingError) {
              _showErrorSnackbar(context, state.message, state.type);
            }
            if (state is BookingCancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Захиалга амжилттай цуцлагдлаа'),
                  backgroundColor: BrandColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, state) {
                    if (state is BookingLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: BrandColors.primary),
                      );
                    }

                    if (state is BookingsLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildBookingList(context, state.upcomingBookings, true),
                          _buildBookingList(context, state.pastBookings, false),
                        ],
                      );
                    }

                    if (state is BookingError) {
                      return _buildErrorState(context);
                    }

                    return const Center(
                      child: CircularProgressIndicator(color: BrandColors.primary),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrandColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: BrandShadows.small,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Захиалгын түүх',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: () {
              context.read<BookingBloc>().add(LoadBookings());
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BrandColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: BrandColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: BrandColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: BrandColors.textOnPrimary,
        unselectedLabelColor: BrandColors.textSecondary,
        indicator: BoxDecoration(
          color: BrandColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Удахгүй'),
          Tab(text: 'Өнгөрсөн'),
        ],
      ),
    );
  }

  Widget _buildBookingList(
      BuildContext context, List<Booking> bookings, bool isUpcoming) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: BrandColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUpcoming ? Icons.calendar_today_rounded : Icons.history_rounded,
                size: 48,
                color: BrandColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'Удахгүй болох захиалга байхгүй' : 'Өнгөрсөн захиалга байхгүй',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Дасгалжуулагч захиалаарай'
                  : 'Таны захиалгын түүх энд харагдана',
              style: TextStyle(
                fontSize: 14,
                color: BrandColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingBloc>().add(LoadBookings());
      },
      color: BrandColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final bloc = context.read<BookingBloc>();
          final canCancel = isUpcoming && bloc.canCancelBooking(booking);
          final timeUntilDeadline = bloc.getTimeUntilCancellationDeadline(booking);

          return _BookingCard(
            booking: booking,
            isUpcoming: isUpcoming,
            canCancel: canCancel,
            timeUntilDeadline: timeUntilDeadline,
            onCancel: canCancel ? () => _showCancelDialog(context, booking) : null,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BrandColors.errorSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: BrandColors.error,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Алдаа гарлаа',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<BookingBloc>().add(LoadBookings());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Дахин оролдох'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.primary,
              foregroundColor: BrandColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message, BookingErrorType type) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case BookingErrorType.cancellationDeadlinePassed:
        backgroundColor = BrandColors.warning;
        icon = Icons.timer_off;
        break;
      case BookingErrorType.slotUnavailable:
        backgroundColor = BrandColors.error;
        icon = Icons.event_busy;
        break;
      default:
        backgroundColor = BrandColors.error;
        icon = Icons.error_outline;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Booking booking) {
    final bloc = context.read<BookingBloc>();
    final timeUntilDeadline = bloc.getTimeUntilCancellationDeadline(booking);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BrandColors.errorSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.cancel_outlined, color: BrandColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Захиалга цуцлах'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Та энэ захиалгыг цуцлахдаа итгэлтэй байна уу?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrandColors.warningSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: BrandColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        timeUntilDeadline != null
                            ? 'Цуцлах хугацаа: ${_formatDuration(timeUntilDeadline)} үлдсэн'
                            : 'Цуцлах хугацаа дууссан',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Үгүй',
                style: TextStyle(color: BrandColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<BookingBloc>().add(CancelBooking(booking.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Цуцлах'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} өдөр ${duration.inHours.remainder(24)} цаг';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} цаг ${duration.inMinutes.remainder(60)} минут';
    } else {
      return '${duration.inMinutes} минут';
    }
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isUpcoming;
  final bool canCancel;
  final Duration? timeUntilDeadline;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.booking,
    required this.isUpcoming,
    required this.canCancel,
    this.timeUntilDeadline,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.small,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Trainer Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    booking.trainerImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: BrandColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person,
                          color: BrandColors.primary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Booking Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.trainerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: BrandColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(booking.scheduledAt),
                            style: TextStyle(
                              fontSize: 13,
                              color: BrandColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: BrandColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.durationMinutes} минут',
                            style: TextStyle(
                              fontSize: 13,
                              color: BrandColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status & Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusChip(booking.status),
                    const SizedBox(height: 8),
                    Text(
                      '₮${booking.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Cancellation deadline warning
          if (isUpcoming && timeUntilDeadline != null && timeUntilDeadline!.inHours < 48)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: BrandColors.warningSurface,
                border: Border(
                  top: BorderSide(color: BrandColors.warning.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: BrandColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Цуцлах хугацаа: ${_formatDurationShort(timeUntilDeadline!)} үлдсэн',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrandColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Cancel button
          if (onCancel != null)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: BrandColors.divider),
                ),
              ),
              child: TextButton.icon(
                onPressed: onCancel,
                icon: Icon(Icons.cancel_outlined, size: 18, color: BrandColors.error),
                label: Text(
                  'Цуцлах',
                  style: TextStyle(color: BrandColors.error),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          // Can't cancel indicator
          if (isUpcoming && booking.status != BookingStatus.cancelled && !canCancel)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: BrandColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_clock, size: 14, color: BrandColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Цуцлах хугацаа дууссан',
                    style: TextStyle(
                      fontSize: 12,
                      color: BrandColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;

    switch (status) {
      case BookingStatus.pending:
        color = BrandColors.warning;
        text = 'Хүлээгдэж буй';
        break;
      case BookingStatus.confirmed:
        color = BrandColors.success;
        text = 'Баталгаажсан';
        break;
      case BookingStatus.completed:
        color = BrandColors.info;
        text = 'Дууссан';
        break;
      case BookingStatus.cancelled:
        color = BrandColors.error;
        text = 'Цуцлагдсан';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['1-р', '2-р', '3-р', '4-р', '5-р', '6-р', '7-р', '8-р', '9-р', '10-р', '11-р', '12-р'];
    return '${months[dateTime.month - 1]} сарын ${dateTime.day}, ${dateTime.hour.toString().padLeft(2, '0')}:00';
  }

  String _formatDurationShort(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}ө ${duration.inHours.remainder(24)}ц';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}ц ${duration.inMinutes.remainder(60)}м';
    } else {
      return '${duration.inMinutes}м';
    }
  }
}
