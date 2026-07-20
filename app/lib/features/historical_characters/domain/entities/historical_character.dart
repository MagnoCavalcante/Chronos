import 'package:chronos/core/base/base_entity.dart';
import 'package:chronos/domain/entities/publication_status.dart';

/// Entidade de Domínio representando um Personagem Histórico no ecossistema CHRONOS.
///
/// Totalmente pura, livre de qualquer dependência de frameworks ou de persistência.
/// Implementa igualdade estrutural por valor e suporte a atualizações imutáveis.
/// Extende [BaseEntity] para centralizar atributos comuns.
class HistoricalCharacter extends BaseEntity {
  final String slug;
  final String nome;
  final String? nomeOriginal;
  final String? nomeAlternativo;
  final String? titulo;
  final String? epiteto;
  final String descricao;
  final String descricaoResumida;
  final DateTime dataNascimento;
  final DateTime? dataMorte;
  final String eraId;
  final String? localNascimentoId;
  final String? localMorteId;
  final String sexo;
  final String? ocupacaoPrincipal;
  final String? civilizacaoPrincipalId;
  final String? imagemPrincipal;
  final String? corIdentificacao;
  final PublicationStatus publicationStatus;

  const HistoricalCharacter({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.slug,
    required this.nome,
    this.nomeOriginal,
    this.nomeAlternativo,
    this.titulo,
    this.epiteto,
    required this.descricao,
    required this.descricaoResumida,
    required this.dataNascimento,
    this.dataMorte,
    required this.eraId,
    this.localNascimentoId,
    this.localMorteId,
    required this.sexo,
    this.ocupacaoPrincipal,
    this.civilizacaoPrincipalId,
    this.imagemPrincipal,
    this.corIdentificacao,
    required this.publicationStatus,
  });

  @override
  HistoricalCharacter copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? slug,
    String? nome,
    String? nomeOriginal,
    String? nomeAlternativo,
    String? titulo,
    String? epiteto,
    String? descricao,
    String? descricaoResumida,
    DateTime? dataNascimento,
    DateTime? dataMorte,
    String? eraId,
    String? localNascimentoId,
    String? localMorteId,
    String? sexo,
    String? ocupacaoPrincipal,
    String? civilizacaoPrincipalId,
    String? imagemPrincipal,
    String? corIdentificacao,
    PublicationStatus? publicationStatus,
  }) {
    return HistoricalCharacter(
      id: id ?? this.id,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      nomeOriginal: nomeOriginal ?? this.nomeOriginal,
      nomeAlternativo: nomeAlternativo ?? this.nomeAlternativo,
      titulo: titulo ?? this.titulo,
      epiteto: epiteto ?? this.epiteto,
      descricao: descricao ?? this.descricao,
      descricaoResumida: descricaoResumida ?? this.descricaoResumida,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      dataMorte: dataMorte ?? this.dataMorte,
      eraId: eraId ?? this.eraId,
      localNascimentoId: localNascimentoId ?? this.localNascimentoId,
      localMorteId: localMorteId ?? this.localMorteId,
      sexo: sexo ?? this.sexo,
      ocupacaoPrincipal: ocupacaoPrincipal ?? this.ocupacaoPrincipal,
      civilizacaoPrincipalId: civilizacaoPrincipalId ?? this.civilizacaoPrincipalId,
      imagemPrincipal: imagemPrincipal ?? this.imagemPrincipal,
      corIdentificacao: corIdentificacao ?? this.corIdentificacao,
      publicationStatus: publicationStatus ?? this.publicationStatus,
    );
  }
}
