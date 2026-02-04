import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/modules/dev_tools/presentation/pages/dev_page.dart';
import 'package:cii/modules/dev_tools/presentation/pages/mqtt_inspector_page.dart';

class DevToolsModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (context) => const DevPage());
    r.child('/inspector', child: (context) => const MqttInspectorPage());
  }
}
