import 'dart:math';

import '../model/mock_request_context.dart';
import '../model/mock_response.dart';
import 'mock_middleware.dart';

class RandomFailureMiddleware extends MockMiddleware {
  RandomFailureMiddleware({
    required this.failureRate,
    this.statusCode = 500,
    this.message = 'Simulated server failure',
    Random? random,
  })  : assert(failureRate >= 0 && failureRate <= 1),
        _random = random ?? Random();

  final double failureRate;
  final int statusCode;
  final String message;
  final Random _random;

  @override
  Future<MockResponse?> onRequest(MockRequestContext context) async {
    if (_random.nextDouble() < failureRate) {
      return MockResponse.error(statusCode: statusCode, message: message);
    }
    return null;
  }
}
