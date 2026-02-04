import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Casa Inteligente V2.4',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Modular.to.navigate('/'),
          ),
          ListTile(
            leading: const Icon(Icons.water),
            title: const Text('Água'),
            onTap: () => Modular.to.navigate(
              '/cisterna',
            ), // Assuming cisterna/water route
          ),
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: const Text('Ambiente'),
            onTap: () =>
                Modular.to.navigate('/cozinha'), // Example environment route
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Dispositivos'),
            onTap: () => Modular.to.navigate('/devices/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () => Modular.to.navigate('/settings/'),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Ferramentas Dev'),
            onTap: () => Modular.to.navigate('/dev/'),
          ),
        ],
      ),
    );
  }
}
