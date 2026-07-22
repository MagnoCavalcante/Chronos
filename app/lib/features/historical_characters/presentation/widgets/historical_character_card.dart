import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/status_badge.dart';
import '../../domain/entities/historical_character.dart';
import 'package:chronos/domain/entities/era.dart';

/// Card de exibição altamente polido para renderizar um Personagem Histórico.
///
/// Apresenta de forma estruturada as informações da entidade [HistoricalCharacter],
/// integrando dados contextuais como a [Era] de atuação, ciclo de vida estruturado,
/// imagens principais e badges de status de publicação.
class HistoricalCharacterCard extends StatelessWidget {
  final HistoricalCharacter item;
  final Era? era;
  final VoidCallback? onTap;

  const HistoricalCharacterCard({
    super.key,
    required this.item,
    this.era,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extrai e converte a cor da Era para estilização dinâmica
    Color? eraColor;
    if (era != null) {
      try {
        final cleanHex = era!.corHex.replaceFirst('#', '');
        if (cleanHex.length == 6) {
          eraColor = Color(int.parse('FF$cleanHex', radix: 16));
        } else if (cleanHex.length == 8) {
          eraColor = Color(int.parse(cleanHex, radix: 16));
        }
      } catch (_) {
        // Ignora falhas de parse de cores e usa fallback
      }
    }

    final Color accentColor = eraColor ?? Colors.amberAccent;

    // Formatação amigável do período de vida (lifespan)
    final birthYear = item.dataNascimento.year;
    final String birthStr = birthYear < 0 ? '${birthYear.abs()} a.C.' : '$birthYear d.C.';

    String periodLabel;
    if (item.dataMorte != null) {
      final deathYear = item.dataMorte!.year;
      final String deathStr = deathYear < 0 ? '${deathYear.abs()} a.C.' : '$deathYear d.C.';
      periodLabel = '$birthStr — $deathStr';
    } else {
      periodLabel = 'Nascido(a) em $birthStr';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: Imagem/Avatar, Nome, Título e Badge de Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem Principal ou Avatar de Fallback
                  _buildLeadingWidget(accentColor),
                  const SizedBox(width: 14),

                  // Nome, Título/Epiteto e Tipo de Personagem
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          semanticsLabel: 'Nome do personagem: ${item.nome}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (item.titulo != null && item.titulo!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.titulo!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (item.ocupacaoPrincipal != null && item.ocupacaoPrincipal!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.ocupacaoPrincipal!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.bold,
                              color: accentColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Badge de status de publicação
                  StatusBadge(status: item.publicationStatus.value),
                ],
              ),
              const SizedBox(height: 14),

              // Pequena descrição (Descrição Resumida ou Descrição principal recortada)
              Text(
                item.descricaoResumida.isNotEmpty
                    ? item.descricaoResumida
                    : item.descricao,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Separador sutil
              const Divider(color: Colors.white12, height: 1, thickness: 0.8),
              const SizedBox(height: 12),

              // Rodapé: Período Cronológico, Vínculo de Era e Sexo/Civilização
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Metadados de período e Era
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cronologia/Lifespan
                        Row(
                          children: [
                            const Icon(Icons.hourglass_empty_rounded, size: 13, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                periodLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Vínculo da Era correspondente
                        Row(
                          children: [
                            const Icon(Icons.history_edu_rounded, size: 13, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Era: ${era?.nome ?? "Desconhecida"}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: accentColor.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Indicador de Gênero ou Atividade
                  Row(
                    children: [
                      Icon(
                        item.sexo.toLowerCase() == 'm'
                            ? Icons.male_rounded
                            : item.sexo.toLowerCase() == 'f'
                                ? Icons.female_rounded
                                : Icons.person_outline_rounded,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.sexo.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget(Color fallbackColor) {
    if (item.imagemPrincipal != null && item.imagemPrincipal!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 50,
          height: 50,
          color: Colors.white10,
          child: Image.network(
            item.imagemPrincipal!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(fallbackColor),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      );
    }
    return _buildAvatarFallback(fallbackColor);
  }

  Widget _buildAvatarFallback(Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.person_rounded,
        color: color,
        size: 26,
      ),
    );
  }
}
