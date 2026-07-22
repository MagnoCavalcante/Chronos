import '../../domain/entities/publication_status.dart';
import 'crud_field.dart';
import 'crud_repository.dart';

/// Configuração de um módulo CRUD para a tela genérica do CHRONOS.
class CrudModuleConfig {
  final String title;
  final String itemLabel;
  final CrudRepository repository;
  final List<CrudField> fields;
  final String? imageKey;
  final String Function(Map<String, dynamic> record) titleBuilder;
  final String? Function(Map<String, dynamic> record) subtitleBuilder;

  CrudModuleConfig({
    required this.title,
    required this.itemLabel,
    required this.repository,
    required this.fields,
    this.imageKey,
    required this.titleBuilder,
    required this.subtitleBuilder,
  });
}

// ignore: avoid_classes_with_only_static_members
class CrudModuleConfigs {
  CrudModuleConfigs._();

  static String _text(Map<String, dynamic> record, String key, {String fallback = ''}) {
    final value = record[key];
    return value?.toString() ?? fallback;
  }

  static final civilizations = CrudModuleConfig(
    title: 'Civilizações',
    itemLabel: 'Civilização',
    repository: CrudRepository(tableName: 'civilizations', orderBy: 'name'),
    imageKey: 'cover_image_url',
    fields: const [
      CrudField(name: 'name', label: 'Nome'),
      CrudField(name: 'short_name', label: 'Região'),
      CrudField(name: 'start_year', label: 'Ano de início', type: CrudFieldType.year),
      CrudField(name: 'end_year', label: 'Ano de fim (opcional)', type: CrudFieldType.year, required: false),
      CrudField(name: 'summary', label: 'Resumo', type: CrudFieldType.multiline),
      CrudField(name: 'description', label: 'Descrição', type: CrudFieldType.multiline),
      CrudField(name: 'color', label: 'Cor (hex)', required: false, hint: '#RRGGBB'),
      CrudField(name: 'cover_image_url', label: 'Imagem (URL)', type: CrudFieldType.url, required: false),
    ],
    titleBuilder: (r) => _text(r, 'name'),
    subtitleBuilder: (r) => _text(r, 'summary', fallback: _text(r, 'description')),
  );

  static final historicalCharacters = CrudModuleConfig(
    title: 'Personagens Históricos',
    itemLabel: 'Personagem',
    repository: CrudRepository(tableName: 'historical_characters', orderBy: 'nome'),
    imageKey: 'imagem_principal',
    fields: const [
      CrudField(name: 'nome', label: 'Nome'),
      CrudField(name: 'civilizacao_principal_id', label: 'Civilização (ID)', required: false),
      CrudField(name: 'era_id', label: 'Período / Era (ID)'),
      CrudField(name: 'descricao', label: 'Biografia', type: CrudFieldType.multiline),
      CrudField(name: 'descricao_resumida', label: 'Resumo curto', type: CrudFieldType.multiline),
      CrudField(name: 'data_nascimento', label: 'Data de nascimento', type: CrudFieldType.date),
      CrudField(name: 'data_morte', label: 'Data de morte (opcional)', type: CrudFieldType.date, required: false),
      CrudField(
        name: 'sexo',
        label: 'Sexo',
        type: CrudFieldType.dropdown,
        options: [
          CrudOption('masculino', 'Masculino'),
          CrudOption('feminino', 'Feminino'),
          CrudOption('outro', 'Outro'),
        ],
      ),
      CrudField(name: 'ocupacao_principal', label: 'Ocupação principal', required: false),
      CrudField(name: 'imagem_principal', label: 'Imagem (URL)', type: CrudFieldType.url, required: false),
      CrudField(name: 'cor_identificacao', label: 'Cor identificação (hex)', required: false, hint: '#RRGGBB'),
    ],
    titleBuilder: (r) => _text(r, 'nome'),
    subtitleBuilder: (r) => _text(r, 'descricao_resumida', fallback: _text(r, 'descricao')),
  );

  static final historicalEvents = CrudModuleConfig(
    title: 'Eventos Históricos',
    itemLabel: 'Evento',
    repository: CrudRepository(tableName: 'historical_events', orderBy: 'start_year'),
    fields: const [
      CrudField(name: 'titulo', label: 'Título'),
      CrudField(name: 'titulo_curto', label: 'Título curto'),
      CrudField(name: 'descricao', label: 'Descrição', type: CrudFieldType.multiline),
      CrudField(name: 'descricao_resumida', label: 'Descrição resumida', type: CrudFieldType.multiline),
      CrudField(name: 'start_year', label: 'Ano de início', type: CrudFieldType.year),
      CrudField(name: 'end_year', label: 'Ano de fim (opcional)', type: CrudFieldType.year, required: false),
      CrudField(name: 'era_id', label: 'Era (ID)'),
      CrudField(name: 'civilization_id', label: 'Civilização (ID)', required: false),
      CrudField(name: 'location_id', label: 'Localização (ID)', required: false),
      CrudField(
        name: 'event_type',
        label: 'Tipo de evento',
        type: CrudFieldType.dropdown,
        options: [
          CrudOption('political', 'Político'),
          CrudOption('military', 'Militar'),
          CrudOption('social', 'Social'),
          CrudOption('cultural', 'Cultural'),
          CrudOption('scientific', 'Científico'),
          CrudOption('religious', 'Religioso'),
          CrudOption('economic', 'Econômico'),
          CrudOption('other', 'Outro'),
        ],
      ),
      CrudField(
        name: 'date_precision',
        label: 'Precisão da data',
        type: CrudFieldType.dropdown,
        options: [
          CrudOption('exact', 'Exata'),
          CrudOption('century', 'Século'),
          CrudOption('decade', 'Década'),
          CrudOption('year', 'Ano'),
          CrudOption('month', 'Mês'),
          CrudOption('day', 'Dia'),
          CrudOption('approximate', 'Aproximada'),
        ],
      ),
      CrudField(name: 'importance_score', label: 'Importância (1 a 5)', type: CrudFieldType.integer),
    ],
    titleBuilder: (r) => _text(r, 'titulo'),
    subtitleBuilder: (r) => _text(r, 'descricao_resumida', fallback: _text(r, 'descricao')),
  );

  static final artifacts = CrudModuleConfig(
    title: 'Artefatos Históricos',
    itemLabel: 'Artefato',
    repository: CrudRepository(tableName: 'artifacts', orderBy: 'name'),
    imageKey: 'cover_image_url',
    fields: const [
      CrudField(name: 'name', label: 'Nome'),
      CrudField(name: 'short_name', label: 'Nome curto', required: false),
      CrudField(name: 'artifact_type', label: 'Tipo do artefato'),
      CrudField(name: 'estimated_year', label: 'Ano estimado', type: CrudFieldType.year),
      CrudField(name: 'material', label: 'Material'),
      CrudField(name: 'current_location', label: 'Localização atual'),
      CrudField(name: 'description', label: 'Descrição', type: CrudFieldType.multiline),
      CrudField(name: 'summary', label: 'Resumo', type: CrudFieldType.multiline, required: false),
      CrudField(name: 'origin_civilization_id', label: 'Civilização de origem (ID)', required: false),
      CrudField(name: 'origin_location_id', label: 'Local de origem (ID)', required: false),
      CrudField(name: 'cover_image_url', label: 'Imagem (URL)', type: CrudFieldType.url, required: false),
    ],
    titleBuilder: (r) => _text(r, 'name'),
    subtitleBuilder: (r) => _text(r, 'summary', fallback: _text(r, 'description')),
  );

  static final historicalLocations = CrudModuleConfig(
    title: 'Localizações Históricas',
    itemLabel: 'Localização',
    repository: CrudRepository(tableName: 'historical_locations', orderBy: 'name'),
    imageKey: 'cover_image_url',
    fields: const [
      CrudField(name: 'name', label: 'Nome'),
      CrudField(name: 'short_name', label: 'Nome curto', required: false),
      CrudField(
        name: 'location_type',
        label: 'Tipo',
        type: CrudFieldType.dropdown,
        options: [
          CrudOption('continent', 'Continente'),
          CrudOption('country', 'País'),
          CrudOption('region', 'Região'),
          CrudOption('province', 'Província'),
          CrudOption('city', 'Cidade'),
          CrudOption('village', 'Vila'),
          CrudOption('settlement', 'Assentamento'),
          CrudOption('empire', 'Império'),
          CrudOption('kingdom', 'Reino'),
          CrudOption('archaeological_site', 'Sítio arqueológico'),
          CrudOption('battlefield', 'Campo de batalha'),
          CrudOption('religious_site', 'Sítio religioso'),
          CrudOption('monument', 'Monumento'),
          CrudOption('natural_landmark', 'Marco natural'),
        ],
      ),
      CrudField(name: 'modern_country', label: 'País moderno'),
      CrudField(name: 'modern_region', label: 'Região moderna'),
      CrudField(name: 'latitude', label: 'Latitude', type: CrudFieldType.number),
      CrudField(name: 'longitude', label: 'Longitude', type: CrudFieldType.number),
      CrudField(name: 'start_year', label: 'Ano de início', type: CrudFieldType.year),
      CrudField(name: 'end_year', label: 'Ano de fim (opcional)', type: CrudFieldType.year, required: false),
      CrudField(name: 'description', label: 'Descrição', type: CrudFieldType.multiline),
      CrudField(name: 'summary', label: 'Resumo', type: CrudFieldType.multiline, required: false),
      CrudField(name: 'parent_location_id', label: 'Localização pai (ID)', required: false),
      CrudField(name: 'cover_image_url', label: 'Imagem (URL)', type: CrudFieldType.url, required: false),
    ],
    titleBuilder: (r) => _text(r, 'name'),
    subtitleBuilder: (r) => _text(r, 'summary', fallback: _text(r, 'description')),
  );

  static final historicalSources = CrudModuleConfig(
    title: 'Fontes Históricas',
    itemLabel: 'Fonte',
    repository: CrudRepository(tableName: 'historical_sources', orderBy: 'titulo'),
    fields: const [
      CrudField(name: 'titulo', label: 'Título'),
      CrudField(name: 'autor', label: 'Autor'),
      CrudField(name: 'url', label: 'URL', type: CrudFieldType.url, required: false),
      CrudField(name: 'descricao', label: 'Descrição', type: CrudFieldType.multiline),
    ],
    titleBuilder: (r) => _text(r, 'titulo'),
    subtitleBuilder: (r) => _text(r, 'autor'),
  );
}
