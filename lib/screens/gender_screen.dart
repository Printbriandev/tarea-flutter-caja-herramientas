import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Predice el género de un nombre con https://api.genderize.io
/// Masculino -> pantalla azul, femenino -> pantalla rosa.
class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _gender; // 'male', 'female' o null
  double _probability = 0;
  String _name = '';

  static const _blue = Color(0xFF64B5F6);
  static const _pink = Color(0xFFF48FB1);

  Future<void> _predict() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
      _gender = null;
    });

    try {
      final uri = Uri.https('api.genderize.io', '/', {'name': name});
      final res = await http.get(uri);
      if (res.statusCode == 429) {
        throw Exception(
            'Se alcanzó el límite diario gratuito de genderize.io. Intenta más tarde.');
      }
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}');
      }
      final data = jsonDecode(res.body);
      setState(() {
        _name = name;
        _gender = data['gender'];
        _probability = (data['probability'] ?? 0).toDouble();
        if (_gender == null) _error = 'No se pudo predecir el género de "$name".';
      });
    } catch (e) {
      setState(() => _error = 'No se pudo consultar la API: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _gender == 'male';
    final background = _gender == null
        ? Theme.of(context).colorScheme.surface
        : (isMale ? _blue : _pink);

    return Scaffold(
      appBar: AppBar(title: const Text('Predecir género')),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la persona',
                hintText: 'Ej: Irma',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _predict(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _predict,
              icon: const Icon(Icons.search),
              label: const Text('Predecir'),
            ),
            const SizedBox(height: 32),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
            if (_gender != null) ...[
              Icon(isMale ? Icons.male : Icons.female,
                  size: 160, color: Colors.white),
              Text(
                _name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                isMale ? 'Masculino' : 'Femenino',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              Text(
                'Probabilidad: ${(_probability * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
