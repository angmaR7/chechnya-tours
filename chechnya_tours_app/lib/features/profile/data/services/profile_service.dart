import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel> getMe() async {
    try {
      final response = await DioClient.dio.get('/auth/me/');
      final data = response.data;

      if (data is! Map) {
        throw Exception('Неверный формат данных профиля.');
      }

      return ProfileModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    } catch (_) {
      throw Exception('Произошла ошибка при загрузке профиля.');
    }
  }

  Future<ProfileModel> updateMe({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await DioClient.dio.patch(
        '/auth/me/',
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Неверный формат ответа при обновлении профиля.');
      }

      return ProfileModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    } catch (_) {
      throw Exception('Произошла ошибка при обновлении профиля.');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPassword2,
  }) async {
    try {
      await DioClient.dio.post(
        '/auth/me/change-password/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password2': newPassword2,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    } catch (_) {
      throw Exception('Произошла ошибка при смене пароля.');
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) {
        return data['detail'].toString();
      }

      for (final entry in data.entries) {
        final value = entry.value;

        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }

        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return 'Не удалось выполнить запрос.';
  }
}