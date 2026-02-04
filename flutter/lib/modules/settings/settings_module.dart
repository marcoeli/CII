import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/modules/settings/presentation/pages/settings_page.dart';
import 'package:cii/modules/devices/presentation/pages/devices_management_page.dart';
import 'package:cii/modules/devices/presentation/pages/device_setup_page.dart';
import 'package:cii/modules/settings/presentation/pages/home_management_page.dart';
import 'package:cii/modules/settings/presentation/pages/tenant_selector_page.dart';
import 'package:cii/modules/settings/presentation/pages/home_selector_page.dart';

class SettingsModule extends Module {
  @override
  void routes(r) {
    // Default route shows the settings page
    r.child(
      '/',
      child: (_) => const SettingsPage(),
      transition: TransitionType.rightToLeft,
    );
    // Additional settings pages can be added here
    r.child('/devices', child: (_) => const DevicesManagementPage());
    r.child('/setup', child: (_) => const DeviceSetupPage());
    r.child('/context', child: (_) => const HomeManagementPage());
    r.child('/tenant-selector', child: (_) => const TenantSelectorPage());
    r.child('/home-selector', child: (_) => const HomeSelectorPage());
  }
}
