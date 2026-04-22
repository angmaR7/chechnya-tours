import 'package:flutter/material.dart';

import '../../../../core/storage/token_storage.dart';
import '../../../../core/ui/app_messages.dart';
import '../../../../core/ui/app_state_view.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../bookings/presentation/screens/create_booking_screen.dart';
import '../../data/models/excursion_detail_model.dart';
import '../../data/services/excursion_service.dart';

class ExcursionDetailScreen extends StatefulWidget {
  final int excursionId;

  const ExcursionDetailScreen({
    super.key,
    required this.excursionId,
  });

  @override
  State<ExcursionDetailScreen> createState() => _ExcursionDetailScreenState();
}

class _ExcursionDetailScreenState extends State<ExcursionDetailScreen> {
  final ExcursionService _excursionService = ExcursionService();
  late Future<ExcursionDetailModel> _futureExcursion;

  @override
  void initState() {
    super.initState();
    _futureExcursion = _excursionService.getExcursionDetail(widget.excursionId);
  }

  Future<void> _reload() async {
    setState(() {
      _futureExcursion =
          _excursionService.getExcursionDetail(widget.excursionId);
    });

    await _futureExcursion;
  }

  Future<void> _openBooking(ExcursionDetailModel excursion) async {
    var accessToken = await TokenStorage.getAccessToken();

    if (!mounted) return;

    if (accessToken == null || accessToken.isEmpty) {
      AppMessages.info(context, 'Сначала войдите в аккаунт');

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      accessToken = await TokenStorage.getAccessToken();

      if (!mounted) return;

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateBookingScreen(
          excursionId: excursion.id,
          excursionTitle: excursion.title,
          placeName: excursion.place.name,
          dateText: _formatDate(excursion.startDatetime),
          pricePerPerson: excursion.price,
          availablePlaces: excursion.availablePlaces,
        ),
      ),
    );

    if (created == true) {
      _reload();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ExcursionDetailModel>(
        future: _futureExcursion,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppStateView.loading(
              title: 'Загружаем экскурсию',
              message: 'Подождите немного',
            );
          }

          if (snapshot.hasError) {
            return AppStateView.error(
              title: 'Не удалось загрузить экскурсию',
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onAction: _reload,
            );
          }

          final excursion = snapshot.data!;
          final place = excursion.place;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: 280,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: _DetailHeroHeader(
                    title: excursion.title,
                    placeName: place.name,
                    imageUrl: place.imageUrl,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopMetaCard(
                        dateText: _formatDate(excursion.startDatetime),
                        priceText: '${excursion.price} ₽',
                        durationText: '${excursion.durationMinutes} мин',
                        availablePlaces: excursion.availablePlaces,
                        isBookable: excursion.isBookable,
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Об экскурсии',
                        child: Text(
                          excursion.description.isEmpty
                              ? 'Описание экскурсии пока не добавлено.'
                              : excursion.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Место проведения',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            if (place.city.isNotEmpty)
                              _InfoLine(
                                icon: Icons.location_city_outlined,
                                text: 'Город: ${place.city}',
                              ),
                            if (place.district.isNotEmpty)
                              _InfoLine(
                                icon: Icons.map_outlined,
                                text: 'Район: ${place.district}',
                              ),
                            if (place.address.isNotEmpty)
                              _InfoLine(
                                icon: Icons.place_outlined,
                                text: 'Адрес: ${place.address}',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Детали поездки',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoLine(
                              icon: Icons.schedule_outlined,
                              text:
                                  'Дата и время: ${_formatDate(excursion.startDatetime)}',
                            ),
                            _InfoLine(
                              icon: Icons.payments_outlined,
                              text: 'Стоимость: ${excursion.price} ₽',
                            ),
                            _InfoLine(
                              icon: Icons.timer_outlined,
                              text:
                                  'Длительность: ${excursion.durationMinutes} мин',
                            ),
                            _InfoLine(
                              icon: Icons.person_outline,
                              text:
                                  'Гид: ${excursion.guideName.isEmpty ? 'Не указан' : excursion.guideName}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Описание места',
                        child: Text(
                          place.description.isEmpty
                              ? 'Описание пока не добавлено.'
                              : place.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: excursion.isBookable
                              ? () => _openBooking(excursion)
                              : null,
                          child: const Text('Забронировать'),
                        ),
                      ),
                    ],
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

class _DetailHeroHeader extends StatelessWidget {
  final String title;
  final String placeName;
  final String imageUrl;

  const _DetailHeroHeader({
    required this.title,
    required this.placeName,
    required this.imageUrl,
  });

  String _normalizeImageUrl(String url) {
    if (url.isEmpty) return '';

    return url
        .replaceFirst('http://127.0.0.1:8000', 'http://10.0.2.2:8000')
        .replaceFirst('http://localhost:8000', 'http://10.0.2.2:8000');
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = _normalizeImageUrl(imageUrl);
    final hasImage = normalizedUrl.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage)
          Image.network(
            normalizedUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackBackground(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _fallbackBackground();
            },
          )
        else
          _fallbackBackground(),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x22000000),
                Color(0xAA000000),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  placeName,
                  style: const TextStyle(
                    color: Color(0xFF243128),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallbackBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB8E9C5),
            Color(0xFFE9F8ED),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.landscape_rounded,
          size: 72,
          color: Color(0xFF2E4437),
        ),
      ),
    );
  }
}

class _TopMetaCard extends StatelessWidget {
  final String dateText;
  final String priceText;
  final String durationText;
  final int availablePlaces;
  final bool isBookable;

  const _TopMetaCard({
    required this.dateText,
    required this.priceText,
    required this.durationText,
    required this.availablePlaces,
    required this.isBookable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
        isBookable ? const Color(0xFF2C7A4B) : const Color(0xFFD14C38);
    final statusBg =
        isBookable ? const Color(0xFFE6F7EA) : const Color(0xFFFFECE8);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaChip(
                icon: Icons.schedule_outlined,
                text: dateText,
              ),
              _MetaChip(
                icon: Icons.timer_outlined,
                text: durationText,
              ),
              _MetaChip(
                icon: Icons.payments_outlined,
                text: priceText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  isBookable ? Icons.check_circle_outline : Icons.block_outlined,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBookable
                        ? 'Доступно для бронирования'
                        : 'Недоступно для бронирования',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Мест: $availablePlaces',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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