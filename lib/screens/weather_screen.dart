import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Clima de hoy en Santo Domingo, República Dominicana.
/// API gratuita y sin llave: https://open-meteo.com
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '18.4861',
        'longitude': '-69.9312',
        'current':
            'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset',
        'timezone': 'America/Santo_Domingo',
        'forecast_days': '1',
      });
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}');
      }
      setState(() => _data = jsonDecode(res.body));
    } catch (e) {
      setState(() => _error = 'No se pudo obtener el clima: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Traduce el código WMO de Open-Meteo a texto e ícono.
  (String, IconData) _describe(int code) {
    if (code == 0) return ('Despejado', Icons.wb_sunny);
    if (code <= 2) return ('Parcialmente nublado', Icons.wb_cloudy);
    if (code == 3) return ('Nublado', Icons.cloud);
    if (code <= 48) return ('Neblina', Icons.foggy);
    if (code <= 57) return ('Llovizna', Icons.grain);
    if (code <= 67) return ('Lluvia', Icons.water_drop);
    if (code <= 77) return ('Nieve', Icons.ac_unit);
    if (code <= 82) return ('Aguaceros', Icons.umbrella);
    return ('Tormenta eléctrica', Icons.thunderstorm);
  }

  Widget _info(IconData icon, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
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
      final current = _data!['current'];
      final daily = _data!['daily'];
      final today = DateTime.parse(daily['time'][0]);
      final (todayText, todayIcon) = _describe(daily['weather_code'][0]);
      final (nowText, _) = _describe(current['weather_code']);
      final sunrise = DateFormat.Hm().format(DateTime.parse(daily['sunrise'][0]));
      final sunset = DateFormat.Hm().format(DateTime.parse(daily['sunset'][0]));
      final date = DateFormat("EEEE d 'de' MMMM 'de' y", 'es').format(today);

      body = RefreshIndicator(
        onRefresh: _loadWeather,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Santo Domingo, RD',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(date[0].toUpperCase() + date.substring(1)),
                    const SizedBox(height: 8),
                    Icon(todayIcon, size: 96),
                    Text('${current['temperature_2m'].round()}°C',
                        style: const TextStyle(
                            fontSize: 56, fontWeight: FontWeight.bold)),
                    Text('Ahora: $nowText'),
                    Text('Pronóstico del día: $todayText',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95,
              children: [
                _info(Icons.arrow_upward, 'Máxima',
                    '${daily['temperature_2m_max'][0].round()}°C'),
                _info(Icons.arrow_downward, 'Mínima',
                    '${daily['temperature_2m_min'][0].round()}°C'),
                _info(Icons.thermostat, 'Sensación',
                    '${current['apparent_temperature'].round()}°C'),
                _info(Icons.umbrella, 'Prob. lluvia',
                    '${daily['precipitation_probability_max'][0]}%'),
                _info(Icons.water_drop, 'Humedad',
                    '${current['relative_humidity_2m']}%'),
                _info(Icons.air, 'Viento',
                    '${current['wind_speed_10m'].round()} km/h'),
                _info(Icons.wb_twilight, 'Amanecer', sunrise),
                _info(Icons.nights_stay, 'Atardecer', sunset),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Datos: Open-Meteo.com',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Clima en RD')),
      body: body,
    );
  }
}
