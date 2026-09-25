import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:verifipay_frontend/core/constants/api_constants.dart';
import 'package:verifipay_frontend/core/network/api_client.dart';
import 'package:verifipay_frontend/features/auth/models/auth_user.dart';
import 'package:verifipay_frontend/features/auth/presentation/role_home_page.dart';
import 'package:verifipay_frontend/features/owner/presentation/owner_home_page.dart';
import 'package:verifipay_frontend/features/payment_request/models/payment_request.dart';
import 'package:verifipay_frontend/features/payment_request/models/payment_request_page.dart';
import 'package:verifipay_frontend/features/payment_request/presentation/cashier_home_page.dart';
import 'package:verifipay_frontend/features/payment_request/presentation/new_payment_request_page.dart';
import 'package:verifipay_frontend/features/payment_request/services/payment_request_service.dart';
import 'package:verifipay_frontend/features/platform_admin/presentation/platform_admin_mobile_home_page.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'access-1'});
  });

  test('PaymentRequest parsea contrato real del backend', () {
    final item = PaymentRequest.fromJson(_paymentRequestJson());

    expect(item.id, 10);
    expect(item.amount, 80.5);
    expect(item.status, PaymentRequestStatus.waiting);
    expect(item.clientRequestId, 'mobile-1');
    expect(item.canCancel, isTrue);
  });

  test('PaymentRequestPage parsea PageResponse', () {
    final page = PaymentRequestPage.fromJson({
      'content': [_paymentRequestJson()],
      'page': 0,
      'size': 5,
      'totalElements': 1,
      'totalPages': 1,
      'first': true,
      'last': true,
    });

    expect(page.content, hasLength(1));
    expect(page.totalPages, 1);
  });

  test('PaymentRequestService crea, lista y cancela cobros', () async {
    final service = PaymentRequestService(
      apiClient: ApiClient(
        httpClient: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer access-1');

          if (request.method == 'POST' &&
              request.url.toString() == ApiConstants.paymentRequests) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body.keys, containsAll(['amount', 'clientRequestId']));
            return http.Response(_apiResponse(_paymentRequestJson()), 201);
          }

          if (request.method == 'GET' &&
              request.url.toString() ==
                  '${ApiConstants.paymentRequests}?page=0&size=5') {
            return http.Response(
              _apiResponse({
                'content': [_paymentRequestJson()],
                'page': 0,
                'size': 5,
                'totalElements': 1,
                'totalPages': 1,
                'first': true,
                'last': true,
              }),
              200,
            );
          }

          if (request.method == 'POST' &&
              request.url.toString() ==
                  '${ApiConstants.paymentRequests}/10/cancel') {
            return http.Response(
              _apiResponse({..._paymentRequestJson(), 'status': 'CANCELLED'}),
              200,
            );
          }

          return http.Response(_apiResponse(null), 404);
        }),
      ),
    );

    expect(
      (await service.create(amount: 80.5, clientRequestId: 'mobile-1')).id,
      10,
    );
    expect((await service.findMine(size: 5)).content, hasLength(1));
    expect((await service.cancel(10)).status, PaymentRequestStatus.cancelled);
  });

  testWidgets('RoleHomePage enruta CASHIER, OWNER y PLATFORM_ADMIN', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RoleHomePage(user: _user('CASHIER'))),
    );
    expect(find.byType(CashierHomePage), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: RoleHomePage(user: _user('OWNER'))),
    );
    expect(find.byType(OwnerHomePage), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: RoleHomePage(user: _user('PLATFORM_ADMIN'))),
    );
    expect(find.byType(PlatformAdminMobileHomePage), findsOneWidget);
    expect(find.textContaining('PaymentRequest'), findsNothing);
    expect(find.textContaining('Receiver'), findsNothing);
    expect(find.textContaining('Nuevo cobro'), findsNothing);
  });

  testWidgets('Nuevo cobro valida monto positivo', (tester) async {
    await tester.pumpWidget(MaterialApp(home: NewPaymentRequestPage()));

    await tester.tap(find.text('Crear cobro'));
    await tester.pump();

    expect(find.text('Ingresa un monto positivo.'), findsOneWidget);
  });
}

Map<String, dynamic> _paymentRequestJson() {
  return {
    'id': 10,
    'companyId': 2,
    'branchId': 3,
    'cashierId': 4,
    'amount': 80.5,
    'status': 'WAITING',
    'clientRequestId': 'mobile-1',
    'createdAt': '2026-09-25T12:00:00Z',
    'expiresAt': '2026-09-25T12:05:00Z',
    'paidAt': null,
  };
}

AuthUser _user(String role) {
  return AuthUser(
    id: 1,
    name: 'Test User',
    email: 'test@verifipay.dev',
    role: role,
    companyId: role == 'PLATFORM_ADMIN' ? null : 1,
    companyName: 'VerifiPay SAC',
    branchId: role == 'CASHIER' ? 2 : null,
    branchName: role == 'CASHIER' ? 'Caja 1' : null,
  );
}

String _apiResponse(Object? data) {
  return jsonEncode({'status': 'SUCCESS', 'message': null, 'data': data});
}
