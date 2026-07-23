import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import '../widgets/consensus_section.dart';
import '../widgets/curiosities_section.dart';
import '../widgets/debates_section.dart';
import '../widgets/knowledge_timeline_section.dart';
import '../widgets/related_entities_section.dart';
import '../widgets/reliability_badge.dart';
import '../widgets/sources_section.dart';

/// Página de detalhes completa de uma entidade na Knowledge Base.
///
/// Reutilizável para qualquer tipo: Character, Event, Civilization, Artifact, Location.
class KnowledgeDetailPage extends StatelessWidget {
  final KnowledgeEntry entry;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onAskAI;
  final ValueChanged<KnowledgeRelation>? onRelationTap;

  const KnowledgeDetailPage({
    super.key,
    required this.entry,
    this.onFavorite,
    this.onShare,
    this.onAskAI,
    this.onRelationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(ChronosSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: ChronosSpacing.lg),
                  _buildResumo(),
                  if (entry.conteudoCompleto != null) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    _buildConteudoCompleto(),
                  ],
                  if (entry.principaisFeitos.isNotEmpty) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    _buildPrincipaisFeitos(),
                  ],
                  if (entry.influenciaHistorica != null) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    _buildInfluencia(),
                  ],
                  if (entry.linhaDoTempo.isNotEmpty) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    KnowledgeTimelineSection(entries: entry.linhaDoTempo),
                  ],
                  if (entry.consenso != null) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    ConsensusSection(consensus: entry.consenso!),
                  ],
                  if (entry.debates.isNotEmpty) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    DebatesSection(debates: entry.debates),
                  ],
                  if (entry.curiosidades.isNotEmpty) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    CuriositiesSection(curiosities: entry.curiosidades),
                  ],
                  if (entry.relacoes.isNotEmpty) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    RelatedEntitiesSection(
                      relations: entry.relacoes,
                      onTap: onRelationTap,
                    ),
                  ],
                  if (entry.fontes.isNotEmpty) ...[
                    const SizedBox(height: ChronosSpacing.lg),
                    SourcesSection(sources: entry.fontes),
                  ],
                  const SizedBox(height: ChronosSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          entry.nome,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
        background: entry.bannerUrl != null
            ? Image.network(
                entry.bannerUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackBanner(),
              )
            : _buildFallbackBanner(),
      ),
      actions: [
        if (onFavorite != null)
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: onFavorite,
          ),
        if (onShare != null)
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: onShare,
          ),
        if (onAskAI != null)
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Perguntar à IA',
            onPressed: onAskAI,
          ),
      ],
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ChronosColors.primary.withOpacity(0.8),
            ChronosColors.primary.withOpacity(0.4),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _entityIcon,
          size: 64,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.nomeOriginal != null)
          Text(
            entry.nomeOriginal!,
            style: ChronosTypography.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
              color: ChronosColors.textMuted,
            ),
          ),
        if (entry.periodoHistorico != null) ...[
          const SizedBox(height: ChronosSpacing.xs),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: ChronosColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                entry.periodoHistorico!,
                style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary),
              ),
            ],
          ),
        ],
        if (entry.civilizacao != null) ...[
          const SizedBox(height: ChronosSpacing.xs),
          Row(
            children: [
              Icon(Icons.account_balance_rounded, size: 14, color: ChronosColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                entry.civilizacao!,
                style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildResumo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo',
          style: ChronosTypography.titleMedium.copyWith(color: ChronosColors.textPrimary),
        ),
        const SizedBox(height: ChronosSpacing.sm),
        Text(
          entry.resumo,
          style: ChronosTypography.bodyMedium.copyWith(
            color: ChronosColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildConteudoCompleto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biografia',
          style: ChronosTypography.titleMedium.copyWith(color: ChronosColors.textPrimary),
        ),
        const SizedBox(height: ChronosSpacing.sm),
        Text(
          entry.conteudoCompleto!,
          style: ChronosTypography.bodyMedium.copyWith(
            color: ChronosColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPrincipaisFeitos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Principais Feitos',
          style: ChronosTypography.titleMedium.copyWith(color: ChronosColors.textPrimary),
        ),
        const SizedBox(height: ChronosSpacing.sm),
        ...entry.principaisFeitos.map((block) => Padding(
              padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(ChronosSpacing.sm),
                decoration: BoxDecoration(
                  color: ChronosColors.surface,
                  borderRadius: ChronosRadius.borderRadiusSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            block.conteudo,
                            style: ChronosTypography.bodyMedium,
                          ),
                        ),
                        if (block.confiabilidade != ReliabilityLevel.fact)
                          ReliabilityBadge(level: block.confiabilidade, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildInfluencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Influência Histórica',
          style: ChronosTypography.titleMedium.copyWith(color: ChronosColors.textPrimary),
        ),
        const SizedBox(height: ChronosSpacing.sm),
        Text(
          entry.influenciaHistorica!,
          style: ChronosTypography.bodyMedium.copyWith(
            color: ChronosColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  IconData get _entityIcon {
    switch (entry.entityType) {
      case EntityType.character:
        return Icons.person_rounded;
      case EntityType.event:
        return Icons.event_rounded;
      case EntityType.civilization:
        return Icons.account_balance_rounded;
      case EntityType.artifact:
        return Icons.diamond_rounded;
      case EntityType.location:
        return Icons.place_rounded;
      case EntityType.era:
        return Icons.timeline_rounded;
    }
  }
}
