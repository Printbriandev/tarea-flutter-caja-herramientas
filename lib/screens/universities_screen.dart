import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Lista las universidades de un país (nombre en inglés).
/// API: https://adamix.net/proxy.php?country=Dominican+Republic
class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  final _countryController = TextEditingController(text: 'Dominican Republic');
  bool _loading = false;
  String? _error;
  List<dynamic> _universities = [];

  Future<void> _search() async {
    final country = _countryController.text.trim();
    if (country.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
      _universities = [];
    });

    try {
      final uri = Uri.https('adamix.net', '/proxy.php', {'country': country});
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as List<dynamic>;
      setState(() {
        _universities = data;
        if (data.isEmpty) {
          _error = 'No se encontraron universidades para "$country".\n'
              'Recuerda escribir el país en inglés.';
        }
      });
    } catch (e) {
      setState(() => _error = 'No se pudo consultar la API: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openWeb(String url) async {
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo abrir $url')));
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universidades')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'País (en inglés)',
                      hintText: 'Ej: Dominican Republic',
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
          ),
          if (_universities.isNotEmpty)
            Text('${_universities.length} universidades encontradas'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _universities.length,
                        itemBuilder: (context, i) {
                          final uni = _universities[i];
                          final domains = List<String>.from(uni['domains'] ?? []);
                          final webPages =
                              List<String>.from(uni['web_pages'] ?? []);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(uni['name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Dominio: ${domains.join(', ')}'),
                                  for (final page in webPages)
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
                                      onPressed: () => _openWeb(page),
                                      icon: const Icon(Icons.open_in_new,
                                          size: 18),
                                      label: Text(page),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
