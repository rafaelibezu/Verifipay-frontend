import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:verifipay_frontend/core/constants/api_constants.dart';
import 'package:verifipay_frontend/core/network/api_client.dart';
import 'package:verifipay_frontend/core/network/api_exception.dart';
import 'package:verifipay_frontend/features/auth/models/auth_user.dart';
import 'package:verifipay_frontend/features/auth/models/login_response.dart';
import 'package:verifipay_frontend/features/auth/services/auth_service.dart';
import 'package:verifipay_frontend/features/auth/services/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final loginData = <String, dynamic>{
    'accessToken': 'access-1',
    'refreshToken': 'refresh-1',
    'tokenType': 'Bearer',
    'expiresIn': 1800,
    'user': {
      'id': 1,
      'name': 'Admin',
      'email': 'admin@test.dev',
      'role': 'PLATFORM_ADMIN',
      'companyId': null,
      'branchId': null,
    },
  };

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('LoginResponse parsea access y refresh token', () {
    final response = LoginResponse.fromJson(loginData);

    expect(response.accessToken, 'access-1');
    expect(response.refreshToken, 'refresh-1');
    expect(response.tokenType, 'Bearer');
    expect(response.expiresIn, 1800);
  });

  test('AuthUser acepta companyId null para PLATFORM_ADMIN', () {
    final user = AuthUser.fromJson(loginData['user'] as Map<String, dynamic>);

    expect(user.role, 'PLATFORM_ADMIN');
    expect(user.companyId, isNull);
    expect(user.branchId, isNull);
  });

  test('TokenStorage guarda y limpia access y refresh', () async {
    final storage = TokenStorage();

    await storage.saveTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );

    expect(await storage.getAccessToken(), 'access-1');
    expect(await storage.getRefreshToken(), 'refresh-1');

    await storage.clearTokens();

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
  });

  test('401 hace refresh, guarda tokens rotados y reintenta una vez', () async {
    final storage = TokenStorage();
    await storage.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );

    var protectedCalls = 0;

    final client = ApiClient(
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        if (request.url.toString() == ApiConstants.refresh) {
          expect(request.body, contains('old-refresh'));

          return http.Response(
            _apiResponse({
              ...loginData,
              'accessToken': 'new-access',
              'refreshToken': 'new-refresh',
            }),
            200,
          );
        }

        protectedCalls++;

        if (protectedCalls == 1) {
          expect(request.headers['Authorization'], 'Bearer old-access');
          return http.Response(_apiResponse(null), 401);
        }

        expect(request.headers['Authorization'], 'Bearer new-access');
        return http.Response(_apiResponse({'ok': true}), 200);
      }),
    );

    final data = await client.get(
      'http://example.test/protected',
      authenticated: true,
    ) as Map<String, dynamic>;

    expect(data['ok'], isTrue);
    expect(protectedCalls, 2);
    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
  });

  test('refresh invalido limpia sesion', () async {
    final storage = TokenStorage();
    await storage.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'bad-refresh',
    );

    final client = ApiClient(
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        if (request.url.toString() == ApiConstants.refresh) {
          return http.Response(_apiResponse(null), 401);
        }

        return http.Response(_apiResponse(null), 401);
      }),
    );

    await expectLater(
      client.get('http://example.test/protected', authenticated: true),
      throwsA(
        isA<ApiException>().having(
          (error) => error.type,
          'type',
          ApiErrorType.sessionExpired,
        ),
      ),
    );

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
  });

  test('logout limpia tokens aunque backend falle', () async {
    final storage = TokenStorage();
    await storage.saveTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );

    final service = AuthService(
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        expect(request.url.toString(), ApiConstants.logout);
        return http.Response(_apiResponse(null), 500);
      }),
    );

    await service.logout();

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
  });
}

String _apiResponse(Object? data) {
  return jsonEncode({'status': 'SUCCESS', 'message': null, 'data': data});
}
