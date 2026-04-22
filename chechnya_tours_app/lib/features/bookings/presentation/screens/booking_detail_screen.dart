import 'package:flutter/material.dart';

import '../../../../core/ui/app_dialogs.dart';
import '../../../../core/ui/app_messages.dart';
import '../../data/models/booking_model.dart';
import '../../data/services/booking_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  late Future<BookingModel> _futureBooking;

  @override
  void initState() {
    super.initState();
    _futureBooking = _bookingService.getBookingDetail(widget.bookingId);
  }

  Future<void> _reload() async {
    setState(() {
      _futureBooking = _bookingService.getBookingDetail(widget.bookingId);
    });
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await AppDialogs.confirm(
      context: context,
      title: 'Отмена бронирования',
      message: 'Вы уверены, что хотите отменить это бронирование?',
      confirmText: 'Отменить бронь',
      cancelText: 'Назад',
      isDanger: true,
    );

    if (!confirmed) return;

    try {
      await _bookingService.cancelBooking(booking.id);

      if (!mounted) return;

      AppMessages.success(context, 'Бронирование отменено.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      AppMessages.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали бронирования'),
      ),
      body: FutureBuilder<BookingModel>(
        future: _futureBooking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _reload,
            );
          }

          final booking = snapshot.data!;
          final statusColor = _statusColor(booking.status);
          final statusBg = _statusBackground(booking.status);

          final canCancel =
              booking.status != 'cancelled' && booking.status != 'completed';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
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
                    Text(
                      booking.excursionTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.placeName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusText(booking.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Краткая информация',
                child: Wrap(
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
                      text: _formatDate(booking.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Данные заказчика',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoLine(
                      icon: Icons.person_outline,
                      text: 'ФИО: ${booking.fullName}',
                    ),
                    _InfoLine(
                      icon: Icons.phone_outlined,
                      text: 'Телефон: ${booking.phoneNumber}',
                    ),
                    _InfoLine(
                      icon: Icons.email_outlined,
                      text: 'Email: ${booking.email.isEmpty ? 'Не указан' : booking.email}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Информация о брони',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoLine(
                      icon: Icons.confirmation_number_outlined,
                      text: 'Номер бронирования: ${booking.id}',
                    ),
                    _InfoLine(
                      icon: Icons.groups_outlined,
                      text: 'Количество человек: ${booking.peopleCount}',
                    ),
                    _InfoLine(
                      icon: Icons.payments_outlined,
                      text: 'Стоимость: ${booking.totalPrice} ₽',
                    ),
                    _InfoLine(
                      icon: Icons.event_note_outlined,
                      text: 'Создано: ${_formatDate(booking.createdAt)}',
                    ),
                    _InfoLine(
                      icon: Icons.update_outlined,
                      text: 'Обновлено: ${_formatDate(booking.updatedAt)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Комментарий',
                child: Text(
                  booking.comment.isEmpty
                      ? 'Комментарий отсутствует.'
                      : booking.comment,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: canCancel ? () => _cancelBooking(booking) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canCancel ? const Color(0xFFD14C38) : null,
                    disabledBackgroundColor: const Color(0xFFDCE4DC),
                  ),
                  child: Text(
                    canCancel
                        ? 'Отменить бронирование'
                        : 'Бронирование недоступно для отмены',
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
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

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5F6B64)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE7EBE5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 36),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}