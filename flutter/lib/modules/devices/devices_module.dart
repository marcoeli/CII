import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/modules/devices/presentation/pages/devices_management_page.dart';
import 'package:cii/modules/devices/presentation/pages/device_setup_page.dart';

class DevicesModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (context) => const DevicesManagementPage());
    r.child('/setup', child: (context) => const DeviceSetupPage());
  }
}
