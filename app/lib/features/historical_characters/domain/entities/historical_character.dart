import 'package:chronos/domain/entities/publication_status.dart';

/// Entidade de Domínio representando um Personagem Histórico no ecossistema CHRONOS.
///
/// Totalmente pura, livre de qualquer dependência de frameworks ou de persistência.
/// Implementa igualdade estrutural por valor e suporte a atualizações imutáveis.
class HistoricalCharacter {
  final String id;
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
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HistoricalCharacter({
    required this.id,
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
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma cópia deste Personagem Histórico com as propriedades especificadas alteradas (Padrão Prototype).
  HistoricalCharacter copyWith({
    String? id,
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
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoricalCharacter(
      id: id ?? this.id,
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
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoricalCharacter &&
        other.id == id &&
        other.slug == slug &&
        other.nome == nome &&
        other.nomeOriginal == nomeOriginal &&
        other.nomeAlternativo == nomeAlternativo &&
        other.titulo == titulo &&
        other.epiteto == epiteto &&
        other.descricao == descricao &&
        other.descricaoResumida == descricaoResumida &&
        other.dataNascimento == dataNascimento &&
        other.dataMorte == dataMorte &&
        other.eraId == eraId &&
        other.localNascimentoId == localNascimentoId &&
        other.localMorteId == localMorteId &&
        other.sexo == sexo &&
        other.ocupacaoPrincipal == ocupacaoPrincipal &&
        other.civilizacaoPrincipalId == civilizacaoPrincipalId &&
        other.imagemPrincipal == imagemPrincipal &&
        other.corIdentificacao == corIdentificacao &&
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
        nomeOriginal.hashCode ^
        nomeAlternativo.hashCode ^
        titulo.hashCode ^
        epiteto.hashCode ^
        descricao.hashCode ^
        descricaoResumida.hashCode ^
        dataNascimento.hashCode ^
        dataMorte.hashCode ^
        eraId.hashCode ^
        localNascimentoId.hashCode ^
        localMorteId.hashCode ^
        sexo.hashCode ^
        ocupacaoPrincipal.hashCode ^
        civilizacaoPrincipalId.hashCode ^
        imagemPrincipal.hashCode ^
        corIdentificacao.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
