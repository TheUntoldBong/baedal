import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/repositories/bogo_offer_repository.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockAuthController extends GetxController with Mock implements AuthController {}

void main() {
  late MockApiClient apiClient;
  late MockAuthController auth;
  late BogoOfferRepository repository;
  late List<String> requestedUris;

  setUp(() {
    requestedUris = [];
    apiClient = MockApiClient();
    when(() => apiClient.getData(any(), handleError: any(named: 'handleError'))).thenAnswer((invocation) async {
      requestedUris.add(invocation.positionalArguments.first as String);
      return const Response(statusCode: 204);
    });

    auth = MockAuthController();
    Get.put<AuthController>(auth);
    repository = BogoOfferRepository(apiClient: apiClient);
  });

  tearDown(Get.reset);

  void signedOutGuest() {
    when(() => auth.isLoggedIn()).thenReturn(false);
    when(() => auth.getGuestId()).thenReturn('4417');
  }

  void signedIn() {
    when(() => auth.isLoggedIn()).thenReturn(true);
    when(() => auth.getGuestId()).thenReturn('4417');
  }

  group('a guest', () {
    test('identifies itself on every bogo request, or the endpoint refuses it', () async {
      signedOutGuest();

      await repository.getBogoHomeData();
      await repository.getBogoOfferList();
      await repository.getBogoOfferDetails(idOrSlug: 'buy-1-get-1');

      expect(requestedUris, hasLength(3));
      for(final String uri in requestedUris) {
        expect(uri, contains('guest_id=4417'), reason: uri);
      }
    });
  });

  group('a signed in customer', () {
    test('sends no guest id, the token identifies them', () async {
      signedIn();

      await repository.getBogoHomeData(orderType: 'delivery');
      await repository.getBogoOfferList(offset: 2);
      await repository.getBogoOfferDetails(idOrSlug: '7');

      for(final String uri in requestedUris) {
        expect(uri, isNot(contains('guest_id')), reason: uri);
      }
      expect(requestedUris.first, contains('order_type=delivery'), reason: 'the existing query is untouched');
      expect(requestedUris[1], contains('offset=2'));
    });
  });

  test('sends no guest id when there is not one yet', () async {
    when(() => auth.isLoggedIn()).thenReturn(false);
    when(() => auth.getGuestId()).thenReturn('');

    await repository.getBogoOfferList();

    expect(requestedUris.single, isNot(contains('guest_id')));
  });
}
