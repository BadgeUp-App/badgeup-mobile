import 'package:flutter_test/flutter_test.dart';
import 'package:badgeup_mobile/services/aroa_errors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildPayload arma los campos correctos y sin PII por default', () {
    final payload = AroaErrors.buildPayload(
      ArgumentError('valor invalido'),
      StackTrace.current,
      level: 'fatal',
    );

    expect(payload['exception_type'], 'ArgumentError');
    expect(payload['message'], contains('valor invalido'));
    expect(payload['level'], 'fatal');
    expect(payload['stack_trace'], isA<String>());
    expect(payload['platform_meta'], isA<Map<String, dynamic>>());
    expect(payload.containsKey('user_hash'), isFalse);
  });

  test('capture es no-op sin init y no lanza', () async {
    await AroaErrors.capture(Exception('boom'), StackTrace.current);
  });
}
