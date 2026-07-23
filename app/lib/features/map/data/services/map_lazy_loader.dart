import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/historical_location.dart';
import '../../../../domain/usecases/get_locations_within_bounds.dart';
import '../../domain/entities/map_entities.dart';

/// Serviço de carregamento progressivo (Lazy Loading) de marcadores.
///
/// Carrega apenas:
/// - marcadores da área visível (bounding box);
/// - dentro do período histórico selecionado;
/// - nas camadas ativas.
///
/// Não carrega todo o banco de uma vez.
class MapLazyLoader {
  final GetLocationsWithinBounds _getLocationsWithinBounds;
  static const String _tag = 'MapLazyLoader';

  /// Cache do último carregamento para evitar recarregar área idêntica.
  GeoBounds? _lastLoadedBounds;
  int? _lastStartYear;
  int? _lastEndYear;
  List<MapMarker> _lastMarkers = [];

  MapLazyLoader({required GetLocationsWithinBounds getLocationsWithinBounds})
      : _getLocationsWithinBounds = getLocationsWithinBounds;

  /// Carrega marcadores dentro dos [bounds] visíveis, opcionalmente filtrados por período.
  ///
  /// Se os bounds forem idênticos ao último carregamento, retorna cache.
  Future<List<MapMarker>> loadVisibleMarkers({
    required GeoBounds bounds,
    int? startYear,
    int? endYear,
  }) async {
    if (_isSameRequest(bounds, startYear, endYear)) {
      return _lastMarkers;
    }

    ChronosLogger.info(
      'Carregando marcadores: lat[${bounds.south},${bounds.north}] lng[${bounds.west},${bounds.east}] anos[$startYear,$endYear]',
      tag: _tag,
    );

    try {
      final params = GetLocationsWithinBoundsParams(
        minLat: bounds.south,
        maxLat: bounds.north,
        minLng: bounds.west,
        maxLng: bounds.east,
      );

      final result = await _getLocationsWithinBounds(params);
      List<HistoricalLocation> locations = [];
      result.fold(
        onSuccess: (data) => locations = data,
        onFailure: (f) => ChronosLogger.error('Falha no lazy load: ${f.message}', tag: _tag),
      );

      // Filtra por período se fornecido
      if (startYear != null || endYear != null) {
        locations = locations.where((loc) {
          if (startYear != null && loc.startYear > startYear) return false;
          if (endYear != null && loc.endYear != null && loc.endYear! < endYear) return false;
          return true;
        }).toList();
      }

      _lastMarkers = locations.map(_toMarker).toList();
      _lastLoadedBounds = bounds;
      _lastStartYear = startYear;
      _lastEndYear = endYear;

      ChronosLogger.info('Lazy load concluído: ${_lastMarkers.length} marcadores', tag: _tag);
      return _lastMarkers;
    } catch (e) {
      ChronosLogger.error('Erro no lazy load: $e', tag: _tag, error: e);
      return _lastMarkers;
    }
  }

  /// Invalida o cache forçando próximo carregamento a refazer a query.
  void invalidate() {
    _lastLoadedBounds = null;
    _lastStartYear = null;
    _lastEndYear = null;
    _lastMarkers = [];
  }

  // ─── Private helpers ───────────────────────────────────────────────

  bool _isSameRequest(GeoBounds bounds, int? startYear, int? endYear) {
    if (_lastLoadedBounds == null) return false;
    return _lastLoadedBounds!.north == bounds.north &&
        _lastLoadedBounds!.south == bounds.south &&
        _lastLoadedBounds!.east == bounds.east &&
        _lastLoadedBounds!.west == bounds.west &&
        _lastStartYear == startYear &&
        _lastEndYear == endYear;
  }

  MapMarker _toMarker(HistoricalLocation location) {
    return MapMarker(
      id: location.id,
      entityType: 'historical_location',
      entityId: location.id,
      title: location.name,
      subtitle: location.shortName,
      position: GeoCoordinate(latitude: location.latitude, longitude: location.longitude),
      year: location.startYear,
      style: MapMarkerStyle(
        color: _colorForType(location.locationType),
      ),
    );
  }

  int _colorForType(LocationType type) {
    switch (type) {
      case LocationType.battlefield:
        return 0xFFC62828;
      case LocationType.empire:
      case LocationType.kingdom:
        return 0xFF6A1B9A;
      case LocationType.city:
      case LocationType.village:
      case LocationType.settlement:
        return 0xFF1565C0;
      case LocationType.archaeologicalSite:
        return 0xFF4E342E;
      case LocationType.religiousSite:
        return 0xFF00695C;
      case LocationType.monument:
        return 0xFFEF6C00;
      case LocationType.naturalLandmark:
        return 0xFF2E7D32;
      default:
        return 0xFFE65100;
    }
  }
}
