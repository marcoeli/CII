import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/home/home_module.dart';
import 'package:cii/modules/settings/settings_module.dart';
import 'package:cii/modules/core/core_module.dart';
import 'package:cii/modules/water/water_module.dart';
import 'package:cii/modules/environment/environment_module.dart';
import 'package:cii/modules/events/events_module.dart';
import 'package:cii/modules/dev_tools/dev_tools_module.dart';
import 'package:cii/modules/devices/devices_module.dart';

/// ✅ DEFINITIVO: AppModule recebe ProviderContainer para bridge Riverpod+Modular
class AppModule extends Module {
  final ProviderContainer container;

  AppModule(this.container);

  @override
  List<Module> get imports => [CoreModule(container)];

  @override
  void binds(Injector i) {}

  @override
  void routes(r) {
    r.module('/', module: HomeModule());
    r.module('/water', module: WaterModule());
    r.module('/environment', module: EnvironmentModule());
    r.module('/events', module: EventsModule());
    r.module('/settings', module: SettingsModule());
    r.module('/dev', module: DevToolsModule());
    r.module('/devices', module: DevicesModule());
  }
}
