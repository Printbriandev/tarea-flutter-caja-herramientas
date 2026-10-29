// Brian Amaury Guzman Mañon - Matrícula: 2024-1286
// Tarea: App "Caja de Herramientas" en Flutter
// Introducción al Desarrollo de Aplicaciones Móviles - ITLA

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/about_screen.dart';
import 'screens/gender_screen.dart';
import 'screens/pokemon_screen.dart';
import 'screens/random_user_screen.dart';
import 'screens/universities_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/wordpress_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fechas en español (clima, fecha de nacimiento, noticias)
  await initializeDateFormatting('es');
  runApp(const ToolboxApp());
}

class ToolboxApp extends StatelessWidget {
  const ToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caja de Herramientas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D5524)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Una herramienta de la caja: título, ícono y la pantalla que abre.
class _Tool {
  final String title;
  final IconData icon;
  final Widget screen;

  const _Tool(this.title, this.icon, this.screen);
}

const _tools = [
  _Tool('Predecir género', Icons.wc, GenderScreen()),
  _Tool('Persona aleatoria', Icons.person_search, RandomUserScreen()),
  _Tool('Universidades', Icons.school, UniversitiesScreen()),
  _Tool('Clima en RD', Icons.wb_sunny, WeatherScreen()),
  _Tool('Pokémon', Icons.catching_pokemon, PokemonScreen()),
  _Tool('Noticias WordPress', Icons.newspaper, WordpressScreen()),
  _Tool('Acerca de', Icons.info_outline, AboutScreen()),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja de Herramientas'),
        backgroundColor: colors.primaryContainer,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colors.primaryContainer),
              child: const Row(
                children: [
                  Icon(Icons.handyman, size: 48),
                  SizedBox(width: 12),
                  Text('Herramientas',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            for (final tool in _tools)
              ListTile(
                leading: Icon(tool.icon),
                title: Text(tool.title),
                onTap: () {
                  Navigator.pop(context); // cierra el menú
                  _open(context, tool.screen);
                },
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/toolbox.jpg', fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(
            'Una app, muchas herramientas.\nElige una para comenzar:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              for (final tool in _tools)
                Card(
                  color: colors.secondaryContainer,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _open(context, tool.screen),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tool.icon, size: 36),
                        const SizedBox(height: 8),
                        Text(tool.title, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
