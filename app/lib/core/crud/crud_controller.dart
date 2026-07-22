import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import '../utils/result.dart';
import 'crud_field.dart';
import 'crud_repository.dart';

/// Controller genérico para CRUD de qualquer tabela do CHRONOS.
///
/// Gerencia o estado reativo da listagem e coordena as operações
/// de criação, atualização e exclusão através do [CrudRepository].
class CrudController extends ChangeNotifier {
  final CrudRepository repository;
  final List<CrudField> fields;

  List<Map<String, dynamic>> _items = const [];
  bool _isLoading = false;
  String? _error;

  CrudController({
    required this.repository,
    required this.fields,
  });

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _items.isEmpty && !_isLoading && _error == null;

  Future<void> load() async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    final result = await repository.getAll();
    result.fold(
      onSuccess: (data) {
        _items = data;
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    _setLoading(false);
  }

  Future<bool> save(Map<String, dynamic> data) async {
    final id = data['id'] as String?;
    final isNew = id == null || id.isEmpty;

    Result<Map<String, dynamic>> result;
    if (isNew) {
      result = await repository.create(_preparePayload(data));
    } else {
      result = await repository.update(id, _preparePayload(data));
    }

    return result.fold(
      onSuccess: (_) {
        _error = null;
        load();
        return true;
      },
      onFailure: (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> delete(String id) async {
    final result = await repository.delete(id);
    return result.fold(
      onSuccess: (_) {
        _error = null;
        load();
        return true;
      },
      onFailure: (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  Map<String, dynamic> _preparePayload(Map<String, dynamic> data) {
    final payload = <String, dynamic>{};
    for (final field in fields) {
      if (!data.containsKey(field.name)) continue;
      final raw = data[field.name];
      if (raw == null || raw.toString().trim().isEmpty) continue;
      switch (field.type) {
        case CrudFieldType.year:
        case CrudFieldType.integer:
          final parsed = int.tryParse(raw.toString().trim());
          if (parsed != null) payload[field.name] = parsed;
        case CrudFieldType.number:
          final parsed = double.tryParse(raw.toString().trim());
          if (parsed != null) payload[field.name] = parsed;
        default:
          payload[field.name] = raw.toString().trim();
      }
    }
    if (!data.containsKey('publication_status') || data['publication_status'] == null) {
      payload['publication_status'] = 'published';
    }
    if (!data.containsKey('ativo') || data['ativo'] == null) {
      payload['ativo'] = true;
    }
    if (data['slug'] == null || (data['slug'] as String?)?.isEmpty == true) {
      final name = _extractName(data);
      if (name != null && name.isNotEmpty) {
        payload['slug'] = _slugify(name);
      }
    }
    return payload;
  }

  String? _extractName(Map<String, dynamic> data) {
    for (final key in ['name', 'nome', 'titulo', 'short_name']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  String _slugify(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .trim();
    return normalized.isEmpty ? 'registro' : normalized;
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _items = const [];
    super.dispose();
  }
}
