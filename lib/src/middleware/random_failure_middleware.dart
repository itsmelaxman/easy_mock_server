import 'dart:math';

import '../model/mock_request_context.dart';
import '../model/mock_response.dart';
import 'mock_middleware.dart';

/// Randomly simulates server failures for testing error handling.
class RandomFailureMiddleware extends MockMiddleware {
  /// Creates a random failure middleware.
  ///
  /// [failureRate] is a value from 0.0 to 1.0 indicating the probability of failure.
  /// [statusCode] is the HTTP status code to return on failure (default: 500).
  /// [message] is the error message to return on failure.
  RandomFailureMiddleware({
    required this.failureRate,
    this.statusCode = 500,
    this.message = 'Simulated server failure',
    Random? random,
  })  : assert(failureRate >= 0 && failureRate <= 1),
        _random = random ?? Random();

  /// Probability of a request failing (0.0 to 1.0).
  final double failureRate;

  /// HTTP status code returned on failure.
  final int statusCode;

  /// Error message returned on failure.
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
