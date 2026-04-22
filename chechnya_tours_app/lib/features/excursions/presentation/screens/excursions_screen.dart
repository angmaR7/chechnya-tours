import 'package:flutter/material.dart';

import '../../../../core/ui/app_state_view.dart';
import '../../data/models/excursion_model.dart';
import '../../data/services/excursion_service.dart';
import 'excursion_detail_screen.dart';

enum ExcursionSortType {
  nearest,
  cheapest,
  expensive,
}

class ExcursionsScreen extends StatefulWidget {
  const ExcursionsScreen({super.key});

  @override
  State<ExcursionsScreen> createState() => _ExcursionsScreenState();
}

class _ExcursionsScreenState extends State<ExcursionsScreen> {
  final ExcursionService _excursionService = ExcursionService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<ExcursionModel>> _futureExcursions;

  String _searchQuery = '';
  bool _onlyAvailable = false;
  ExcursionSortType _sortType = ExcursionSortType.nearest;

  @override
  void initState() {
    super.initState();
    _futureExcursions = _excursionService.getExcursions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _futureExcursions = _excursionService.getExcursions();
    });

    await _futureExcursions;
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

  void _openExcursionDetail(ExcursionModel excursion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExcursionDetailScreen(excursionId: excursion.id),
      ),
    );
  }

  List<ExcursionModel> _applyFilters(List<ExcursionModel> source) {
    var result = [...source];

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();

      result = result.where((excursion) {
        return excursion.title.toLowerCase().contains(query) ||
            excursion.placeName.toLowerCase().contains(query) ||
            excursion.description.toLowerCase().contains(query);
      }).toList();
    }

    if (_onlyAvailable) {
      result = result
          .where((excursion) => excursion.availablePlaces > 0)
          .toList();
    }

    switch (_sortType) {
      case ExcursionSortType.nearest:
        result.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));
        break;
      case ExcursionSortType.cheapest:
        result.sort(
          (a, b) => double.parse(a.price).compareTo(double.parse(b.price)),
        );
        break;
      case ExcursionSortType.expensive:
        result.sort(
          (a, b) => double.parse(b.price).compareTo(double.parse(a.price)),
        );
        break;
    }

    return result;
  }

  String _sortLabel(ExcursionSortType type) {
    switch (type) {
      case ExcursionSortType.nearest:
        return 'Сначала ближайшие';
      case ExcursionSortType.cheapest:
        return 'Сначала дешевле';
      case ExcursionSortType.expensive:
        return 'Сначала дороже';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<ExcursionModel>>(
        future: _futureExcursions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppStateView.loading(
              title: 'Загружаем экскурсии',
              message: 'Подождите немного',
            );
          }

          if (snapshot.hasError) {
            return AppStateView.error(
              title: 'Не удалось загрузить экскурсии',
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onAction: _reload,
            );
          }

          final excursions = snapshot.data ?? [];
          final filteredExcursions = _applyFilters(excursions);

          if (excursions.isEmpty) {
            return const AppStateView.empty(
              icon: Icons.travel_explore_rounded,
              title: 'Экскурсий пока нет',
              message: 'Когда экскурсии появятся, они будут отображаться здесь.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const _ExcursionsHeader(),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Поиск по названию, месту, описанию',
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      selected: _onlyAvailable,
                      label: const Text('Только доступные'),
                      onSelected: (value) {
                        setState(() {
                          _onlyAvailable = value;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    _SortChip(
                      label: _sortLabel(_sortType),
                      onTap: () async {
                        final selected =
                            await showModalBottomSheet<ExcursionSortType>(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Сначала ближайшие'),
                                    onTap: () => Navigator.of(context).pop(
                                      ExcursionSortType.nearest,
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Сначала дешевле'),
                                    onTap: () => Navigator.of(context).pop(
                                      ExcursionSortType.cheapest,
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Сначала дороже'),
                                    onTap: () => Navigator.of(context).pop(
                                      ExcursionSortType.expensive,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (selected != null) {
                          setState(() {
                            _sortType = selected;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (filteredExcursions.isEmpty)
                const AppStateView.empty(
                  icon: Icons.search_off_rounded,
                  title: 'Ничего не найдено',
                  message:
                      'Попробуйте изменить поисковый запрос или отключить фильтр доступных экскурсий.',
                )
              else
                ...filteredExcursions.map(
                  (excursion) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ExcursionCard(
                      excursion: excursion,
                      dateText: _formatDate(excursion.startDatetime),
                      onTap: () => _openExcursionDetail(excursion),
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

class _ExcursionsHeader extends StatelessWidget {
  const _ExcursionsHeader();

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
            Color(0xFFE6F7EA),
            Color(0xFFF4FBF6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Экскурсии', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Выбирай подходящий маршрут, смотри детали и бронируй поездки прямо в приложении.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.tune, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _ExcursionCard extends StatelessWidget {
  final ExcursionModel excursion;
  final String dateText;
  final VoidCallback onTap;

  const _ExcursionCard({
    required this.excursion,
    required this.dateText,
    required this.onTap,
  });

  String _normalizeImageUrl(String url) {
    if (url.isEmpty) return '';

    return url
        .replaceFirst('http://127.0.0.1:8000', 'http://10.0.2.2:8000')
        .replaceFirst('http://localhost:8000', 'http://10.0.2.2:8000');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = excursion.availablePlaces > 0;
    final imageUrl = _normalizeImageUrl(excursion.imageUrl);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 154,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const _ExcursionImageFallback();
                        },
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const _ExcursionImageFallback();
                        },
                      )
                    else
                      const _ExcursionImageFallback(),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(210),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              dateText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF334139),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: available
                              ? const Color(0xFFE6F7EA)
                              : const Color(0xFFFFECE8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          available
                              ? 'Мест: ${excursion.availablePlaces}'
                              : 'Нет мест',
                          style: TextStyle(
                            color: available
                                ? const Color(0xFF2C7A4B)
                                : const Color(0xFFD14C38),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      excursion.title,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      excursion.placeName,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      excursion.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F5F1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payments_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${excursion.price} ₽',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExcursionImageFallback extends StatelessWidget {
  const _ExcursionImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB6E8C4),
            Color(0xFFE7F7EC),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.landscape_rounded,
          size: 56,
          color: Color(0xFF2F4137),
        ),
      ),
    );
  }
}