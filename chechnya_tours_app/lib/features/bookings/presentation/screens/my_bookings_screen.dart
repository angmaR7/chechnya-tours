import 'package:flutter/material.dart';

import '../../../../core/storage/token_storage.dart';
import '../../../../core/ui/app_state_view.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../data/models/booking_model.dart';
import '../../data/services/booking_service.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();

  Future<List<BookingModel>>? _futureBookings;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _initBookings();
  }

  Future<void> _initBookings() async {
    final token = await TokenStorage.getAccessToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _hasToken = false;
        _futureBookings = null;
      });
      return;
    }

    setState(() {
      _hasToken = true;
      _futureBookings = _bookingService.getMyBookings();
    });
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

    _initBookings();
  }

  Future<void> _openBookingDetail(BookingModel booking) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(bookingId: booking.id),
      ),
    );

    if (changed == true) {
      _initBookings();
    }
  }

  Future<void> _reload() async {
    await _initBookings();
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day.$month.$year • $hour:$minute';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF2C7A4B);
      case 'cancelled':
        return const Color(0xFFD14C38);
      case 'completed':
        return const Color(0xFF2D6CDF);
      default:
        return const Color(0xFFCC8A1A);
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFFE6F7EA);
      case 'cancelled':
        return const Color(0xFFFFECE8);
      case 'completed':
        return const Color(0xFFEAF1FF);
      default:
        return const Color(0xFFFFF4DF);
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Подтверждено';
      case 'cancelled':
        return 'Отменено';
      case 'completed':
        return 'Завершено';
      default:
        return 'В ожидании';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasToken) {
      return AppStateView.empty(
        icon: Icons.bookmark_border_rounded,
        title: 'Мои бронирования',
        message:
            'Чтобы просматривать свои заявки и управлять ими, войди в аккаунт.',
        actionText: 'Войти',
        onAction: _openLogin,
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<BookingModel>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppStateView.loading(
              title: 'Загружаем бронирования',
              message: 'Подождите немного',
            );
          }

          if (snapshot.hasError) {
            return AppStateView.error(
              title: 'Не удалось загрузить бронирования',
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onAction: _initBookings,
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const AppStateView.empty(
              icon: Icons.bookmark_add_outlined,
              title: 'Бронирований пока нет',
              message: 'Когда ты забронируешь первую экскурсию, она появится здесь.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const _BookingsHeader(),
              const SizedBox(height: 18),
              ...bookings.map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _BookingCard(
                    booking: booking,
                    createdAtText: _formatDate(booking.createdAt),
                    statusText: _statusText(booking.status),
                    statusColor: _statusColor(booking.status),
                    statusBackground: _statusBackground(booking.status),
                    onTap: () => _openBookingDetail(booking),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE9F5EC),
            Color(0xFFF6FBF7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Мои бронирования', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Здесь хранятся все твои заявки на экскурсии, их статусы и детали поездок.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String createdAtText;
  final String statusText;
  final Color statusColor;
  final Color statusBackground;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.createdAtText,
    required this.statusText,
    required this.statusColor,
    required this.statusBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE7EBE5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3EC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.bookmark_outline_rounded),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        booking.excursionTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  booking.placeName,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaChip(
                      icon: Icons.groups_outlined,
                      text: '${booking.peopleCount} чел.',
                    ),
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      text: '${booking.totalPrice} ₽',
                    ),
                    _MetaChip(
                      icon: Icons.schedule_outlined,
                      text: createdAtText,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}