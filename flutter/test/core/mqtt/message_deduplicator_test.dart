import 'package:flutter_test/flutter_test.dart';
import 'package:cii/core/mqtt/message_deduplicator.dart';

void main() {
  group('MessageDeduplicator', () {
    late MessageDeduplicator deduplicator;

    setUp(() {
      deduplicator = MessageDeduplicator();
    });

    test('should identify duplicate messages', () {
      final topic = 'topic/1';
      final payload = 'payload';

      // First message: New
      expect(deduplicator.isDuplicate(topic, payload), isFalse);

      // Same message immediately: Duplicate
      expect(deduplicator.isDuplicate(topic, payload), isTrue);
    });

    test('should accept different payloads on same topic', () {
      final topic = 'topic/1';

      expect(deduplicator.isDuplicate(topic, 'A'), isFalse);
      expect(deduplicator.isDuplicate(topic, 'B'), isFalse);
    });

    test('should accept same payload on different topics', () {
      final payload = 'A';

      expect(deduplicator.isDuplicate('topic/1', payload), isFalse);
      expect(deduplicator.isDuplicate('topic/2', payload), isFalse);
    });

    test('should clear cache', () {
      final topic = 'topic/1';
      final payload = 'payload';

      deduplicator.isDuplicate(topic, payload);
      deduplicator.clear();

      // Should handle as new after clear
      expect(deduplicator.isDuplicate(topic, payload), isFalse);
    });
  });
}
