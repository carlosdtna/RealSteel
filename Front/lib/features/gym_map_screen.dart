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

  LatLng _center = const LatLng(38.9167, -6.3500); // Mérida por defecto
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

    // Mostrar Mérida en el mapa mientras se obtiene la ubicación real
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _mapController.move(_center, 13);

    try {
      final position = await _getLocation();

      final location = position != null
          ? LatLng(position.latitude, position.longitude)
          : _center; // Si no hay GPS usamos Mérida

      final gyms = await _buscarGimnasios(location);

      if (!mounted) return;
      setState(() {
        _center = location;
        _gimnasios = gyms;
        _isLoading = false;
      });
      _mapController.move(_center, 13);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el mapa.';
        _isLoading = false;
      });
    }
  }

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint("=== UBICACION: ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      debugPrint("=== GPS error: $e");
      return null;
    }
  }

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
    final gyms = <Map<String, dynamic>>[];
    final idsVistos = <String>{};

    // ── Overpass API ─────────────────────────────────────────────
    try {
      final query =
          '[out:json][timeout:25];'
          '('
          'node["leisure"="fitness_centre"](around:5000,$lat,$lng);'
          'node["amenity"="gym"](around:5000,$lat,$lng);'
          'node["leisure"="sports_centre"](around:5000,$lat,$lng);'
          'way["leisure"="fitness_centre"](around:5000,$lat,$lng);'
          'way["amenity"="gym"](around:5000,$lat,$lng);'
          'way["leisure"="sports_centre"](around:5000,$lat,$lng);'
          'relation["leisure"="fitness_centre"](around:5000,$lat,$lng);'
          ');'
          'out center 50;';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=${Uri.encodeComponent(query)}',
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        debugPrint("=== OVERPASS elementos: ${elements.length}");

        for (final e in elements) {
          final tags = e['tags'] as Map<String, dynamic>? ?? {};
          final id = e['id'].toString();
          if (idsVistos.contains(id)) continue;

          double? lat2, lng2;
          if (e['type'] == 'node') {
            lat2 = (e['lat'] as num?)?.toDouble();
            lng2 = (e['lon'] as num?)?.toDouble();
          } else if (e['center'] != null) {
            lat2 = (e['center']['lat'] as num?)?.toDouble();
            lng2 = (e['center']['lon'] as num?)?.toDouble();
          }
          if (lat2 == null || lng2 == null) continue;

          final nombre = (tags['name'] as String?)?.trim() ?? 'Instalación deportiva';
          final street = (tags['addr:street'] as String?) ?? '';
          final number = (tags['addr:housenumber'] as String?) ?? '';
          final city = (tags['addr:city'] as String?) ?? '';
          final distancia = _distanciaMetros(location, LatLng(lat2, lng2));

          String direccion;
          if (street.isNotEmpty) {
            direccion = street;
            if (number.isNotEmpty) direccion += ' $number';
            if (city.isNotEmpty) direccion += ', $city';
          } else {
            direccion = '${_formatDistancia(distancia)} de distancia';
          }

          double rating = 4.0;
          if (tags['website'] != null || tags['contact:website'] != null) rating += 0.3;
          if (tags['phone'] != null || tags['contact:phone'] != null) rating += 0.2;
          if (tags['opening_hours'] != null) rating += 0.3;
          if (tags['addr:street'] != null) rating += 0.1;
          rating = double.parse(min(5.0, rating).toStringAsFixed(1));

          idsVistos.add(id);
          gyms.add({
            'nombre': nombre,
            'direccion': direccion,
            'distancia': distancia,
            'distanciaTexto': _formatDistancia(distancia),
            'rating': rating,
            'lat': lat2,
            'lng': lng2,
          });
        }
      }
    } catch (e) {
      debugPrint('=== Overpass error: $e');
    }

    // ── Nominatim como complemento ───────────────────────────────
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=gimnasio'
            '&format=json'
            '&limit=20'
            '&viewbox=${lng - 0.07},${lat + 0.07},${lng + 0.07},${lat - 0.07}'
            '&bounded=1'
            '&addressdetails=1'
            '&extratags=1',
      );

      final resp = await http.get(url, headers: {
        'User-Agent': 'RealSteelApp/1.0',
        'Accept-Language': 'es',
      }).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        debugPrint("=== NOMINATIM gimnasio: ${data.length} resultados");

        for (final item in data) {
          final osmId = item['osm_id'].toString();
          if (idsVistos.contains(osmId)) continue;

          final latG = double.tryParse(item['lat'].toString());
          final lngG = double.tryParse(item['lon'].toString());
          if (latG == null || lngG == null) continue;

          final distancia = _distanciaMetros(location, LatLng(latG, lngG));
          if (distancia > 5000) continue;

          final displayName = item['display_name'].toString();
          final nombre = displayName.split(',').first.trim();
          if (nombre.isEmpty) continue;

          final address = item['address'] as Map<String, dynamic>? ?? {};
          final road = (address['road'] ?? address['pedestrian'] ?? '') as String;
          final houseNumber = (address['house_number'] ?? '') as String;
          final city = (address['city'] ?? address['town'] ?? address['village'] ?? '') as String;

          String direccion;
          if (road.isNotEmpty) {
            direccion = road;
            if (houseNumber.isNotEmpty) direccion += ' $houseNumber';
            if (city.isNotEmpty) direccion += ', $city';
          } else {
            direccion = '${_formatDistancia(distancia)} de distancia';
          }

          final extratags = item['extratags'] as Map<String, dynamic>? ?? {};
          double rating = 4.0;
          if (extratags['website'] != null) rating += 0.3;
          if (extratags['phone'] != null) rating += 0.2;
          if (extratags['opening_hours'] != null) rating += 0.3;
          rating = double.parse(min(5.0, rating).toStringAsFixed(1));

          idsVistos.add(osmId);
          gyms.add({
            'nombre': nombre,
            'direccion': direccion,
            'distancia': distancia,
            'distanciaTexto': _formatDistancia(distancia),
            'rating': rating,
            'lat': latG,
            'lng': lngG,
          });
        }
      }
    } catch (e) {
      debugPrint('=== Nominatim error: $e');
    }

    debugPrint("=== TOTAL instalaciones encontradas: ${gyms.length}");

    if (gyms.isEmpty) {
      if (mounted) setState(() => _error = 'No se encontraron instalaciones en 5km.');
      return [];
    }

    // Ordenar por rating desc, luego distancia asc
    gyms.sort((a, b) {
      final ratingCmp = (b['rating'] as double).compareTo(a['rating'] as double);
      if (ratingCmp != 0) return ratingCmp;
      return (a['distancia'] as double).compareTo(b['distancia'] as double);
    });

    return gyms;
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
        title: Text(
          "INSTALACIONES CERCANAS",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.accent),
            onPressed: _init,
            tooltip: "Actualizar",
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de carga
          if (_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.accent.withOpacity(0.1),
              child: Row(children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  "Buscando instalaciones en tu zona...",
                  style: TextStyle(color: AppColors.accent, fontSize: 11),
                ),
              ]),
            ),

          // Banner de error
          if (!_isLoading && _error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.accent.withOpacity(0.1),
              child: Row(children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.accent, fontSize: 11),
                  ),
                ),
              ]),
            ),

          // MAPA — siempre visible
          SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
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
                          border: Border.all(color: Colors.white, width: 2),
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
                        point: LatLng(g['lat'] as double, g['lng'] as double),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () {
                            _mapController.move(
                                LatLng(g['lat'] as double, g['lng'] as double),
                                16);
                            RS.info(context,
                                '${g['nombre']} · ${g['distanciaTexto']}');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
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

          // TÍTULO
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isLoading
                    ? "BUSCANDO..."
                    : _gimnasios.isEmpty
                    ? "SIN INSTALACIONES ENCONTRADAS"
                    : "TOP ${_gimnasios.length} INSTALACIONES CERCANAS",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ]),
          ),

          // LISTA
          Expanded(
            child: _isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/robotin.jpg',
                      width: 70, height: 70, fit: BoxFit.contain),
                  const SizedBox(height: 12),
                  Text(
                    "Localizando instalaciones...",
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
                : _gimnasios.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off,
                      color: AppColors.textHint, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "No hay instalaciones en 5km",
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: _gimnasios.length,
              itemBuilder: (_, i) {
                final g = _gimnasios[i];
                final color = _medallaColor(i);
                return GestureDetector(
                  onTap: () => _mapController.move(
                      LatLng(g['lat'] as double, g['lng'] as double),
                      16),
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
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              g['nombre'] as String,
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              g['direccion'] as String,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(children: [
                              Icon(Icons.directions_walk,
                                  color: AppColors.accent, size: 11),
                              const SizedBox(width: 3),
                              Text(
                                g['distanciaTexto'] as String,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFD700), size: 13),
                          const SizedBox(width: 3),
                          Text(
                            '${g['rating']}',
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
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