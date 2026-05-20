import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class GymMapScreen extends StatefulWidget {
  const GymMapScreen({super.key});

  @override
  State<GymMapScreen> createState() => _GymMapScreenState();
}

class _GymMapScreenState extends State<GymMapScreen> {
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(40.4168, -3.7038);
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _gimnasios = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _gimnasios = [];
    });

    try {
      final position = await _getLocation();
      if (position == null) return;

      final location = LatLng(position.latitude, position.longitude);
      final gyms = await _buscarGimnasios(location);

      if (!mounted) return;
      setState(() {
        _center = location;
        _gimnasios = gyms;
        _isLoading = false;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _mapController.move(_center, 13);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el mapa.';
        _isLoading = false;
      });
    }
  }

  Future<Position?> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() {
        _error = 'GPS desactivado. Actívalo para ver gimnasios cercanos.';
        _isLoading = false;
      });
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) setState(() {
        _error = 'Permiso de ubicación denegado.';
        _isLoading = false;
      });
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  }

  // Distancia real en metros usando fórmula de Haversine
  double _distanciaMetros(LatLng a, LatLng b) {
    const R = 6371000.0;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final x = sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLng * sinDLng;
    return R * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  String _formatDistancia(double metros) {
    if (metros < 1000) return '${metros.toInt()} m';
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }

  Future<List<Map<String, dynamic>>> _buscarGimnasios(LatLng location) async {
    final lat = location.latitude;
    final lng = location.longitude;

    // Query amplia con todos los tipos de gimnasio y radio de 5km
    final query = '''
[out:json][timeout:15];
(
  node["leisure"="fitness_centre"](around:5000,$lat,$lng);
  node["amenity"="gym"](around:5000,$lat,$lng);
  node["leisure"="sports_centre"]["sport"="fitness"](around:5000,$lat,$lng);
  way["leisure"="fitness_centre"](around:5000,$lat,$lng);
  way["amenity"="gym"](around:5000,$lat,$lng);
);
out center 30;
''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=${Uri.encodeComponent(query)}',
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        if (elements.isNotEmpty) {
          final List<Map<String, dynamic>> gyms = [];

          for (final e in elements) {
            final tags = e['tags'] ?? {};
            final nombre = tags['name'];
            if (nombre == null || nombre.toString().trim().isEmpty) continue;

            // Coordenadas — nodes tienen lat/lon directo, ways tienen center
            double? lat2, lng2;
            if (e['type'] == 'node') {
              lat2 = (e['lat'] as num?)?.toDouble();
              lng2 = (e['lon'] as num?)?.toDouble();
            } else if (e['center'] != null) {
              lat2 = (e['center']['lat'] as num?)?.toDouble();
              lng2 = (e['center']['lon'] as num?)?.toDouble();
            }
            if (lat2 == null || lng2 == null) continue;

            final gymLocation = LatLng(lat2, lng2);
            final distancia = _distanciaMetros(location, gymLocation);

            // Construir dirección
            final street = tags['addr:street'] ?? '';
            final number = tags['addr:housenumber'] ?? '';
            final city = tags['addr:city'] ?? '';
            String direccion = '';
            if (street.isNotEmpty) {
              direccion = street;
              if (number.isNotEmpty) direccion += ' $number';
              if (city.isNotEmpty) direccion += ', $city';
            }
            if (direccion.isEmpty) {
              direccion = _formatDistancia(distancia) + ' de distancia';
            }

            // Rating basado en si tiene web, teléfono, horario (más datos = más fiable)
            double rating = 4.0;
            if (tags['website'] != null || tags['contact:website'] != null) rating += 0.2;
            if (tags['phone'] != null || tags['contact:phone'] != null) rating += 0.1;
            if (tags['opening_hours'] != null) rating += 0.2;
            rating = double.parse(rating.toStringAsFixed(1));

            gyms.add({
              'nombre': nombre.toString(),
              'direccion': direccion,
              'distancia': distancia,
              'distanciaTexto': _formatDistancia(distancia),
              'rating': rating,
              'lat': lat2,
              'lng': lng2,
            });
          }

          if (gyms.isNotEmpty) {
            // Ordenar por distancia real
            gyms.sort((a, b) =>
                (a['distancia'] as double).compareTo(b['distancia'] as double));

            // Devolver top 5
            return gyms.take(5).toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Overpass error: $e');
    }

    // Si no hay resultados reales, mostrar mensaje
    if (mounted) {
      setState(() => _error = 'No se encontraron gimnasios en 5km. Mostrando zona.');
    }
    return [];
  }

  Color _medallaColor(int i) {
    if (i == 0) return const Color(0xFFFFD700);
    if (i == 1) return const Color(0xFFC0C0C0);
    if (i == 2) return const Color(0xFFCD7F32);
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title:  Text("GIMNASIOS CERCANOS",
            style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                fontSize: 16)),
        actions: [
          IconButton(
            icon:  Icon(Icons.refresh, color: AppColors.accent),
            onPressed: _init,
            tooltip: "Actualizar",
          ),
        ],
      ),
      body: _isLoading
          ?  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                color: AppColors.accent, strokeWidth: 2),
            SizedBox(height: 16),
            Text("Buscando gimnasios cercanos...",
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 6),
            Text("Buscando en un radio de 5km",
                style: TextStyle(
                    color: AppColors.textHint, fontSize: 11)),
          ],
        ),
      )
          : Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              color: AppColors.accent.withOpacity(0.1),
              child: Row(children: [
                 Icon(Icons.info_outline,
                    color: AppColors.accent, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!,
                      style:  TextStyle(
                          color: AppColors.accent, fontSize: 11)),
                ),
              ]),
            ),

          // MAPA
          SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags:
                  InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.realsteel',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    // Marcador usuario
                    Marker(
                      point: _center,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    // Marcadores gimnasios
                    ..._gimnasios.asMap().entries.map((entry) {
                      final i = entry.key;
                      final g = entry.value;
                      final color = _medallaColor(i);
                      return Marker(
                        point: LatLng(g['lat'], g['lng']),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () {
                            _mapController.move(
                                LatLng(g['lat'], g['lng']), 16);
                            RS.info(context, '${g['nombre']} · ${g['distanciaTexto']}');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // TÍTULO TOP 5
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(
                _gimnasios.isEmpty
                    ? "SIN GIMNASIOS ENCONTRADOS"
                    : "TOP ${_gimnasios.length} GIMNASIOS CERCANOS",
                style:  TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5),
              ),
            ]),
          ),

          // LISTA
          Expanded(
            child: _gimnasios.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.location_off,
                      color: AppColors.textHint, size: 48),
                  const SizedBox(height: 12),
                   Text("No hay gimnasios en 5km",
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _init,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Reintentar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: _gimnasios.length,
              itemBuilder: (_, i) {
                final g = _gimnasios[i];
                final color = _medallaColor(i);
                return GestureDetector(
                  onTap: () => _mapController.move(
                      LatLng(g['lat'], g['lng']), 16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      // Medalla
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(g['nombre'],
                                style:  TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(g['direccion'],
                                style:  TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Row(children: [
                               Icon(Icons.directions_walk,
                                  color: AppColors.accent,
                                  size: 11),
                              const SizedBox(width: 3),
                              Text(g['distanciaTexto'],
                                  style:  TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 11,
                                      fontWeight:
                                      FontWeight.w600)),
                            ]),
                          ],
                        ),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                          AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFD700), size: 13),
                          const SizedBox(width: 3),
                          Text('${g['rating']}',
                              style:  TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                        ]),
                      ),
                    ]),
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