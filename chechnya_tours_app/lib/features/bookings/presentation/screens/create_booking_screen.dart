import 'package:flutter/material.dart';

import '../../../../core/ui/app_messages.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../data/services/booking_service.dart';

class CreateBookingScreen extends StatefulWidget {
  final int excursionId;
  final String excursionTitle;
  final String placeName;
  final String dateText;
  final String pricePerPerson;
  final int availablePlaces;

  const CreateBookingScreen({
    super.key,
    required this.excursionId,
    required this.excursionTitle,
    required this.placeName,
    required this.dateText,
    required this.pricePerPerson,
    required this.availablePlaces,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final BookingService _bookingService = BookingService();
  final ProfileService _profileService = ProfileService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool _isLoading = false;
  bool _isPrefilling = true;
  int _peopleCount = 1;

  double get _pricePerPersonValue =>
      double.tryParse(widget.pricePerPerson.replaceAll(',', '.')) ?? 0;

  double get _totalPrice => _pricePerPersonValue * _peopleCount;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _prefillUserData() async {
    try {
      final profile = await _profileService.getMe();
      final fullName = '${profile.firstName} ${profile.lastName}'.trim();

      if (!mounted) return;

      if (_fullNameController.text.trim().isEmpty) {
        _fullNameController.text =
            fullName.isEmpty ? profile.username : fullName;
      }

      if (_phoneController.text.trim().isEmpty) {
        _phoneController.text = profile.phoneNumber;
      }

      if (_emailController.text.trim().isEmpty) {
        _emailController.text = profile.email;
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isPrefilling = false;
        });
      }
    }
  }

  void _increasePeople() {
    if (_peopleCount >= widget.availablePlaces) return;

    setState(() {
      _peopleCount += 1;
    });
  }

  void _decreasePeople() {
    if (_peopleCount <= 1) return;

    setState(() {
      _peopleCount -= 1;
    });
  }

  Future<void> _submit() async {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final comment = _commentController.text.trim();

    if (fullName.isEmpty) {
      AppMessages.error(context, 'Укажи ФИО.');
      return;
    }

    if (phone.isEmpty) {
      AppMessages.error(context, 'Укажи телефон.');
      return;
    }

    if (_peopleCount <= 0) {
      AppMessages.error(context, 'Количество человек должно быть больше 0.');
      return;
    }

    if (_peopleCount > widget.availablePlaces) {
      AppMessages.error(context, 'Недостаточно свободных мест.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _bookingService.createBooking(
        excursionId: widget.excursionId,
        fullName: fullName,
        phoneNumber: phone,
        email: email,
        peopleCount: _peopleCount,
        comment: comment,
      );

      if (!mounted) return;

      AppMessages.success(context, 'Бронирование успешно создано.');
      Navigator.of(context).pop(true);
    } catch (e) {
      AppMessages.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final hasPlaces = widget.availablePlaces > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бронирование'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE7EBE5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.excursionTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.placeName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaChip(
                      icon: Icons.schedule_outlined,
                      text: widget.dateText,
                    ),
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      text: '${widget.pricePerPerson} ₽ / чел.',
                    ),
                    _MetaChip(
                      icon: Icons.event_seat_outlined,
                      text: 'Свободно: ${widget.availablePlaces}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isPrefilling)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5ED),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Подставляем данные профиля...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          TextField(
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'ФИО',
              hintText: 'Введите полное имя',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Телефон',
              hintText: '+7...',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'example@mail.com',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE7EBE5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Количество человек',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _CountButton(
                      icon: Icons.remove,
                      onTap: _decreasePeople,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F5F1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$_peopleCount',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CountButton(
                      icon: Icons.add,
                      onTap: hasPlaces ? _increasePeople : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Можно выбрать до ${widget.availablePlaces} человек.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              hintText: 'Например, нужны места рядом',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5ED),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Итоговая стоимость',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatMoney(_totalPrice)} ₽',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: (_isLoading || !hasPlaces) ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Отправить бронь'),
            ),
          ),
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
          Icon(icon, size: 17),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CountButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? const Color(0xFFE3E7E1) : const Color(0xFFEAF3EC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon),
        ),
      ),
    );
  }
}