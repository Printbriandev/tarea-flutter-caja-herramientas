import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Acerca de: mi foto y datos de contacto para posibles trabajos.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 90,
              backgroundImage: AssetImage('assets/foto.jpg'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Brian Amaury Guzman Mañon',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Estudiante de Desarrollo de Software - ITLA\nMatrícula: 2024-1286',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Disponible para trabajos de desarrollo móvil y web.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Correo'),
                  subtitle: const Text('guzmanmanonbrian@gmail.com'),
                  onTap: () => _open('mailto:guzmanmanonbrian@gmail.com'),
                ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Correo institucional'),
                  subtitle: const Text('20241286@itla.edu.do'),
                  onTap: () => _open('mailto:20241286@itla.edu.do'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('GitHub'),
                  subtitle: const Text('github.com/Printbriandev'),
                  onTap: () => _open('https://github.com/Printbriandev'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
