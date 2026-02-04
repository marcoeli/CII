import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/modules/main_scaffold.dart';
import 'package:cii/modules/water/presentation/pages/cisterna_page.dart';
import 'package:cii/modules/water/presentation/pages/water_tank_page.dart';
import 'package:cii/modules/water/presentation/pages/pumps_page.dart';
import 'package:cii/modules/environment/presentation/pages/kitchen_page.dart';

class HomeModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(r) {
    r.child(Modular.initialRoute, child: (_) => const MainScaffold());
    r.child('/cisterna', child: (_) => const CisternaPage());
    r.child('/caixas', child: (_) => const WaterTankPage());
    r.child('/bombas', child: (_) => const PumpsPage());
    r.child('/cozinha', child: (_) => const KitchenPage());
  }
}
