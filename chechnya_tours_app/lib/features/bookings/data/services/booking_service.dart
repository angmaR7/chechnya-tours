import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/booking_model.dart';

class BookingService {
  Future<BookingModel> createBooking({
    required int excursionId,
    required String fullName,
    required String phoneNumber,
    required String email,
    required int peopleCount,
    required String comment,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/bookings/',
        data: {
          'excursion': excursionId,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'email': email,
          'people_count': peopleCount,
          'comment': comment,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Неверный формат ответа при создании брони.');
      }

      return BookingModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    } catch (_) {
      throw Exception('Произошла ошибка при создании бронирования.');
    }
  }

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await DioClient.dio.get('/bookings/my/');
      final data = response.data;

      if (data is! List) {
        throw Exception('Неверный формат списка бронирований.');
      }

      return data
          .map(
            (item) => BookingModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    } catch (_) {
      throw Exception('Произошла ошибка при загрузке бронирований.');
    }
  }

  Future<BookingModel> getBookingDetail(int id) async {
    try {
      final response = await DioClient.dio.get('/bookings/$id/');
      final data = response.data;

      if (data is! Map) {
        throw Exception('Неверный формат данных бронирования.');
      }

      return BookingModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    } catch (_) {
      throw Exception('Произошла ошибка при загрузке бронирования.');
    }
  }

  Future<BookingModel> cancelBooking(int id) async {
    try {
      final response = await DioClient.dio.post('/bookings/$id/cancel/');
      final data = response.data;

      if (data is! Map) {
        throw Exception('Неверный формат ответа при отмене бронирования.');
      }

      return BookingModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    } catch (_) {
      throw Exception('Произошла ошибка при отмене бронирования.');
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