import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_tokens_model.dart';

class AuthService {
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/auth/token/',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          extra: {
            'requiresAuth': false,
          },
        ),
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Неверный формат ответа при авторизации.');
      }

      final tokens = AuthTokensModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      await TokenStorage.saveTokens(
        accessToken: tokens.access,
        refreshToken: tokens.refresh,
      );

      return tokens;
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map && responseData['detail'] != null) {
        throw Exception(responseData['detail'].toString());
      }

      throw Exception('Не удалось выполнить вход.');
    } catch (_) {
      throw Exception('Произошла ошибка при авторизации.');
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required String password2,
  }) async {
    try {
      await DioClient.dio.post(
        '/auth/register/',
        data: {
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'password': password,
          'password2': password2,
        },
        options: Options(
          extra: {
            'requiresAuth': false,
          },
        ),
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData['detail'] != null) {
          throw Exception(responseData['detail'].toString());
        }

        for (final entry in responseData.entries) {
          final value = entry.value;

          if (value is List && value.isNotEmpty) {
            throw Exception(value.first.toString());
          }

          if (value is String && value.isNotEmpty) {
            throw Exception(value);
          }
        }
      }

      throw Exception('Не удалось зарегистрироваться.');
    } catch (_) {
      throw Exception('Произошла ошибка при регистрации.');
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await DioClient.dio.post(
          '/auth/logout/',
          data: {
            'refresh': refreshToken,
          },
          options: Options(
            extra: {
              'requiresAuth': false,
            },
          ),
        );
      }
    } catch (_) {
    } finally {
      await TokenStorage.clearTokens();
    }
  }
}