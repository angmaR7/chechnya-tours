import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/excursion_detail_model.dart';
import '../models/excursion_model.dart';

class ExcursionService {
  Future<List<ExcursionModel>> getExcursions() async {
    try {
      final response = await DioClient.dio.get('/excursions/');
      final data = response.data;

      if (data is! List) {
        throw Exception('Неверный формат данных от сервера.');
      }

      return data
          .map(
            (item) => ExcursionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map && responseData['detail'] != null) {
        throw Exception(responseData['detail'].toString());
      }

      throw Exception('Не удалось загрузить экскурсии.');
    } catch (_) {
      throw Exception('Произошла ошибка при загрузке экскурсий.');
    }
  }

  Future<ExcursionDetailModel> getExcursionDetail(int id) async {
    try {
      final response = await DioClient.dio.get('/excursions/$id/');
      final data = response.data;

      if (data is! Map) {
        throw Exception('Неверный формат данных экскурсии.');
      }

      return ExcursionDetailModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map && responseData['detail'] != null) {
        throw Exception(responseData['detail'].toString());
      }

      throw Exception('Не удалось загрузить данные экскурсии.');
    } catch (_) {
      throw Exception('Произошла ошибка при загрузке экскурсии.');
    }
  }
}