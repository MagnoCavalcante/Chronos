import 'package:flutter/material.dart';
import '../../../domain/entities/era.dart';
import '../../../domain/entities/event.dart';

enum TimelineItemType { era, event }

/// Modelo unificado de apresentação para os nós da Timeline CHRONOS.
///
/// Consolida diferentes tipos de entidades (Eras, Eventos) em um formato comum
/// com suporte completo a cores de Eras e formatação cronológica amigável.
class TimelineDisplayItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int year;
  final String? imageUrl;
  final Color color;
  final TimelineItemType type;
  final dynamic originalEntity;

  const TimelineDisplayItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.year,
    this.imageUrl,
    required this.color,
    required this.type,
    required this.originalEntity,
  });

  /// Constrói um item a partir de uma entidade [Era].
  factory TimelineDisplayItem.fromEra(Era era, Color color) {
    final startSuffix = era.inicioAno < 0 ? ' a.C.' : ' d.C.';
    final endSuffix = era.fimAno < 0 ? ' a.C.' : ' d.C.';
    final String periodLabel = '${era.inicioAno.abs()}$startSuffix — ${era.fimAno.abs()}$endSuffix';

    return TimelineDisplayItem(
      id: era.id,
      title: era.nome,
      subtitle: periodLabel,
      description: era.descricaoResumida.isNotEmpty
          ? era.descricaoResumida
          : era.descricao,
      year: era.inicioAno,
      imageUrl: era.coverImageUrl,
      color: color,
      type: TimelineItemType.era,
      originalEntity: era,
    );
  }

  /// Constrói um item a partir de uma entidade [HistoricalEvent] e sua respectiva [Era].
  factory TimelineDisplayItem.fromEvent(HistoricalEvent event, Era? era, Color color) {
    final suffix = event.anoOcorrencia < 0 ? ' a.C.' : ' d.C.';
    final String periodLabel = '${event.anoOcorrencia.abs()}$suffix';

    return TimelineDisplayItem(
      id: event.id,
      title: event.nome,
      subtitle: periodLabel,
      description: event.descricao,
      year: event.anoOcorrencia,
      imageUrl: null, // Eventos não possuem imagens diretas na entidade pura
      color: color,
      type: TimelineItemType.event,
      originalEntity: event,
    );
  }
}
