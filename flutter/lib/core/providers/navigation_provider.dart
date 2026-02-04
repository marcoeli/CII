import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enumeração das abas disponíveis no Bottom Navigation
enum NavigationTab { home, water, environment, events }

/// Notifier para gerenciar a aba ativa
class NavigationTabNotifier extends Notifier<NavigationTab> {
  @override
  NavigationTab build() => NavigationTab.home;

  void setTab(NavigationTab tab) {
    state = tab;
  }
}

/// Provider para gerenciar a aba ativa e permitir controle remoto (Header, Cards)
final navigationTabProvider =
    NotifierProvider<NavigationTabNotifier, NavigationTab>(
      NavigationTabNotifier.new,
    );
