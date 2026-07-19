import 'publication_status.dart';

/// Entidade de Domínio representando uma Localização histórica no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class Location {
  final String id;
  final String slug;
  final String nome;
  final double latitude;
  final double longitude;
  final String regiao;
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Location({
    required this.id,
    required this.slug,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.regiao,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  Location copyWith({
    String? id,
    String? slug,
    String? nome,
    double? latitude,
    double? longitude,
    String? regiao,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      regiao: regiao ?? this.regiao,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.id == id &&
        other.slug == slug &&
        other.nome == nome &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.regiao == regiao &&
        other.publicationStatus == publicationStatus &&
        other.ativo == ativo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        slug.hashCode ^
        nome.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        regiao.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
