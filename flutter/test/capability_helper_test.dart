import 'package:flutter_test/flutter_test.dart';
import 'package:cii/core/domain/enums/device_capability.dart';
import 'package:cii/core/utils/capability_helper.dart';

void main() {
  group('CapabilityHelper', () {
    group('parseCapabilities', () {
      test('parses valid JSON array', () {
        final json = '["OTA", "RESTART", "CONFIG"]';
        final capabilities = CapabilityHelper.parseCapabilities(json);

        expect(capabilities.length, 3);
        expect(capabilities, contains(DeviceCapability.ota));
        expect(capabilities, contains(DeviceCapability.restart));
        expect(capabilities, contains(DeviceCapability.config));
      });

      test('parses comma-separated string', () {
        final capabilities = CapabilityHelper.parseCapabilities(
          'OTA,RESTART,CONFIG',
        );

        expect(capabilities.length, 3);
        expect(capabilities, contains(DeviceCapability.ota));
        expect(capabilities, contains(DeviceCapability.restart));
      });

      test('parses semicolon-separated string', () {
        final capabilities = CapabilityHelper.parseCapabilities(
          'OTA;RESTART;CONFIG',
        );

        expect(capabilities.length, 3);
        expect(capabilities, contains(DeviceCapability.ota));
      });

      test('parses single capability string', () {
        final capabilities = CapabilityHelper.parseCapabilities('OTA');

        expect(capabilities.length, 1);
        expect(capabilities.first, DeviceCapability.ota);
      });

      test('handles null input', () {
        final capabilities = CapabilityHelper.parseCapabilities(null);
        expect(capabilities, isEmpty);
      });

      test('handles empty string', () {
        final capabilities = CapabilityHelper.parseCapabilities('');
        expect(capabilities, isEmpty);
      });

      test('ignores invalid capabilities', () {
        final json = '["OTA", "INVALID_CAPABILITY", "RESTART"]';
        final capabilities = CapabilityHelper.parseCapabilities(json);

        expect(capabilities.length, 2);
        expect(capabilities, contains(DeviceCapability.ota));
        expect(capabilities, contains(DeviceCapability.restart));
      });

      test('is case-insensitive', () {
        final capabilities = CapabilityHelper.parseCapabilities(
          'ota,RESTART,CoNfIg',
        );

        expect(capabilities.length, 3);
        expect(capabilities, contains(DeviceCapability.ota));
      });

      test('handles whitespace in comma-separated', () {
        final capabilities = CapabilityHelper.parseCapabilities(
          'OTA , RESTART , CONFIG',
        );

        expect(capabilities.length, 3);
      });
    });

    group('hasCapability', () {
      const capabilitiesJson = '["OTA", "RESTART", "CONFIG"]';

      test('returns true when capability exists', () {
        expect(
          CapabilityHelper.hasCapability(
            capabilitiesJson,
            DeviceCapability.ota,
          ),
          true,
        );
      });

      test('returns false when capability does not exist', () {
        expect(
          CapabilityHelper.hasCapability(
            capabilitiesJson,
            DeviceCapability.waterControl,
          ),
          false,
        );
      });

      test('returns false for null capabilities', () {
        expect(
          CapabilityHelper.hasCapability(null, DeviceCapability.ota),
          false,
        );
      });
    });

    group('hasAllCapabilities', () {
      const capabilitiesJson = '["OTA", "RESTART", "CONFIG", "SENSORS"]';

      test('returns true when all required capabilities exist', () {
        expect(
          CapabilityHelper.hasAllCapabilities(capabilitiesJson, [
            DeviceCapability.ota,
            DeviceCapability.restart,
          ]),
          true,
        );
      });

      test('returns false when some capabilities are missing', () {
        expect(
          CapabilityHelper.hasAllCapabilities(capabilitiesJson, [
            DeviceCapability.ota,
            DeviceCapability.waterControl,
          ]),
          false,
        );
      });

      test('returns true for empty required list', () {
        expect(CapabilityHelper.hasAllCapabilities(capabilitiesJson, []), true);
      });

      test('returns false for null capabilities', () {
        expect(
          CapabilityHelper.hasAllCapabilities(null, [DeviceCapability.ota]),
          false,
        );
      });
    });

    group('hasAnyCapability', () {
      const capabilitiesJson = '["OTA", "RESTART"]';

      test('returns true when at least one capability exists', () {
        expect(
          CapabilityHelper.hasAnyCapability(capabilitiesJson, [
            DeviceCapability.ota,
            DeviceCapability.waterControl,
          ]),
          true,
        );
      });

      test('returns false when no capabilities match', () {
        expect(
          CapabilityHelper.hasAnyCapability(capabilitiesJson, [
            DeviceCapability.waterControl,
            DeviceCapability.lights,
          ]),
          false,
        );
      });

      test('returns false for empty anyOf list', () {
        expect(CapabilityHelper.hasAnyCapability(capabilitiesJson, []), false);
      });
    });

    group('toJson', () {
      test('converts capabilities list to JSON array', () {
        final capabilities = [
          DeviceCapability.ota,
          DeviceCapability.restart,
          DeviceCapability.config,
        ];
        final json = CapabilityHelper.toJson(capabilities);

        expect(json, '["OTA","RESTART","CONFIG"]');
      });

      test('converts empty list to empty JSON array', () {
        final json = CapabilityHelper.toJson([]);
        expect(json, '[]');
      });
    });

    group('getCapabilityDescription', () {
      test('returns correct Portuguese description for OTA', () {
        expect(
          CapabilityHelper.getCapabilityDescription(DeviceCapability.ota),
          'Atualização Over-The-Air',
        );
      });

      test('returns correct description for restart', () {
        expect(
          CapabilityHelper.getCapabilityDescription(DeviceCapability.restart),
          'Reinicialização Remota',
        );
      });

      test('returns correct description for all capabilities', () {
        for (final capability in DeviceCapability.values) {
          final description = CapabilityHelper.getCapabilityDescription(
            capability,
          );
          expect(description, isNotEmpty);
          expect(description, isNot(contains('null')));
        }
      });
    });

    group('formatCapabilitiesList', () {
      test('formats capabilities list correctly', () {
        const json = '["OTA", "RESTART"]';
        final formatted = CapabilityHelper.formatCapabilitiesList(json);

        expect(formatted, contains('Atualização Over-The-Air'));
        expect(formatted, contains('Reinicialização Remota'));
        expect(formatted, contains(', '));
      });

      test('returns message for empty capabilities', () {
        final formatted = CapabilityHelper.formatCapabilitiesList('[]');
        expect(formatted, 'Nenhuma capability');
      });

      test('returns message for null capabilities', () {
        final formatted = CapabilityHelper.formatCapabilitiesList(null);
        expect(formatted, 'Nenhuma capability');
      });
    });

    group('isValidCapabilitiesJson', () {
      test('returns true for valid JSON array', () {
        expect(
          CapabilityHelper.isValidCapabilitiesJson('["OTA", "RESTART"]'),
          true,
        );
      });

      test('returns true for comma-separated string', () {
        expect(CapabilityHelper.isValidCapabilitiesJson('OTA,RESTART'), true);
      });

      test('returns true for null', () {
        expect(CapabilityHelper.isValidCapabilitiesJson(null), true);
      });

      test('returns true for empty string', () {
        expect(CapabilityHelper.isValidCapabilitiesJson(''), true);
      });

      test('returns true even with invalid capability names', () {
        // Invalid names are just ignored, not a parsing error
        expect(
          CapabilityHelper.isValidCapabilitiesJson('["OTA", "INVALID"]'),
          true,
        );
      });
    });

    group('DeviceCapability enum', () {
      test('fromString returns correct capability', () {
        expect(DeviceCapability.fromString('OTA'), DeviceCapability.ota);
        expect(
          DeviceCapability.fromString('RESTART'),
          DeviceCapability.restart,
        );
        expect(DeviceCapability.fromString('CONFIG'), DeviceCapability.config);
      });

      test('fromString is case-insensitive', () {
        expect(DeviceCapability.fromString('ota'), DeviceCapability.ota);
        expect(DeviceCapability.fromString('OtA'), DeviceCapability.ota);
      });

      test('fromString returns null for invalid capability', () {
        expect(DeviceCapability.fromString('INVALID'), isNull);
        expect(DeviceCapability.fromString(''), isNull);
      });

      test('fromStringList filters out invalid values', () {
        final capabilities = DeviceCapability.fromStringList([
          'OTA',
          'INVALID',
          'RESTART',
          '',
        ]);

        expect(capabilities.length, 2);
        expect(capabilities, contains(DeviceCapability.ota));
        expect(capabilities, contains(DeviceCapability.restart));
      });

      test('toJson returns correct value', () {
        expect(DeviceCapability.ota.toJson(), 'OTA');
        expect(DeviceCapability.restart.toJson(), 'RESTART');
      });

      test('toString returns correct value', () {
        expect(DeviceCapability.ota.toString(), 'OTA');
      });

      test('all capabilities have unique values', () {
        final values = DeviceCapability.values.map((c) => c.value).toSet();
        expect(values.length, DeviceCapability.values.length);
      });
    });

    group('Integration tests', () {
      test('full workflow: parse, check, format', () {
        const json = '["OTA", "RESTART", "SENSORS"]';

        // Parse
        final capabilities = CapabilityHelper.parseCapabilities(json);
        expect(capabilities.length, 3);

        // Check single
        expect(
          CapabilityHelper.hasCapability(json, DeviceCapability.ota),
          true,
        );
        expect(
          CapabilityHelper.hasCapability(json, DeviceCapability.waterControl),
          false,
        );

        // Check multiple
        expect(
          CapabilityHelper.hasAllCapabilities(json, [
            DeviceCapability.ota,
            DeviceCapability.sensors,
          ]),
          true,
        );

        // Format
        final formatted = CapabilityHelper.formatCapabilitiesList(json);
        expect(formatted, contains('Atualização'));
        expect(formatted, contains('Sensores'));
      });

      test('device with no capabilities', () {
        const json = '[]';

        expect(CapabilityHelper.parseCapabilities(json), isEmpty);
        expect(
          CapabilityHelper.hasCapability(json, DeviceCapability.ota),
          false,
        );
        expect(
          CapabilityHelper.formatCapabilitiesList(json),
          'Nenhuma capability',
        );
      });
    });
  });
}
