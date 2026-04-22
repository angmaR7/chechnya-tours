import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';

class SessionService {
  Future<bool> checkSession() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      final refreshToken = await TokenStorage.getRefreshToken();

      final hasAnyToken = (accessToken != null && accessToken.isNotEmpty) ||
          (refreshToken != null && refreshToken.isNotEmpty);

      if (!hasAnyToken) {
        return false;
      }

      await DioClient.dio.get('/auth/me/');
      return true;
    } catch (_) {
      await TokenStorage.clearTokens();
      return false;
    }
  }
}