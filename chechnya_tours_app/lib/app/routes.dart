import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/excursions/presentation/screens/excursions_screen.dart';
import '../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String excursions = '/excursions';
  static const String myBookings = '/my-bookings';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    excursions: (_) => const ExcursionsScreen(),
    myBookings: (_) => const MyBookingsScreen(),
    profile: (_) => const ProfileScreen(),
  };
}