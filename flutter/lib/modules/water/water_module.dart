import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/modules/water/presentation/pages/cisterna_page.dart';
import 'package:cii/modules/water/presentation/pages/water_tank_page.dart';
import 'package:cii/modules/water/presentation/pages/pumps_page.dart';

class WaterModule extends Module {
  @override
  void routes(r) {
    r.child('/cisterna', child: (_) => const CisternaPage());
    r.child('/caixas', child: (_) => const WaterTankPage());
    r.child('/bombas', child: (_) => const PumpsPage());
  }
}
