import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:verifipay_frontend/core/constants/api_constants.dart';
import 'package:verifipay_frontend/core/network/api_client.dart';
import 'package:verifipay_frontend/core/network/api_exception.dart';
import 'package:verifipay_frontend/features/auth/models/auth_user.dart';
import 'package:verifipay_frontend/features/owner/presentation/owner_home_page.dart';
import 'package:verifipay_frontend/features/receiver_device/models/receiver_device_local_state.dart';
import 'package:verifipay_frontend/features/receiver_device/services/receiver_device_local_store.dart';
import 'package:verifipay_frontend/features/receiver_device/services/receiver_device_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.verifipay/notification_access');
  late bool nativeHasToken;
  late int clearTokenCalls;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'access-1'});
    nativeHasToken = false;
    clearTokenCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'hasDeviceToken':
              return nativeHasToken;
            case 'clearDeviceToken':
              nativeHasToken = false;
              clearTokenCalls++;
              return true;
            case 'isNotificationAccessGranted':
              return true;
            case 'getPendingYapeEventCount':
              return 2;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'getCurrentReceiver parsea receiver activo sin exponer secretos',
    () async {
      final service = _serviceFor(
        http.Response(
          _apiResponse({
            'id': 31,
            'name': 'Receptor principal',
            'branchId': 7,
            'branchName': 'Sucursal Centro',
            'lastSeenAt': '2026-09-25T12:30:00Z',
            'deviceToken': 'must-not-be-retained',
            'tokenHash': 'must-not-be-retained-either',
          }),
          200,
        ),
      );

      final current = await service.getCurrentReceiver();

      expect(current?.id, 31);
      expect(current?.branchName, 'Sucursal Centro');
      expect(current?.lastSeenAt, DateTime.utc(2026, 9, 25, 12, 30));
      expect(current.toString(), isNot(contains('must-not-be-retained')));
    },
  );

  test('getCurrentReceiver trata 404 como no configurado', () async {
    final service = _serviceFor(http.Response('{}', 404));

    expect(await service.getCurrentReceiver(), isNull);
  });

  test(
    'getCurrentReceiver conserva otros errores HTTP para reintento',
    () async {
      final service = _serviceFor(http.Response('{"message":"Error"}', 503));

      await expectLater(
        service.getCurrentReceiver(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    },
  );

  testWidgets('receiver activo sin token local pertenece a otro dispositivo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OwnerHomePage(
          user: _owner(),
          receiverDeviceService: _serviceFor(
            http.Response(_apiResponse(_currentReceiverJson()), 200),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Activo'), findsWidgets);
    expect(find.text('Otro dispositivo'), findsOneWidget);
    expect(find.text('Sucursal: Sucursal Centro'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('404 limpia token y metadata local obsoletos', (tester) async {
    nativeHasToken = true;
    final localStore = ReceiverDeviceLocalStore();
    await localStore.save(
      const ReceiverDeviceLocalState(
        id: 31,
        name: 'Receptor anterior',
        branchId: 7,
        branchName: 'Sucursal Centro',
        active: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OwnerHomePage(
          user: _owner(),
          receiverDeviceService: _serviceFor(http.Response('{}', 404)),
          receiverDeviceLocalStore: localStore,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No configurado'), findsOneWidget);
    expect(find.text('No vinculado'), findsOneWidget);
    expect(nativeHasToken, isFalse);
    expect(clearTokenCalls, 1);
    expect(await localStore.read(), isNull);
  });

  testWidgets('error de consulta muestra acción de reintento', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OwnerHomePage(
          user: _owner(),
          receiverDeviceService: _serviceFor(
            http.Response('{"message":"Servicio no disponible"}', 503),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Error de consulta'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('No configurado'), findsNothing);
  });
}

ReceiverDeviceService _serviceFor(http.Response response) {
  return ReceiverDeviceService(
    apiClient: ApiClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          '${ApiConstants.ownerReceiverDevices}/current',
        );
        expect(request.headers['Authorization'], 'Bearer access-1');
        return response;
      }),
    ),
  );
}

AuthUser _owner() {
  return AuthUser(
    id: 1,
    name: 'Owner Test',
    email: 'owner@test.dev',
    role: 'OWNER',
    companyId: 1,
    companyName: 'VerifiPay SAC',
  );
}

Map<String, dynamic> _currentReceiverJson() {
  return {
    'id': 31,
    'name': 'Receptor principal',
    'branchId': 7,
    'branchName': 'Sucursal Centro',
    'lastSeenAt': '2026-09-25T12:30:00Z',
  };
}

String _apiResponse(Object? data) {
  return jsonEncode({'status': 'SUCCESS', 'message': null, 'data': data});
}
