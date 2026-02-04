import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/modules/events/presentation/pages/events_tab_content.dart';

class EventsModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const EventsTabContent());
  }
}
