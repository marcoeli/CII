import 'package:flutter_test/flutter_test.dart';
import 'package:cii/core/utils/staleness_checker.dart';

void main() {
  group('StalenessChecker', () {
    group('isStale', () {
      test(
        'returns true for timestamps older than default threshold (5 min)',
        () {
          final oldTime = DateTime.now().subtract(const Duration(minutes: 10));
          expect(StalenessChecker.isStale(oldTime), true);
        },
      );

      test('returns false for recent timestamps within default threshold', () {
        final recentTime = DateTime.now().subtract(const Duration(seconds: 30));
        expect(StalenessChecker.isStale(recentTime), false);
      });

      test('returns true for null timestamps', () {
        expect(StalenessChecker.isStale(null), true);
      });

      test('respects custom threshold', () {
        final time = DateTime.now().subtract(const Duration(minutes: 7));

        // Default threshold (5 min) - should be stale
        expect(StalenessChecker.isStale(time), true);

        // Custom threshold (10 min) - should not be stale
        expect(
          StalenessChecker.isStale(
            time,
            threshold: const Duration(minutes: 10),
          ),
          false,
        );
      });

      test('edge case: exactly at threshold boundary', () {
        final time = DateTime.now().subtract(const Duration(minutes: 5));

        // At exactly 5 minutes, should be stale (> threshold, not >=)
        expect(StalenessChecker.isStale(time), isFalse);
      });
    });

    group('getStalenessDuration', () {
      test('returns correct duration', () {
        final time = DateTime.now().subtract(const Duration(minutes: 3));
        final duration = StalenessChecker.getStalenessDuration(time);

        expect(duration, isNotNull);
        expect(duration!.inMinutes, 3);
      });

      test('returns null for null timestamp', () {
        expect(StalenessChecker.getStalenessDuration(null), isNull);
      });

      test('handles very recent timestamps', () {
        final time = DateTime.now().subtract(const Duration(milliseconds: 500));
        final duration = StalenessChecker.getStalenessDuration(time);

        expect(duration, isNotNull);
        expect(duration!.inSeconds, 0);
      });
    });

    group('formatRelativeTime', () {
      test('formats seconds correctly (long format)', () {
        final time = DateTime.now().subtract(const Duration(seconds: 30));
        final formatted = StalenessChecker.formatRelativeTime(time);

        expect(formatted, '30 segundos atrás');
      });

      test('formats single second correctly', () {
        final time = DateTime.now().subtract(const Duration(seconds: 1));
        final formatted = StalenessChecker.formatRelativeTime(time);

        expect(formatted, '1 segundo atrás');
      });

      test('formats minutes correctly (long format)', () {
        final time = DateTime.now().subtract(const Duration(minutes: 5));
        final formatted = StalenessChecker.formatRelativeTime(time);

        expect(formatted, '5 minutos atrás');
      });

      test('formats hours correctly (long format)', () {
        final time = DateTime.now().subtract(const Duration(hours: 2));
        final formatted = StalenessChecker.formatRelativeTime(time);

        expect(formatted, '2 horas atrás');
      });

      test('formats days correctly (long format)', () {
        final time = DateTime.now().subtract(const Duration(days: 3));
        final formatted = StalenessChecker.formatRelativeTime(time);

        expect(formatted, '3 dias atrás');
      });

      test('formats weeks correctly (long format)', () {
        final time = DateTime.now().subtract(const Duration(days: 14));
        final formatted = StalenessChecker.formatRelativeTime(time);

        expect(formatted, '2 semanas atrás');
      });

      test('formats very old dates as absolute date', () {
        final time = DateTime.now().subtract(const Duration(days: 60));
        final formatted = StalenessChecker.formatRelativeTime(time);

        // Should return a date string, not relative
        expect(formatted, contains('/'));
      });

      test('formats seconds correctly (short format)', () {
        final time = DateTime.now().subtract(const Duration(seconds: 45));
        final formatted = StalenessChecker.formatRelativeTime(
          time,
          short: true,
        );

        expect(formatted, '45s');
      });

      test('formats minutes correctly (short format)', () {
        final time = DateTime.now().subtract(const Duration(minutes: 15));
        final formatted = StalenessChecker.formatRelativeTime(
          time,
          short: true,
        );

        expect(formatted, '15m');
      });

      test('formats hours correctly (short format)', () {
        final time = DateTime.now().subtract(const Duration(hours: 3));
        final formatted = StalenessChecker.formatRelativeTime(
          time,
          short: true,
        );

        expect(formatted, '3h');
      });

      test('handles null timestamp', () {
        final formatted = StalenessChecker.formatRelativeTime(null);
        expect(formatted, 'Nunca atualizado');
      });

      test('handles null timestamp (short format)', () {
        final formatted = StalenessChecker.formatRelativeTime(
          null,
          short: true,
        );
        expect(formatted, 'N/A');
      });

      test('handles very recent timestamp (now)', () {
        final time = DateTime.now().subtract(const Duration(milliseconds: 100));
        final formatted = StalenessChecker.formatRelativeTime(time);

        expect(formatted, 'agora mesmo');
      });
    });

    group('getStalenessLevel', () {
      test('returns fresh for very recent timestamps', () {
        final time = DateTime.now().subtract(const Duration(seconds: 30));
        final level = StalenessChecker.getStalenessLevel(time);

        expect(level, StalenessLevel.fresh);
      });

      test('returns slightlyStale for timestamps between thresholds', () {
        final time = DateTime.now().subtract(const Duration(minutes: 3));
        final level = StalenessChecker.getStalenessLevel(time);

        expect(level, StalenessLevel.slightlyStale);
      });

      test('returns veryStale for old timestamps', () {
        final time = DateTime.now().subtract(const Duration(minutes: 10));
        final level = StalenessChecker.getStalenessLevel(time);

        expect(level, StalenessLevel.veryStale);
      });

      test('returns unknown for null timestamp', () {
        final level = StalenessChecker.getStalenessLevel(null);

        expect(level, StalenessLevel.unknown);
      });

      test('respects custom thresholds', () {
        final time = DateTime.now().subtract(const Duration(seconds: 45));

        // With default thresholds (1 min fresh, 5 min stale)
        final defaultLevel = StalenessChecker.getStalenessLevel(time);
        expect(defaultLevel, StalenessLevel.fresh);

        // With custom thresholds (30s fresh, 2 min stale)
        final customLevel = StalenessChecker.getStalenessLevel(
          time,
          freshnessThreshold: const Duration(seconds: 30),
          stalenessThreshold: const Duration(minutes: 2),
        );
        expect(customLevel, StalenessLevel.slightlyStale);
      });
    });

    group('formatAbsoluteTime', () {
      test('formats date and time correctly', () {
        final time = DateTime(2026, 1, 16, 20, 30, 45);
        final formatted = StalenessChecker.formatAbsoluteTime(time);

        expect(formatted, '16/01/2026 20:30:45');
      });

      test('formats date only when requested', () {
        final time = DateTime(2026, 1, 16, 20, 30, 45);
        final formatted = StalenessChecker.formatAbsoluteTime(
          time,
          includeTime: false,
        );

        expect(formatted, '16/01/2026');
      });

      test('handles null timestamp', () {
        final formatted = StalenessChecker.formatAbsoluteTime(null);
        expect(formatted, 'N/A');
      });

      test('handles single-digit day and month with leading zeros', () {
        final time = DateTime(2026, 3, 5, 9, 5, 7);
        final formatted = StalenessChecker.formatAbsoluteTime(time);

        expect(formatted, '05/03/2026 09:05:07');
      });
    });

    group('Integration tests', () {
      test('staleness workflow: fresh → slightly stale → very stale', () {
        // Fresh
        var time = DateTime.now().subtract(const Duration(seconds: 30));
        expect(StalenessChecker.getStalenessLevel(time), StalenessLevel.fresh);
        expect(StalenessChecker.isStale(time), false);

        // Slightly stale
        time = DateTime.now().subtract(const Duration(minutes: 3));
        expect(
          StalenessChecker.getStalenessLevel(time),
          StalenessLevel.slightlyStale,
        );
        expect(StalenessChecker.isStale(time), false);

        // Very stale
        time = DateTime.now().subtract(const Duration(minutes: 10));
        expect(
          StalenessChecker.getStalenessLevel(time),
          StalenessLevel.veryStale,
        );
        expect(StalenessChecker.isStale(time), true);
      });
    });
  });
}
