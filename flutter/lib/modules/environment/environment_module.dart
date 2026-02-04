import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/modules/environment/presentation/pages/kitchen_page.dart';
import 'package:cii/modules/environment/presentation/pages/environment_tab_content.dart';

class EnvironmentModule extends Module {
  @override
  void routes(r) {
    r.child('/kitchen', child: (_) => const KitchenPage());
    r.child('/tabs', child: (_) => const EnvironmentTabContent());
  }
}
