import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Muestra una persona aleatoria de https://randomuser.me
class RandomUserScreen extends StatefulWidget {
  const RandomUserScreen({super.key});

  @override
  State<RandomUserScreen> createState() => _RandomUserScreenState();
}

class _RandomUserScreenState extends State<RandomUserScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res =
          await http.get(Uri.parse('https://randomuser.me/api/?results=1'));
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}');
      }
      final data = jsonDecode(res.body);
      setState(() => _user = data['results'][0]);
    } catch (e) {
      setState(() => _error = 'No se pudo obtener la persona: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text(_error!, textAlign: TextAlign.center));
    } else {
      final user = _user!;
      final birth = DateTime.parse(user['dob']['date']).toLocal();
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(user['picture']['large']),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _row(Icons.badge, 'Nombre', user['name']['first']),
                _row(Icons.badge_outlined, 'Apellido', user['name']['last']),
                _row(Icons.cake, 'Fecha de nacimiento',
                    DateFormat("d 'de' MMMM 'de' y", 'es').format(birth)),
                _row(Icons.hourglass_bottom, 'Edad', '${user['dob']['age']} años'),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Persona aleatoria')),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _loadUser,
        icon: const Icon(Icons.refresh),
        label: const Text('Otra persona'),
      ),
    );
  }
}
