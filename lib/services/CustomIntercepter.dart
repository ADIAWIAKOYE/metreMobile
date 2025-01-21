import 'package:http/http.dart' as http;
import 'package:Metre/services/TokenManager.dart';

class CustomIntercepter extends http.BaseClient {
  final http.Client _inner;
  CustomIntercepter(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    String? token = await TokenManager.getValidToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return await _inner.send(request);
  }
}
