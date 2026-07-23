import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/map_entities.dart';

/// Serviço de pré-cache inteligente para dados geográficos do mapa.
///
/// Ao abrir um período histórico, armazena localmente:
/// - marcadores da região;
/// - coordenadas;
/// - metadados de conexões (Relationship Engine).
///
/// Quando o usuário voltar ao mesmo período, o carregamento é praticamente instantâneo.
class MapCacheService {
  static const String _tag = 'MapCacheService';
  static const String _prefix = 'chronos_map_cache_';
  static const Duration _ttl = Duration(hours: 24);

  /// Cache em memória (fallback e performance).
  final Map<String, _CacheEntry> _memory = {};

  /// Gera chave de cache para um período e região.
  String _key({int? startYear, int? endYear, GeoBounds? bounds}) {
    final parts = <String>[];
    if (startYear != null) parts.add('s$startYear');
    if (endYear != null) parts.add('e$endYear');
    if (bounds != null) {
      parts.add('${bounds.south.toStringAsFixed(1)}_${bounds.north.toStringAsFixed(1)}');
      parts.add('${bounds.west.toStringAsFixed(1)}_${bounds.east.toStringAsFixed(1)}');
    }
    return '$_prefix${parts.join('_')}';
  }

  /// Armazena marcadores para a região/período especificados.
  Future<void> cacheMarkers({
    required List<MapMarker> markers,
    int? startYear,
    int? endYear,
    GeoBounds? bounds,
  }) async {
    final key = _key(startYear: startYear, endYear: endYear, bounds: bounds);
    final data = markers.map((m) => _markerToJson(m)).toList();

    _memory[key] = _CacheEntry(data: data, timestamp: DateTime.now());

    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({'ts': DateTime.now().millisecondsSinceEpoch, 'data': data});
      await prefs.setString(key, payload);
    } catch (e) {
      ChronosLogger.warn('Cache disk falhou, usando memória: $e', tag: _tag);
    }
  }

  /// Recupera marcadores cacheados para a região/período.
  ///
  /// Retorna null se o cache expirou ou não existe.
  Future<List<MapMarker>?> getCachedMarkers({
    int? startYear,
    int? endYear,
    GeoBounds? bounds,
  }) async {
    final key = _key(startYear: startYear, endYear: endYear, bounds: bounds);

    // Tenta memória primeiro
    if (_memory.containsKey(key)) {
      final entry = _memory[key]!;
      if (DateTime.now().difference(entry.timestamp) < _ttl) {
        return entry.data.map(_markerFromJson).toList();
      } else {
        _memory.remove(key);
      }
    }

    // Tenta disco
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.fromMillisecondsSinceEpoch(decoded['ts'] as int);
      if (DateTime.now().difference(ts) > _ttl) {
        await prefs.remove(key);
        return null;
      }

      final data = (decoded['data'] as List).cast<Map<String, dynamic>>();
      _memory[key] = _CacheEntry(data: data, timestamp: ts);
      return data.map(_markerFromJson).toList();
    } catch (e) {
      ChronosLogger.warn('Leitura de cache disk falhou: $e', tag: _tag);
      return null;
    }
  }

  /// Pré-carrega dados para um período (chamado proativamente).
  Future<void> warmUp({
    required List<MapMarker> markers,
    required int startYear,
    required int endYear,
    GeoBounds? bounds,
  }) async {
    await cacheMarkers(
      markers: markers,
      startYear: startYear,
      endYear: endYear,
      bounds: bounds,
    );
    ChronosLogger.info('WarmUp concluído: ${markers.length} marcadores para [$startYear..$endYear]', tag: _tag);
  }

  /// Limpa todo o cache de mapas.
  Future<void> clearAll() async {
    _memory.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  // ─── Serialização ───────────────────────────────────────────────

  Map<String, dynamic> _markerToJson(MapMarker m) => {
        'id': m.id,
        'entityType': m.entityType,
        'entityId': m.entityId,
        'title': m.title,
        'subtitle': m.subtitle,
        'lat': m.position.latitude,
        'lng': m.position.longitude,
        'year': m.year,
        'color': m.style.color,
        'size': m.style.size,
      };

  MapMarker _markerFromJson(Map<String, dynamic> json) => MapMarker(
        id: json['id'] as String,
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String?,
        position: GeoCoordinate(
          latitude: (json['lat'] as num).toDouble(),
          longitude: (json['lng'] as num).toDouble(),
        ),
        year: json['year'] as int?,
        style: MapMarkerStyle(
          color: json['color'] as int? ?? 0xFFE65100,
          size: (json['size'] as num?)?.toDouble() ?? 36,
        ),
      );
}

class _CacheEntry {
  final List<Map<String, dynamic>> data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});
}
