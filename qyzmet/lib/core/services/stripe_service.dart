import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stripeServiceProvider =
    Provider<StripeService>((ref) => StripeService());

class StripeService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amountKZT,
    required String bookingId,
    required String clientId,
    required String providerId,
  }) async {
    final callable =
        _functions.httpsCallable('createPaymentIntent');
    final result = await callable.call({
      'amount': amountKZT * 100, // Convert to tiyn (cents)
      'currency': 'kzt',
      'bookingId': bookingId,
      'clientId': clientId,
      'providerId': providerId,
    });
    return Map<String, dynamic>.from(result.data);
  }

  Future<bool> presentPaymentSheet({
    required String clientSecret,
    required String merchantName,
    required String customerEmail,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantName,
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'KZ',
          currencyCode: 'KZT',
          testEnv: true,
        ),
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: 'KZ',
        ),
      ),
    );

    await Stripe.instance.presentPaymentSheet();
    return true;
  }

  Future<Map<String, dynamic>> createConnectAccount({
    required String userId,
    required String email,
    required String country,
  }) async {
    final callable =
        _functions.httpsCallable('createConnectAccount');
    final result = await callable.call({
      'userId': userId,
      'email': email,
      'country': country,
    });
    return Map<String, dynamic>.from(result.data);
  }

  Future<String> createAccountLink(String accountId) async {
    final callable =
        _functions.httpsCallable('createAccountLink');
    final result = await callable.call({'accountId': accountId});
    return result.data['url'] as String;
  }

  Future<void> requestPayout({
    required String providerId,
    required double amount,
  }) async {
    final callable = _functions.httpsCallable('requestPayout');
    await callable.call({
      'providerId': providerId,
      'amount': amount,
    });
  }

  Future<Map<String, dynamic>> getPaymentMethods(
      String customerId) async {
    final callable =
        _functions.httpsCallable('getPaymentMethods');
    final result = await callable.call({'customerId': customerId});
    return Map<String, dynamic>.from(result.data);
  }
}
