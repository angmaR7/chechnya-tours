import 'package:flutter/material.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/ui/app_state_view.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  Future<ProfileModel>? _futureProfile;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  Future<void> _initProfile() async {
    final token = await TokenStorage.getAccessToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _hasToken = false;
        _futureProfile = null;
      });
      return;
    }

    setState(() {
      _hasToken = true;
      _futureProfile = _profileService.getMe();
    });
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

    _initProfile();
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    AppNavigator.toLoginAndClearStack();
  }

  Future<void> _openEditProfile(ProfileModel profile) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );

    if (changed == true) {
      _initProfile();
    }
  }

  Future<void> _openChangePassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );

    if (!mounted) return;
    _initProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasToken) {
      return AppStateView.empty(
        icon: Icons.person_outline_rounded,
        title: 'Профиль недоступен',
        message:
            'Войди в аккаунт, чтобы просматривать свои данные и управлять настройками.',
        actionText: 'Войти',
        onAction: _openLogin,
      );
    }

    return FutureBuilder<ProfileModel>(
      future: _futureProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppStateView.loading(
            title: 'Загружаем профиль',
            message: 'Подождите немного',
          );
        }

        if (snapshot.hasError) {
          return AppStateView.error(
            title: 'Не удалось загрузить профиль',
            message: snapshot.error.toString().replaceFirst('Exception: ', ''),
            onAction: _initProfile,
          );
        }

        final profile = snapshot.data!;

        final fullName =
            '${profile.firstName} ${profile.lastName}'.trim().isEmpty
                ? profile.username
                : '${profile.firstName} ${profile.lastName}'.trim();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ProfileHeroCard(
              fullName: fullName,
              email: profile.email,
              username: profile.username,
            ),
            const SizedBox(height: 18),
            _InfoCard(
              icon: Icons.phone_outlined,
              title: 'Телефон',
              value:
                  profile.phoneNumber.isEmpty ? 'Не указан' : profile.phoneNumber,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: profile.email.isEmpty ? 'Не указан' : profile.email,
            ),
            const SizedBox(height: 24),
            Text(
              'Управление аккаунтом',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.edit_outlined,
              title: 'Редактировать профиль',
              subtitle: 'Изменить имя, email и телефон',
              onTap: () => _openEditProfile(profile),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.lock_outline_rounded,
              title: 'Сменить пароль',
              subtitle: 'Обновить пароль аккаунта',
              onTap: _openChangePassword,
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.logout_rounded,
              title: 'Выйти',
              subtitle: 'Завершить текущую сессию',
              isDanger: true,
              onTap: _logout,
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final String fullName;
  final String email;
  final String username;

  const _ProfileHeroCard({
    required this.fullName,
    required this.email,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
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
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(210),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.person_rounded, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            email.isEmpty ? 'Email не указан' : email,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '@$username',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EBE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = isDanger ? const Color(0xFFFFECE8) : const Color(0xFFEAF3EC);
    final iconColor = isDanger ? const Color(0xFFD14C38) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE7EBE5)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}