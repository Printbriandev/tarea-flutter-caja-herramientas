import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Busca un Pokémon en https://pokeapi.co y muestra su foto,
/// experiencia base, habilidades y reproduce su sonido (cries.latest).
class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final _nameController = TextEditingController(text: 'pikachu');
  final _player = AudioPlayer();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _pokemon;

  Future<void> _search() async {
    final name = _nameController.text.trim().toLowerCase();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
      _pokemon = null;
    });

    try {
      final res = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
      if (res.statusCode == 404) {
        throw Exception('No existe un Pokémon llamado "$name".');
      }
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}');
      }
      setState(() => _pokemon = jsonDecode(res.body));
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _playCry() async {
    final url = _pokemon?['cries']?['latest'];
    if (url == null) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo reproducir el sonido: $e')));
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  void dispose() {
    _nameController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = _pokemon;
    final image = pokemon?['sprites']?['other']?['official-artwork']
            ?['front_default'] ??
        pokemon?['sprites']?['front_default'];

    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Pokémon',
                    hintText: 'Ej: pikachu',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null) Text(_error!, textAlign: TextAlign.center),
          if (pokemon != null) ...[
            Text(
              _capitalize(pokemon['name']),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            if (image != null) Image.network(image, height: 240),
            Card(
              child: ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Experiencia base'),
                trailing: Text('${pokemon['base_experience'] ?? '—'}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Habilidades',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final a in pokemon['abilities'])
                          Chip(
                            label: Text(_capitalize(a['ability']['name'])),
                            avatar: a['is_hidden'] == true
                                ? const Icon(Icons.visibility_off, size: 16)
                                : null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: pokemon['cries']?['latest'] == null ? null : _playCry,
              icon: const Icon(Icons.volume_up),
              label: const Text('Escuchar sonido'),
            ),
          ],
        ],
      ),
    );
  }
}
