import 'package:flutter/material.dart';

import '../../../../core/ui/app_state_view.dart';
import '../../data/models/dashboard_data_model.dart';
import '../../data/services/dashboard_service.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../excursions/presentation/screens/excursion_detail_screen.dart';
import '../../../excursions/presentation/screens/excursions_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Chechnya Tours',
    'Экскурсии',
    'Мои бронирования',
    'Профиль',
  ];

  final List<Widget> _basePages = const [
    ExcursionsScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openExcursionsTab() {
    _changeTab(1);
  }

  void _openBookingsTab() {
    _changeTab(2);
  }

  void _openProfileTab() {
    _changeTab(3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pages = [
      _DashboardTab(
        onOpenExcursions: _openExcursionsTab,
        onOpenBookings: _openBookingsTab,
        onOpenProfile: _openProfileTab,
      ),
      _basePages[0],
      _basePages[1],
      _basePages[2],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              height: 72,
              selectedIndex: _currentIndex,
              backgroundColor: theme.colorScheme.surface,
              onDestinationSelected: _changeTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Главная',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Экскурсии',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded),
                  label: 'Бронирования',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Профиль',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  final VoidCallback onOpenExcursions;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenProfile;

  const _DashboardTab({
    required this.onOpenExcursions,
    required this.onOpenBookings,
    required this.onOpenProfile,
  });

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final DashboardService _dashboardService = DashboardService();
  late Future<DashboardDataModel> _futureDashboard;

  @override
  void initState() {
    super.initState();
    _futureDashboard = _dashboardService.getDashboardData();
  }

  Future<void> _reload() async {
    setState(() {
      _futureDashboard = _dashboardService.getDashboardData();
    });

    await _futureDashboard;
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
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<DashboardDataModel>(
        future: _futureDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppStateView.loading(
              title: 'Загружаем главную страницу',
              message: 'Подождите немного',
            );
          }

          if (snapshot.hasError) {
            return AppStateView.error(
              title: 'Не удалось загрузить главную страницу',
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onAction: _reload,
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _HeroCard(
                userName: data.userName,
              ),
              const SizedBox(height: 22),
              const _SectionHeader(
                title: 'Сводка',
                subtitle: 'Актуальные данные по приложению',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.map_outlined,
                      title: '${data.totalExcursions}',
                      subtitle: 'Всего экскурсий',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.event_available_outlined,
                      title: '${data.availableExcursions}',
                      subtitle: 'Доступно сейчас',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _WideStatCard(
                icon: Icons.bookmark_outline_rounded,
                title: '${data.myBookingsCount}',
                subtitle: 'Моих бронирований',
                onTap: widget.onOpenBookings,
              ),
              const SizedBox(height: 26),
              const _SectionHeader(
                title: 'Ближайшая экскурсия',
                subtitle: 'Следующий доступный маршрут',
              ),
              const SizedBox(height: 14),
              if (data.nearestExcursion != null)
                _NearestExcursionCard(
                  title: data.nearestExcursion!.title,
                  placeName: data.nearestExcursion!.placeName,
                  dateText: _formatDate(data.nearestExcursion!.startDatetime),
                  priceText: '${data.nearestExcursion!.price} ₽',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExcursionDetailScreen(
                          excursionId: data.nearestExcursion!.id,
                        ),
                      ),
                    );
                  },
                )
              else
                const _EmptyNearestExcursionCard(),
              const SizedBox(height: 26),
              const _SectionHeader(
                title: 'Быстрые действия',
                subtitle: 'Основные сценарии использования',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.explore_outlined,
                      title: 'Найти маршрут',
                      subtitle: 'Посмотреть все экскурсии',
                      onTap: widget.onOpenExcursions,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.bookmark_border_rounded,
                      title: 'Мои бронирования',
                      subtitle: 'Открыть список поездок',
                      onTap: widget.onOpenBookings,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _QuickActionWideCard(
                icon: Icons.location_on_outlined,
                title: 'Популярные направления',
                subtitle:
                    'Открыть список доступных экскурсий и выбрать маршрут',
                onTap: widget.onOpenExcursions,
              ),
              const SizedBox(height: 12),
              _QuickActionWideCard(
                icon: Icons.person_outline_rounded,
                title: 'Профиль',
                subtitle: 'Посмотреть свои данные и настройки аккаунта',
                onTap: widget.onOpenProfile,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String? userName;

  const _HeroCard({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting =
        userName == null || userName!.trim().isEmpty ? 'Путешественник' : userName!;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA7E6BD),
            Color(0xFFDCF4E2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(155),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.landscape_rounded,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Добро пожаловать, $greeting',
            style: theme.textTheme.headlineSmall?.copyWith(
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Планируй поездки по Чеченской Республике, выбирай интересные маршруты и управляй своими бронированиями.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF476052),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Icon(icon, size: 28),
          const SizedBox(height: 18),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _WideStatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EBE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.arrow_forward_rounded, size: 20),
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _NearestExcursionCard extends StatelessWidget {
  final String title;
  final String placeName;
  final String dateText;
  final String priceText;
  final VoidCallback onTap;

  const _NearestExcursionCard({
    required this.title,
    required this.placeName,
    required this.dateText,
    required this.priceText,
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE7EBE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(placeName, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetaChip(
                    icon: Icons.schedule_outlined,
                    text: dateText,
                  ),
                  _MetaChip(
                    icon: Icons.payments_outlined,
                    text: priceText,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Spacer(),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNearestExcursionCard extends StatelessWidget {
  const _EmptyNearestExcursionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EBE5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy_outlined, size: 34),
          const SizedBox(height: 12),
          Text(
            'Экскурсии пока не найдены',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Когда в системе появятся маршруты, ближайшая экскурсия будет показана здесь.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE7EBE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionWideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionWideCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE7EBE5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
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
          Icon(icon, size: 17),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}