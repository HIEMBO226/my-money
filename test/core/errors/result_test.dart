import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/core/errors/app_exception.dart';
import 'package:my_money/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Success exposes data and runs success branch', () {
      const Result<int> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.exceptionOrNull, isNull);

      final output = result.when(
        success: (data) => 'value:$data',
        failure: (error) => 'error:${error.message}',
      );
      expect(output, 'value:42');
    });

    test('Failure exposes exception and runs failure branch', () {
      const exception = ValidationException('Montant invalide');
      const Result<int> result = Failure(exception);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.exceptionOrNull, exception);

      final output = result.when(
        success: (data) => 'value:$data',
        failure: (error) => 'error:${error.message}',
      );
      expect(output, 'error:Montant invalide');
    });
  });
}
