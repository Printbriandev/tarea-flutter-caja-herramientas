import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Últimas 3 noticias de TechCrunch, un sitio hecho con WordPress.
/// API REST de WordPress: https://techcrunch.com/wp-json/wp/v2/posts?per_page=3
class WordpressScreen extends StatefulWidget {
  const WordpressScreen({super.key});

  @override
  State<WordpressScreen> createState() => _WordpressScreenState();
}

class _WordpressScreenState extends State<WordpressScreen> {
  static const _site = 'techcrunch.com';
  static const _logo =
      'https://techcrunch.com/wp-content/uploads/2015/02/cropped-cropped-favicon-gradient.png';

  bool _loading = true;
  String? _error;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.https(_site, '/wp-json/wp/v2/posts', {
        'per_page': '3',
        '_fields': 'id,date,link,title,excerpt',
      });
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}');
      }
      setState(() => _posts = jsonDecode(res.body));
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar las noticias: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// WordPress devuelve HTML (<p>, &#8217;, ...). Lo convertimos a texto plano.
  String _plainText(String htmlText) =>
      html.parseFragment(htmlText).text?.trim() ?? '';

  Future<void> _visit(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias WordPress')),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(_logo, height: 110),
              ),
            ),
            const SizedBox(height: 8),
            const Text('TechCrunch',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Últimas 3 noticias publicadas',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null) Text(_error!, textAlign: TextAlign.center),
            for (final post in _posts)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_plainText(post['title']['rendered']),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat("d 'de' MMMM 'de' y, h:mm a", 'es')
                            .format(DateTime.parse(post['date'])),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_plainText(post['excerpt']['rendered'])),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _visit(post['link']),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Visitar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
